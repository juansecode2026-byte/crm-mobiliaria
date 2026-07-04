-- ============================================================
-- MIGRATION 019: Security Fix — Functions
--
-- Problema 1: search_path mutable en funciones SECURITY DEFINER
--   → permite que un atacante cree objetos en otro schema que
--     "ganen" la resolución de nombres y se ejecuten con privilegios
--     del owner. Fix: SET search_path = public, pg_catalog.
--
-- Problema 2: funciones SECURITY DEFINER ejecutables por anon
--   → cualquier persona sin login puede llamarlas vía /rest/v1/rpc/
--     y ejecutan con privilegios del creador (bypassing RLS).
--   Fix: REVOKE de PUBLIC, GRANT solo a los roles que las necesitan.
-- ============================================================

-- ============================================================
-- 1. fn_current_organization_id
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_current_organization_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, pg_catalog AS $$
    SELECT organization_id FROM public.profiles WHERE id = auth.uid()
$$;

REVOKE ALL   ON FUNCTION public.fn_current_organization_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_current_organization_id() TO authenticated;

-- ============================================================
-- 2. fn_current_role
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_current_role()
RETURNS public.user_role LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, pg_catalog AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid()
$$;

REVOKE ALL   ON FUNCTION public.fn_current_role() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_current_role() TO authenticated;

-- ============================================================
-- 3. fn_current_contact_id
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_current_contact_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, pg_catalog AS $$
    SELECT contact_id FROM public.profiles WHERE id = auth.uid()
$$;

REVOKE ALL   ON FUNCTION public.fn_current_contact_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_current_contact_id() TO authenticated;

-- ============================================================
-- 4. fn_is_admin_or_manager
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_is_admin_or_manager()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, pg_catalog AS $$
    SELECT role IN ('admin', 'manager') FROM public.profiles WHERE id = auth.uid()
$$;

REVOKE ALL   ON FUNCTION public.fn_is_admin_or_manager() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.fn_is_admin_or_manager() TO authenticated;

-- ============================================================
-- 5. fn_set_updated_at  (trigger — no SECURITY DEFINER, igual
--    añadimos search_path como buena práctica)
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql
SET search_path = public, pg_catalog AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- ============================================================
-- 6. fn_handle_new_auth_user  (ya tenía search_path = public;
--    lo ampliamos a public, pg_catalog)
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_handle_new_auth_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_catalog AS $$
BEGIN
    INSERT INTO public.profiles (id, organization_id, role, first_name, last_name, email)
    VALUES (
        NEW.id,
        (NEW.raw_app_meta_data->>'organization_id')::UUID,
        COALESCE((NEW.raw_app_meta_data->>'role')::public.user_role, 'agent'),
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        NEW.email
    );
    RETURN NEW;
END;
$$;

-- ============================================================
-- 7. fn_operation_stage_change
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_operation_stage_change()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_catalog AS $$
BEGIN
    IF OLD.stage IS DISTINCT FROM NEW.stage THEN
        NEW.stage_changed_at = NOW();

        INSERT INTO public.activities (
            organization_id, performed_by, activity_type,
            entity_type, entity_id, old_values, new_values, description
        ) VALUES (
            NEW.organization_id,
            auth.uid(),
            'stage_changed',
            'operation',
            NEW.id,
            jsonb_build_object('stage', OLD.stage),
            jsonb_build_object('stage', NEW.stage),
            format('Etapa cambiada de %s a %s', OLD.stage, NEW.stage)
        );

        IF NEW.stage = 'vendido' THEN
            UPDATE public.properties SET status = 'sold' WHERE id = NEW.property_id;
        END IF;

        IF OLD.stage = 'vendido' AND NEW.stage != 'vendido' THEN
            UPDATE public.properties SET status = 'available' WHERE id = NEW.property_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

-- ============================================================
-- 8. fn_log_payment
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_log_payment()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_catalog AS $$
BEGIN
    INSERT INTO public.activities (
        organization_id, performed_by, activity_type,
        entity_type, entity_id, new_values, description
    ) VALUES (
        NEW.organization_id,
        auth.uid(),
        'payment_received',
        'payment',
        NEW.id,
        jsonb_build_object(
            'amount',   NEW.amount,
            'currency', NEW.currency,
            'concept',  NEW.concept
        ),
        format('Pago registrado: %s %s — %s', NEW.amount, NEW.currency, NEW.concept)
    );
    RETURN NEW;
END;
$$;

-- ============================================================
-- 9. fn_custom_jwt_claims  (JWT hook — solo supabase_auth_admin)
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_custom_jwt_claims(event JSONB)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_catalog AS $$
DECLARE
    v_profile RECORD;
    v_claims  JSONB;
BEGIN
    SELECT organization_id, role, contact_id
    INTO v_profile
    FROM public.profiles
    WHERE id = (event->>'user_id')::UUID;

    v_claims := event->'claims';
    v_claims := jsonb_set(v_claims, '{organization_id}', to_jsonb(v_profile.organization_id::TEXT));
    v_claims := jsonb_set(v_claims, '{user_role}',       to_jsonb(v_profile.role::TEXT));

    IF v_profile.contact_id IS NOT NULL THEN
        v_claims := jsonb_set(v_claims, '{contact_id}', to_jsonb(v_profile.contact_id::TEXT));
    END IF;

    RETURN jsonb_set(event, '{claims}', v_claims);
END;
$$;

REVOKE ALL    ON FUNCTION public.fn_custom_jwt_claims(JSONB) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.fn_custom_jwt_claims(JSONB) TO supabase_auth_admin;
