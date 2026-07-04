-- ============================================================
-- MIGRATION 022: Business Constraints & Remaining Fixes
--
-- PARTE 1 — Revocar acceso público a rls_auto_enable()
-- PARTE 2 — Policy UPDATE en payments (admin/manager only)
-- PARTE 3 — Índices trigram adicionales (address, developments)
-- PARTE 4 — CHECK constraints: fechas, precios, rangos
-- ============================================================

-- ============================================================
-- PARTE 1: REVOKE rls_auto_enable()
-- Función de utilidad interna — nadie externo debería invocarla
-- ============================================================
REVOKE ALL ON FUNCTION public.rls_auto_enable() FROM PUBLIC;

-- ============================================================
-- PARTE 2: UPDATE policy en payments
-- Pagos son inmutables por diseño, pero admin/manager pueden
-- corregir errores de carga. Sin DELETE (el registro queda).
-- ============================================================
CREATE POLICY pol_payments_update ON public.payments
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

-- ============================================================
-- PARTE 3: Índices trigram adicionales
-- Buscar por dirección en propiedades y nombre de desarrollo.
-- (search_path ya incluye extensions desde migración 020)
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_properties_address_trgm
    ON public.properties USING GIN (unaccent(address) gin_trgm_ops)
    WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_developments_name_trgm
    ON public.developments USING GIN (unaccent(name) gin_trgm_ops)
    WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_contacts_email_trgm
    ON public.contacts USING GIN (email gin_trgm_ops)
    WHERE deleted_at IS NULL AND email IS NOT NULL;

-- ============================================================
-- PARTE 4: CHECK constraints
-- Red de seguridad ante fallos del frontend o llamadas directas
-- a la API. Las tablas tienen 0 filas → ALTER TABLE inmediato.
-- ============================================================

-- ---- properties ----
ALTER TABLE public.properties
    ADD CONSTRAINT chk_properties_price_positive
        CHECK (price > 0),
    ADD CONSTRAINT chk_properties_commission_rate
        CHECK (commission_rate IS NULL OR (commission_rate >= 0 AND commission_rate <= 100)),
    ADD CONSTRAINT chk_properties_total_area
        CHECK (total_area_m2 IS NULL OR total_area_m2 > 0),
    ADD CONSTRAINT chk_properties_covered_area
        CHECK (covered_area_m2 IS NULL OR covered_area_m2 > 0),
    ADD CONSTRAINT chk_properties_area_logic
        CHECK (covered_area_m2 IS NULL OR total_area_m2 IS NULL OR covered_area_m2 <= total_area_m2),
    ADD CONSTRAINT chk_properties_rooms
        CHECK (rooms IS NULL OR rooms >= 0),
    ADD CONSTRAINT chk_properties_bedrooms
        CHECK (bedrooms IS NULL OR bedrooms >= 0),
    ADD CONSTRAINT chk_properties_bathrooms
        CHECK (bathrooms IS NULL OR bathrooms >= 0);

-- ---- operations ----
ALTER TABLE public.operations
    ADD CONSTRAINT chk_operations_offered_price
        CHECK (offered_price IS NULL OR offered_price > 0),
    ADD CONSTRAINT chk_operations_closed_price
        CHECK (closed_price IS NULL OR closed_price > 0),
    ADD CONSTRAINT chk_operations_commission_rate
        CHECK (commission_rate IS NULL OR (commission_rate >= 0 AND commission_rate <= 100)),
    ADD CONSTRAINT chk_operations_commission_amount
        CHECK (commission_amount IS NULL OR commission_amount >= 0);

-- ---- rental_contracts ----
ALTER TABLE public.rental_contracts
    ADD CONSTRAINT chk_rental_dates
        CHECK (end_date > start_date),
    ADD CONSTRAINT chk_rental_monthly_amount
        CHECK (monthly_amount > 0),
    ADD CONSTRAINT chk_rental_deposit
        CHECK (deposit_amount IS NULL OR deposit_amount >= 0),
    ADD CONSTRAINT chk_rental_adjustment_freq
        CHECK (adjustment_frequency_months > 0);

-- ---- rental_payments ----
ALTER TABLE public.rental_payments
    ADD CONSTRAINT chk_rental_payment_due
        CHECK (amount_due > 0),
    ADD CONSTRAINT chk_rental_payment_paid
        CHECK (amount_paid >= 0);

-- ---- valuations ----
ALTER TABLE public.valuations
    ADD CONSTRAINT chk_valuation_estimated_value
        CHECK (estimated_value IS NULL OR estimated_value > 0);

-- ---- commission_payments ----
ALTER TABLE public.commission_payments
    ADD CONSTRAINT chk_commission_percentage
        CHECK (percentage >= 0 AND percentage <= 100),
    ADD CONSTRAINT chk_commission_amount
        CHECK (amount > 0);

-- ---- contacts ----
-- GDPR: si hay consentimiento, debe tener fecha
ALTER TABLE public.contacts
    ADD CONSTRAINT chk_contacts_gdpr_date
        CHECK (NOT gdpr_consent OR gdpr_consent_at IS NOT NULL);

-- ---- appointments ----
ALTER TABLE public.appointments
    ADD CONSTRAINT chk_appointment_duration
        CHECK (duration_minutes > 0);

-- ---- developments ----
ALTER TABLE public.developments
    ADD CONSTRAINT chk_development_units
        CHECK (total_units >= 0 AND available_units >= 0),
    ADD CONSTRAINT chk_development_available_le_total
        CHECK (available_units <= total_units);
