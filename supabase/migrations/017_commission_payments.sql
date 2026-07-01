-- ============================================================
-- MIGRATION 017: Commission Payments (Liquidación de Comisiones)
-- Tracks if/when commissions were actually paid to each agent
-- ============================================================

CREATE TYPE public.commission_role AS ENUM (
    'seller',
    'capturer',
    'co_seller',
    'referrer'
);

CREATE TYPE public.commission_status AS ENUM (
    'pending',
    'paid',
    'cancelled'
);

-- ============================================================
-- COMMISSION PAYMENTS
-- ============================================================
CREATE TABLE public.commission_payments (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    sale_id             UUID NOT NULL REFERENCES public.sales(id) ON DELETE RESTRICT,
    agent_id            UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    role                public.commission_role NOT NULL DEFAULT 'seller',
    percentage          NUMERIC(5,2) NOT NULL,
    amount              NUMERIC(15,2) NOT NULL,
    currency            public.currency_code NOT NULL,
    status              public.commission_status NOT NULL DEFAULT 'pending',
    paid_at             TIMESTAMPTZ,
    payment_method      public.payment_method,
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_commission_payments_org ON public.commission_payments (organization_id);
CREATE INDEX idx_commission_payments_sale ON public.commission_payments (sale_id);
CREATE INDEX idx_commission_payments_agent ON public.commission_payments (agent_id, status);
CREATE INDEX idx_commission_payments_status ON public.commission_payments (organization_id, status);

-- Trigger updated_at
CREATE TRIGGER trg_set_updated_at_commission_payments
    BEFORE UPDATE ON public.commission_payments
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- RLS
ALTER TABLE public.commission_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY pol_commission_select ON public.commission_payments
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = auth.uid())
        )
    );

CREATE POLICY pol_commission_insert ON public.commission_payments
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    );

CREATE POLICY pol_commission_update ON public.commission_payments
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());
