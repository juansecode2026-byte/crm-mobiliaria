-- ============================================================
-- MIGRATION 015: Contact Search Criteria (Criterios de Búsqueda)
-- Stores what each buyer is looking for — enables automatic matching
-- ============================================================

CREATE TABLE public.contact_search_criteria (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    contact_id          UUID NOT NULL REFERENCES public.contacts(id) ON DELETE CASCADE,
    operation_type      public.operation_type NOT NULL DEFAULT 'sale',
    property_types      public.property_type[] DEFAULT '{}',
    min_price           NUMERIC(15,2),
    max_price           NUMERIC(15,2),
    currency            public.currency_code DEFAULT 'USD',
    min_area_m2         NUMERIC(8,2),
    max_area_m2         NUMERIC(8,2),
    min_rooms           SMALLINT,
    max_rooms           SMALLINT,
    min_bedrooms        SMALLINT,
    cities              TEXT[] DEFAULT '{}',
    neighborhoods       TEXT[] DEFAULT '{}',
    provinces           TEXT[] DEFAULT '{}',
    features            TEXT[] DEFAULT '{}',
    notes               TEXT,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_search_criteria_contact ON public.contact_search_criteria (contact_id) WHERE is_active = TRUE;
CREATE INDEX idx_search_criteria_org ON public.contact_search_criteria (organization_id) WHERE is_active = TRUE;
CREATE INDEX idx_search_criteria_operation ON public.contact_search_criteria (organization_id, operation_type) WHERE is_active = TRUE;

-- Trigger updated_at
CREATE TRIGGER trg_set_updated_at_search_criteria
    BEFORE UPDATE ON public.contact_search_criteria
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- RLS
ALTER TABLE public.contact_search_criteria ENABLE ROW LEVEL SECURITY;

CREATE POLICY pol_search_criteria_select ON public.contact_search_criteria
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND EXISTS (
                SELECT 1 FROM public.contacts c
                WHERE c.id = contact_search_criteria.contact_id
                AND c.assigned_agent_id = auth.uid()
            ))
            OR (public.fn_current_role() = 'buyer' AND contact_id = public.fn_current_contact_id())
        )
    );

CREATE POLICY pol_search_criteria_insert ON public.contact_search_criteria
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_search_criteria_update ON public.contact_search_criteria
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND EXISTS (
                SELECT 1 FROM public.contacts c
                WHERE c.id = contact_search_criteria.contact_id
                AND c.assigned_agent_id = auth.uid()
            ))
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());
