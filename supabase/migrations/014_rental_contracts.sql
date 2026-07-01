-- ============================================================
-- MIGRATION 014: Rental Contracts (Contratos de Alquiler)
-- ============================================================

CREATE TYPE public.rental_status AS ENUM (
    'active',
    'expired',
    'terminated',
    'renewed'
);

CREATE TYPE public.adjustment_index AS ENUM (
    'ICL',
    'IPC',
    'UVA',
    'fixed',
    'other'
);

CREATE TYPE public.rental_payment_status AS ENUM (
    'pending',
    'paid',
    'partial',
    'overdue'
);

-- ============================================================
-- RENTAL CONTRACTS
-- ============================================================
CREATE TABLE public.rental_contracts (
    id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id             UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    property_id                 UUID NOT NULL REFERENCES public.properties(id) ON DELETE RESTRICT,
    tenant_contact_id           UUID NOT NULL REFERENCES public.contacts(id) ON DELETE RESTRICT,
    owner_contact_id            UUID REFERENCES public.contacts(id) ON DELETE SET NULL,
    agent_id                    UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    start_date                  DATE NOT NULL,
    end_date                    DATE NOT NULL,
    monthly_amount              NUMERIC(15,2) NOT NULL,
    currency                    public.currency_code NOT NULL,
    deposit_amount              NUMERIC(15,2),
    deposit_currency            public.currency_code,
    adjustment_index            public.adjustment_index NOT NULL DEFAULT 'ICL',
    adjustment_frequency_months SMALLINT NOT NULL DEFAULT 12,
    status                      public.rental_status NOT NULL DEFAULT 'active',
    termination_date            DATE,
    termination_reason          TEXT,
    notes                       TEXT,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rental_contracts_org ON public.rental_contracts (organization_id);
CREATE INDEX idx_rental_contracts_property ON public.rental_contracts (property_id);
CREATE INDEX idx_rental_contracts_tenant ON public.rental_contracts (tenant_contact_id);
CREATE INDEX idx_rental_contracts_status ON public.rental_contracts (organization_id, status);
CREATE INDEX idx_rental_contracts_agent ON public.rental_contracts (agent_id) WHERE agent_id IS NOT NULL;

-- ============================================================
-- RENTAL PAYMENTS (cuotas mensuales de alquiler)
-- ============================================================
CREATE TABLE public.rental_payments (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id         UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    rental_contract_id      UUID NOT NULL REFERENCES public.rental_contracts(id) ON DELETE RESTRICT,
    contact_id              UUID NOT NULL REFERENCES public.contacts(id) ON DELETE RESTRICT,
    period_month            DATE NOT NULL,
    amount_due              NUMERIC(15,2) NOT NULL,
    amount_paid             NUMERIC(15,2) NOT NULL DEFAULT 0,
    currency                public.currency_code NOT NULL,
    status                  public.rental_payment_status NOT NULL DEFAULT 'pending',
    payment_date            DATE,
    payment_method          public.payment_method,
    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_rental_payment_period UNIQUE (rental_contract_id, period_month)
);

CREATE INDEX idx_rental_payments_contract ON public.rental_payments (rental_contract_id);
CREATE INDEX idx_rental_payments_status ON public.rental_payments (organization_id, status, period_month);
CREATE INDEX idx_rental_payments_contact ON public.rental_payments (contact_id);

-- Triggers updated_at
CREATE TRIGGER trg_set_updated_at_rental_contracts
    BEFORE UPDATE ON public.rental_contracts
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

CREATE TRIGGER trg_set_updated_at_rental_payments
    BEFORE UPDATE ON public.rental_payments
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- RLS
ALTER TABLE public.rental_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rental_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY pol_rental_contracts_select ON public.rental_contracts
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = auth.uid())
            OR (public.fn_current_role() = 'buyer' AND tenant_contact_id = public.fn_current_contact_id())
        )
    );

CREATE POLICY pol_rental_contracts_insert ON public.rental_contracts
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_rental_contracts_update ON public.rental_contracts
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

CREATE POLICY pol_rental_payments_select ON public.rental_payments
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'buyer' AND contact_id = public.fn_current_contact_id())
        )
    );

CREATE POLICY pol_rental_payments_insert ON public.rental_payments
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_rental_payments_update ON public.rental_payments
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());
