-- ============================================================
-- MIGRATION 012: Appointments (Agenda y Visitas)
-- ============================================================

CREATE TYPE public.appointment_type AS ENUM (
    'visit',
    'call',
    'meeting',
    'task',
    'other'
);

CREATE TYPE public.appointment_status AS ENUM (
    'scheduled',
    'completed',
    'cancelled',
    'no_show'
);

-- ============================================================
-- APPOINTMENTS
-- ============================================================
CREATE TABLE public.appointments (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    agent_id            UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    contact_id          UUID REFERENCES public.contacts(id) ON DELETE SET NULL,
    property_id         UUID REFERENCES public.properties(id) ON DELETE SET NULL,
    operation_id        UUID REFERENCES public.operations(id) ON DELETE SET NULL,
    appointment_type    public.appointment_type NOT NULL DEFAULT 'visit',
    title               TEXT NOT NULL,
    notes               TEXT,
    scheduled_at        TIMESTAMPTZ NOT NULL,
    duration_minutes    SMALLINT NOT NULL DEFAULT 60,
    location            TEXT,
    status              public.appointment_status NOT NULL DEFAULT 'scheduled',
    completed_notes     TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_appointments_org ON public.appointments (organization_id);
CREATE INDEX idx_appointments_agent ON public.appointments (agent_id, scheduled_at);
CREATE INDEX idx_appointments_contact ON public.appointments (contact_id) WHERE contact_id IS NOT NULL;
CREATE INDEX idx_appointments_status ON public.appointments (organization_id, status, scheduled_at);
CREATE INDEX idx_appointments_property ON public.appointments (property_id) WHERE property_id IS NOT NULL;

-- Trigger updated_at
CREATE TRIGGER trg_set_updated_at_appointments
    BEFORE UPDATE ON public.appointments
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- RLS
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

CREATE POLICY pol_appointments_select ON public.appointments
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = auth.uid())
        )
    );

CREATE POLICY pol_appointments_insert ON public.appointments
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_appointments_update ON public.appointments
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = auth.uid())
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

CREATE POLICY pol_appointments_delete ON public.appointments
    FOR DELETE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = auth.uid())
        )
    );
