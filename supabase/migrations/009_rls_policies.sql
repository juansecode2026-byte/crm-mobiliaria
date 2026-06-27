-- ============================================================
-- MIGRATION 009: Row Level Security Policies
-- ============================================================

-- Enable RLS on all public tables
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunity_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.amortization_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.amortization_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cuotas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.integrations ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- organizations
-- ============================================================
CREATE POLICY pol_org_select ON public.organizations
    FOR SELECT TO authenticated
    USING (id = public.fn_current_organization_id());

CREATE POLICY pol_org_update ON public.organizations
    FOR UPDATE TO authenticated
    USING (id = public.fn_current_organization_id() AND public.fn_current_role() = 'admin')
    WITH CHECK (id = public.fn_current_organization_id() AND public.fn_current_role() = 'admin');

-- ============================================================
-- profiles
-- ============================================================
CREATE POLICY pol_profiles_select ON public.profiles
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_current_role() != 'buyer'
            OR id = auth.uid()
        )
    );

CREATE POLICY pol_profiles_insert ON public.profiles
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    );

CREATE POLICY pol_profiles_update ON public.profiles
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (id = auth.uid() OR public.fn_current_role() = 'admin')
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ============================================================
-- contacts
-- ============================================================
CREATE POLICY pol_contacts_select ON public.contacts
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = auth.uid())
        )
    );

CREATE POLICY pol_contacts_insert ON public.contacts
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_contacts_update ON public.contacts
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = auth.uid())
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ============================================================
-- properties
-- ============================================================
CREATE POLICY pol_properties_select ON public.properties
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = auth.uid())
        )
    );

CREATE POLICY pol_properties_insert ON public.properties
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_properties_update ON public.properties
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = auth.uid())
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

CREATE POLICY pol_property_images_all ON public.property_images
    FOR ALL TO authenticated
    USING (organization_id = public.fn_current_organization_id());

CREATE POLICY pol_property_features_all ON public.property_features
    FOR ALL TO authenticated
    USING (organization_id = public.fn_current_organization_id());

-- ============================================================
-- opportunities
-- ============================================================
CREATE POLICY pol_opportunities_select ON public.opportunities
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = auth.uid())
        )
    );

CREATE POLICY pol_opportunities_insert ON public.opportunities
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_opportunities_update ON public.opportunities
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = auth.uid())
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

CREATE POLICY pol_opp_activities_all ON public.opportunity_activities
    FOR ALL TO authenticated
    USING (organization_id = public.fn_current_organization_id());

-- ============================================================
-- sales
-- ============================================================
CREATE POLICY pol_sales_select ON public.sales
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() != 'buyer'
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = auth.uid())
        )
    );

CREATE POLICY pol_sales_insert ON public.sales
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_sales_update ON public.sales
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ============================================================
-- amortization_schedules and lines
-- ============================================================
CREATE POLICY pol_amort_schedule_select ON public.amortization_schedules
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() != 'buyer'
    );

CREATE POLICY pol_amort_schedule_insert ON public.amortization_schedules
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    );

CREATE POLICY pol_amort_lines_select ON public.amortization_lines
    FOR SELECT TO authenticated
    USING (organization_id = public.fn_current_organization_id());

-- ============================================================
-- cuotas — THE DIFFERENTIATOR
-- ============================================================
CREATE POLICY pol_cuotas_select ON public.cuotas
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (
                public.fn_current_role() = 'agent'
                AND EXISTS (
                    SELECT 1 FROM public.sales s
                    WHERE s.id = cuotas.sale_id AND s.agent_id = auth.uid()
                )
            )
            OR (
                public.fn_current_role() = 'buyer'
                AND contact_id = public.fn_current_contact_id()
            )
        )
    );

CREATE POLICY pol_cuotas_insert ON public.cuotas
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_cuotas_update ON public.cuotas
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ============================================================
-- payments
-- ============================================================
CREATE POLICY pol_payments_select ON public.payments
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND received_by = auth.uid())
            OR (public.fn_current_role() = 'buyer' AND contact_id = public.fn_current_contact_id())
        )
    );

CREATE POLICY pol_payments_insert ON public.payments
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

-- ============================================================
-- documents
-- ============================================================
CREATE POLICY pol_documents_select ON public.documents
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_current_role() != 'buyer'
            OR (
                entity_type = 'cuota'
                AND EXISTS (
                    SELECT 1 FROM public.cuotas c
                    WHERE c.id = documents.entity_id
                    AND c.contact_id = public.fn_current_contact_id()
                )
            )
            OR (
                entity_type = 'payment'
                AND EXISTS (
                    SELECT 1 FROM public.payments p
                    WHERE p.id = documents.entity_id
                    AND p.contact_id = public.fn_current_contact_id()
                )
            )
        )
    );

CREATE POLICY pol_documents_insert ON public.documents
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

-- ============================================================
-- activities (audit log)
-- ============================================================
CREATE POLICY pol_activities_select ON public.activities
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() != 'buyer'
    );

CREATE POLICY pol_activities_insert ON public.activities
    FOR INSERT TO authenticated
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ============================================================
-- notifications
-- ============================================================
CREATE POLICY pol_notifications_select ON public.notifications
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND recipient_profile_id = auth.uid()
    );

CREATE POLICY pol_notifications_update ON public.notifications
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND recipient_profile_id = auth.uid()
    )
    WITH CHECK (recipient_profile_id = auth.uid());

-- ============================================================
-- integrations
-- ============================================================
CREATE POLICY pol_integrations_all ON public.integrations
    FOR ALL TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() = 'admin'
    );
