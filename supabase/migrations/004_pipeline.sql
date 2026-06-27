-- ============================================================
-- MIGRATION 004: Pipeline (Opportunities + Activities)
-- ============================================================

CREATE TABLE public.opportunities (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    contact_id          UUID NOT NULL REFERENCES public.contacts(id) ON DELETE RESTRICT,
    property_id         UUID REFERENCES public.properties(id) ON DELETE SET NULL,
    assigned_agent_id   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    stage               public.pipeline_stage NOT NULL DEFAULT 'prospecto',
    stage_changed_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    offered_price       NUMERIC(15,2),
    offered_currency    public.currency_code,
    expected_close_date DATE,
    title               TEXT,
    notes               TEXT,
    lost_reason         TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_opportunities_org ON public.opportunities (organization_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_opportunities_stage ON public.opportunities (organization_id, stage) WHERE deleted_at IS NULL;
CREATE INDEX idx_opportunities_agent ON public.opportunities (organization_id, assigned_agent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_opportunities_contact ON public.opportunities (contact_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_opportunities_property ON public.opportunities (property_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_opportunities_kanban ON public.opportunities (organization_id, stage, stage_changed_at DESC) WHERE deleted_at IS NULL;

-- ============================================================
-- OPPORTUNITY ACTIVITIES (user-created CRM log per opportunity)
-- ============================================================
CREATE TABLE public.opportunity_activities (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    opportunity_id      UUID NOT NULL REFERENCES public.opportunities(id) ON DELETE CASCADE,
    performed_by        UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    activity_type       public.activity_type NOT NULL,
    description         TEXT NOT NULL,
    activity_date       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata            JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_opp_activities_opportunity ON public.opportunity_activities (opportunity_id, activity_date DESC);
CREATE INDEX idx_opp_activities_org ON public.opportunity_activities (organization_id, activity_date DESC);
