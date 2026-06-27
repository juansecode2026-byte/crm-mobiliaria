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
        'opportunities', 'sales', 'cuotas', 'payments', 'integrations'
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
-- TRIGGER: Track pipeline stage changes on opportunities
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_opportunity_stage_change()
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
            'opportunity',
            NEW.id,
            jsonb_build_object('stage', OLD.stage),
            jsonb_build_object('stage', NEW.stage),
            format('Etapa cambiada de %s a %s', OLD.stage, NEW.stage)
        );

        IF NEW.stage = 'vendido' THEN
            UPDATE public.properties
            SET status = 'sold'
            WHERE id = NEW.property_id;
        END IF;

        IF OLD.stage = 'vendido' AND NEW.stage != 'vendido' THEN
            UPDATE public.properties
            SET status = 'available'
            WHERE id = NEW.property_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_opportunity_stage_change
    BEFORE UPDATE ON public.opportunities
    FOR EACH ROW EXECUTE FUNCTION public.fn_opportunity_stage_change();

-- ============================================================
-- TRIGGER: Auto-create cuotas when amortization_lines are inserted
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_create_cuota_from_amortization_line()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_sale RECORD;
BEGIN
    SELECT s.id, s.organization_id, s.contact_id
    INTO v_sale
    FROM public.amortization_schedules sch
    JOIN public.sales s ON s.id = sch.sale_id
    WHERE sch.id = NEW.schedule_id;

    INSERT INTO public.cuotas (
        organization_id, sale_id, amortization_line_id,
        contact_id, installment_number, due_date,
        amount_due, currency, status
    ) VALUES (
        NEW.organization_id,
        v_sale.id,
        NEW.id,
        v_sale.contact_id,
        NEW.installment_number,
        NEW.due_date,
        NEW.total_amount,
        NEW.currency,
        'pending'
    )
    ON CONFLICT (sale_id, installment_number) DO NOTHING;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_create_cuota_from_amort_line
    AFTER INSERT ON public.amortization_lines
    FOR EACH ROW EXECUTE FUNCTION public.fn_create_cuota_from_amortization_line();

-- ============================================================
-- TRIGGER: Update cuota status when a payment is registered
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_update_cuota_on_payment()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_cuota RECORD;
BEGIN
    SELECT id, amount_due, amount_paid
    INTO v_cuota
    FROM public.cuotas
    WHERE id = NEW.cuota_id
    FOR UPDATE;

    UPDATE public.cuotas
    SET
        amount_paid = amount_paid + NEW.amount,
        last_payment_date = NEW.payment_date,
        status = CASE
            WHEN (amount_paid + NEW.amount) >= amount_due THEN 'paid'::public.quota_status
            WHEN (amount_paid + NEW.amount) > 0 THEN 'partial'::public.quota_status
            ELSE status
        END
    WHERE id = NEW.cuota_id;

    INSERT INTO public.activities (
        organization_id, performed_by, activity_type,
        entity_type, entity_id, new_values, description
    ) VALUES (
        NEW.organization_id,
        auth.uid(),
        'payment_received',
        'payment',
        NEW.id,
        jsonb_build_object('amount', NEW.amount, 'currency', NEW.currency, 'method', NEW.payment_method),
        format('Pago de %s %s registrado', NEW.amount, NEW.currency)
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_update_cuota_on_payment
    AFTER INSERT ON public.payments
    FOR EACH ROW EXECUTE FUNCTION public.fn_update_cuota_on_payment();

-- ============================================================
-- STORED PROCEDURE: Mark overdue cuotas (called daily via n8n cron)
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_mark_overdue_cuotas()
RETURNS INTEGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    WITH updated AS (
        UPDATE public.cuotas
        SET status = 'overdue'
        WHERE status = 'pending'
          AND due_date < CURRENT_DATE
          AND amount_paid = 0
        RETURNING id, organization_id, contact_id, sale_id, installment_number
    )
    INSERT INTO public.notifications (
        organization_id, recipient_profile_id, notification_type,
        channel, title, body, entity_type, entity_id
    )
    SELECT DISTINCT
        u.organization_id,
        s.agent_id,
        'payment_overdue',
        'in_app',
        'Cuota vencida',
        format('Cuota #%s vencida', u.installment_number),
        'cuota',
        u.id
    FROM updated u
    JOIN public.sales s ON s.id = u.sale_id
    WHERE s.agent_id IS NOT NULL;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$;

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
