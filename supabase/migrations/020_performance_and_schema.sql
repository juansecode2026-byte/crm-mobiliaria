-- ============================================================
-- MIGRATION 020: Performance & Schema Hardening
--
-- PARTE 1 — Extensions
--   Mueve pg_trgm / unaccent / btree_gin de public al schema
--   extensions. Los índices GIN existentes funcionan igual
--   (referencian por OID). Se actualiza search_path a nivel
--   DB y roles para que código futuro los resuelva.
--
-- PARTE 2 — FK indexes faltantes (12)
--   FK columns que o no tenían índice o sólo estaban cubiertas
--   por un índice compuesto partial (inútil para FK enforcement).
--
-- PARTE 3 — RLS: auth.uid() → (SELECT auth.uid())
--   Convierte auth.uid() directo en un InitPlan que PostgreSQL
--   evalúa UNA sola vez por statement, no por fila.
--   Impacto real en tablas con muchas filas.
-- ============================================================

-- ============================================================
-- PARTE 1: Extensions
-- ============================================================
ALTER EXTENSION pg_trgm   SET SCHEMA extensions;
ALTER EXTENSION unaccent  SET SCHEMA extensions;
ALTER EXTENSION btree_gin SET SCHEMA extensions;

-- Asegurar que todas las conexiones resuelvan extensions schema
-- (PostgREST usa search_path del rol authenticated)
ALTER DATABASE postgres  SET search_path TO "$user", public, extensions;
ALTER ROLE authenticated SET search_path TO "$user", public, extensions;
ALTER ROLE anon          SET search_path TO "$user", public, extensions;
ALTER ROLE service_role  SET search_path TO "$user", public, extensions;

-- ============================================================
-- PARTE 2: FK indexes faltantes
-- ============================================================

-- properties.owner_contact_id (sin índice)
CREATE INDEX IF NOT EXISTS idx_properties_owner_contact
    ON public.properties (owner_contact_id)
    WHERE owner_contact_id IS NOT NULL;

-- properties.assigned_agent_id — el índice compuesto (org, agent) WHERE deleted_at IS NULL
-- no es útil para FK enforcement (busca ALL rows, no solo non-deleted)
CREATE INDEX IF NOT EXISTS idx_properties_assigned_agent_fk
    ON public.properties (assigned_agent_id)
    WHERE assigned_agent_id IS NOT NULL;

-- contacts.assigned_agent_id — mismo caso: composite partial insuficiente
CREATE INDEX IF NOT EXISTS idx_contacts_assigned_agent_fk
    ON public.contacts (assigned_agent_id)
    WHERE assigned_agent_id IS NOT NULL;

-- operations.assigned_agent_id — mismo caso
CREATE INDEX IF NOT EXISTS idx_operations_assigned_agent_fk
    ON public.operations (assigned_agent_id)
    WHERE assigned_agent_id IS NOT NULL;

-- operation_activities.performed_by (sin índice)
CREATE INDEX IF NOT EXISTS idx_op_activities_performed_by
    ON public.operation_activities (performed_by)
    WHERE performed_by IS NOT NULL;

-- payments.received_by (sin índice)
CREATE INDEX IF NOT EXISTS idx_payments_received_by
    ON public.payments (received_by)
    WHERE received_by IS NOT NULL;

-- documents.generated_by (sin índice)
CREATE INDEX IF NOT EXISTS idx_documents_generated_by
    ON public.documents (generated_by)
    WHERE generated_by IS NOT NULL;

-- developments.developer_contact_id (sin índice)
CREATE INDEX IF NOT EXISTS idx_developments_developer_contact
    ON public.developments (developer_contact_id)
    WHERE developer_contact_id IS NOT NULL;

-- appointments.operation_id (sin índice)
CREATE INDEX IF NOT EXISTS idx_appointments_operation
    ON public.appointments (operation_id)
    WHERE operation_id IS NOT NULL;

-- valuations.property_id (sin índice)
CREATE INDEX IF NOT EXISTS idx_valuations_property
    ON public.valuations (property_id)
    WHERE property_id IS NOT NULL;

-- rental_contracts.owner_contact_id (sin índice)
CREATE INDEX IF NOT EXISTS idx_rental_contracts_owner_contact
    ON public.rental_contracts (owner_contact_id)
    WHERE owner_contact_id IS NOT NULL;

-- message_templates.created_by (sin índice)
CREATE INDEX IF NOT EXISTS idx_message_templates_created_by
    ON public.message_templates (created_by)
    WHERE created_by IS NOT NULL;

-- ============================================================
-- PARTE 3: RLS — auth.uid() → (SELECT auth.uid())
-- ============================================================

