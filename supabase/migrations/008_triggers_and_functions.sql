-- ============================================================
-- MIGRATION 008: Triggers and Functions
-- ============================================================

-- ============================================================
-- HELPER FUNCTIONS FOR RLS
-- ============================================================

CREATE OR REPLACE FUNCTION public.fn_current_organization_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER AS $$
    SELECT organization_id FROM public.profiles WHERE id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.fn_current_role()
RETURNS public.user_role LANGUAGE sql STABLE SECURITY DEFINER AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.fn_current_contact_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER AS $$
    SELECT contact_id FROM public.profiles WHERE id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.fn_is_admin_or_manager()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
    SELECT role IN ('admin', 'manager') FROM public.profiles WHERE id = auth.uid()
$$;

-- ============================================================
-- TRIGGER: Auto-update updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

DO $$
DECLARE
    t TEXT;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'organizations', 'profiles', 'contacts', 'properties',
        'operations', 'payments', 'integrations'
    ] LOOP
        EXECUTE format('
            CREATE TRIGGER trg_set_updated_at
            BEFORE UPDATE ON public.%I
            FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();
        ', t);
    END LOOP;
END;
$$;

-- ============================================================
-- TRIGGER: Auto-create profile after auth.users insert
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_handle_new_auth_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
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

CREATE TRIGGER trg_handle_new_auth_user
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.fn_handle_new_auth_user();

-- ============================================================
-- TRIGGER: Cambio de etapa en operaciones
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_operation_stage_change()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
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

CREATE TRIGGER trg_operation_stage_change
    BEFORE UPDATE ON public.operations
    FOR EACH ROW EXECUTE FUNCTION public.fn_operation_stage_change();

-- ============================================================
-- TRIGGER: Registrar pago contra una operación
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_log_payment()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
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
        jsonb_build_object('amount', NEW.amount, 'currency', NEW.currency, 'concept', NEW.concept),
        format('Pago registrado: %s %s — %s', NEW.amount, NEW.currency, NEW.concept)
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_log_payment
    AFTER INSERT ON public.payments
    FOR EACH ROW EXECUTE FUNCTION public.fn_log_payment();

-- ============================================================
-- CUSTOM JWT CLAIMS HOOK
-- Register in Supabase Dashboard > Auth > Hooks > Custom Access Token
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_custom_jwt_claims(event JSONB)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
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
    v_claims := jsonb_set(v_claims, '{user_role}', to_jsonb(v_profile.role::TEXT));

    IF v_profile.contact_id IS NOT NULL THEN
        v_claims := jsonb_set(v_claims, '{contact_id}', to_jsonb(v_profile.contact_id::TEXT));
    END IF;

    RETURN jsonb_set(event, '{claims}', v_claims);
END;
$$;
