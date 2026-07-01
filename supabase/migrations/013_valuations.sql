-- ============================================================
-- MIGRATION 013: Valuations (Tasaciones)
-- ============================================================

CREATE TYPE public.valuation_status AS ENUM (
    'pending',    -- cargada, tasación pendiente
    'valued',     -- tasada, esperando respuesta del propietario
    'accepted',   -- propietario aceptó → propiedad ingresada al sistema
    'rejected'    -- propietario rechazó
);

-- ============================================================
-- VALUATIONS
-- ============================================================
CREATE TABLE public.valuations (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    agent_id            UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    contact_id          UUID NOT NULL REFERENCES public.contacts(id) ON DELETE RESTRICT,
    property_id         UUID REFERENCES public.properties(id) ON DELETE SET NULL,
    status              public.valuation_status NOT NULL DEFAULT 'pending',
    estimated_value     NUMERIC(15,2),
    currency            public.currency_code NOT NULL DEFAULT 'USD',
    valuation_date      DATE,
    owner_response_at   TIMESTAMPTZ,
    rejection_reason    TEXT,
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_valuations_org ON public.valuations (organization_id);
CREATE INDEX idx_valuations_agent ON public.valuations (agent_id) WHERE agent_id IS NOT NULL;
CREATE INDEX idx_valuations_contact ON public.valuations (contact_id);
CREATE INDEX idx_valuations_status ON public.valuations (organization_id, status);

-- Trigger updated_at
CREATE TRIGGER trg_set_updated_at_valuations
    BEFORE UPDATE ON public.valuations
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- RLS
ALTER TABLE public.valuations ENABLE ROW LEVEL SECURITY;

CREATE POLICY pol_valuations_select ON public.valuations
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() != 'buyer'
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = auth.uid())
        )
    );

CREATE POLICY pol_valuations_insert ON public.valuations
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_valuations_update ON public.valuations
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = auth.uid())
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());