-- ---- profiles ----
DROP POLICY IF EXISTS pol_profiles_select ON public.profiles;
DROP POLICY IF EXISTS pol_profiles_update ON public.profiles;

CREATE POLICY pol_profiles_select ON public.profiles
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_current_role() != 'buyer'
            OR id = (SELECT auth.uid())
        )
    );

CREATE POLICY pol_profiles_update ON public.profiles
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (id = (SELECT auth.uid()) OR public.fn_current_role() = 'admin')
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ---- contacts ----
DROP POLICY IF EXISTS pol_contacts_select ON public.contacts;
DROP POLICY IF EXISTS pol_contacts_update ON public.contacts;

CREATE POLICY pol_contacts_select ON public.contacts
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = (SELECT auth.uid()))
        )
    );

CREATE POLICY pol_contacts_update ON public.contacts
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = (SELECT auth.uid()))
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ---- properties ----
DROP POLICY IF EXISTS pol_properties_select ON public.properties;
DROP POLICY IF EXISTS pol_properties_update ON public.properties;

CREATE POLICY pol_properties_select ON public.properties
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = (SELECT auth.uid()))
        )
    );

CREATE POLICY pol_properties_update ON public.properties
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = (SELECT auth.uid()))
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ---- operations ----
DROP POLICY IF EXISTS pol_operations_select ON public.operations;
DROP POLICY IF EXISTS pol_operations_update ON public.operations;

CREATE POLICY pol_operations_select ON public.operations
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = (SELECT auth.uid()))
        )
    );

CREATE POLICY pol_operations_update ON public.operations
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND assigned_agent_id = (SELECT auth.uid()))
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ---- payments ----
DROP POLICY IF EXISTS pol_payments_select ON public.payments;

CREATE POLICY pol_payments_select ON public.payments
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND received_by = (SELECT auth.uid()))
        )
    );

-- ---- notifications ----
DROP POLICY IF EXISTS pol_notifications_select ON public.notifications;
DROP POLICY IF EXISTS pol_notifications_update ON public.notifications;

CREATE POLICY pol_notifications_select ON public.notifications
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND recipient_profile_id = (SELECT auth.uid())
    );

CREATE POLICY pol_notifications_update ON public.notifications
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND recipient_profile_id = (SELECT auth.uid())
    )
    WITH CHECK (recipient_profile_id = (SELECT auth.uid()));

-- ---- appointments ----
DROP POLICY IF EXISTS pol_appointments_select ON public.appointments;
DROP POLICY IF EXISTS pol_appointments_update ON public.appointments;
DROP POLICY IF EXISTS pol_appointments_delete ON public.appointments;

CREATE POLICY pol_appointments_select ON public.appointments
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = (SELECT auth.uid()))
        )
    );

CREATE POLICY pol_appointments_update ON public.appointments
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = (SELECT auth.uid()))
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

CREATE POLICY pol_appointments_delete ON public.appointments
    FOR DELETE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = (SELECT auth.uid()))
        )
    );

-- ---- valuations ----
DROP POLICY IF EXISTS pol_valuations_select ON public.valuations;
DROP POLICY IF EXISTS pol_valuations_update ON public.valuations;

CREATE POLICY pol_valuations_select ON public.valuations
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() != 'buyer'
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = (SELECT auth.uid()))
        )
    );

CREATE POLICY pol_valuations_update ON public.valuations
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = (SELECT auth.uid()))
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ---- rental_contracts ----
DROP POLICY IF EXISTS pol_rental_contracts_select ON public.rental_contracts;

CREATE POLICY pol_rental_contracts_select ON public.rental_contracts
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = (SELECT auth.uid()))
            OR (public.fn_current_role() = 'buyer' AND tenant_contact_id = public.fn_current_contact_id())
        )
    );

-- ---- contact_search_criteria ----
DROP POLICY IF EXISTS pol_search_criteria_select ON public.contact_search_criteria;
DROP POLICY IF EXISTS pol_search_criteria_update ON public.contact_search_criteria;

CREATE POLICY pol_search_criteria_select ON public.contact_search_criteria
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND EXISTS (
                SELECT 1 FROM public.contacts c
                WHERE c.id = contact_search_criteria.contact_id
                  AND c.assigned_agent_id = (SELECT auth.uid())
            ))
            OR (public.fn_current_role() = 'buyer' AND contact_id = public.fn_current_contact_id())
        )
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
                  AND c.assigned_agent_id = (SELECT auth.uid())
            ))
        )
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ---- commission_payments ----
DROP POLICY IF EXISTS pol_commission_select ON public.commission_payments;

CREATE POLICY pol_commission_select ON public.commission_payments
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND (
            public.fn_is_admin_or_manager()
            OR (public.fn_current_role() = 'agent' AND agent_id = (SELECT auth.uid()))
        )
    );
