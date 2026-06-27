-- ============================================================
-- MIGRATION 006: Payments and Documents
-- ============================================================

-- ============================================================
-- PAYMENTS
-- ============================================================
CREATE TABLE public.payments (
    id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id             UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    cuota_id                    UUID NOT NULL REFERENCES public.cuotas(id) ON DELETE RESTRICT,
    sale_id                     UUID NOT NULL REFERENCES public.sales(id) ON DELETE RESTRICT,
    contact_id                  UUID NOT NULL REFERENCES public.contacts(id) ON DELETE RESTRICT,
    received_by                 UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    amount                      NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    currency                    public.currency_code NOT NULL,
    payment_date                DATE NOT NULL,
    payment_method              public.payment_method NOT NULL DEFAULT 'cash',
    reference_number            TEXT,
    exchange_rate               NUMERIC(12,6),
    amount_in_base_currency     NUMERIC(15,2),
    notes                       TEXT,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_org ON public.payments (organization_id);
CREATE INDEX idx_payments_cuota ON public.payments (cuota_id);
CREATE INDEX idx_payments_sale ON public.payments (sale_id);
CREATE INDEX idx_payments_contact ON public.payments (contact_id);
CREATE INDEX idx_payments_date ON public.payments (organization_id, payment_date DESC);
CREATE INDEX idx_payments_received_by ON public.payments (received_by);

-- ============================================================
-- DOCUMENTS (PDF metadata — files in Supabase Storage)
-- ============================================================
CREATE TABLE public.documents (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id         UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    document_type           public.document_type NOT NULL,
    entity_type             public.activity_entity_type NOT NULL,
    entity_id               UUID NOT NULL,
    storage_path            TEXT NOT NULL,
    filename                TEXT NOT NULL,
    file_size_bytes         INT,
    mime_type               TEXT NOT NULL DEFAULT 'application/pdf',
    is_public               BOOLEAN NOT NULL DEFAULT FALSE,
    signed_url              TEXT,
    signed_url_expires_at   TIMESTAMPTZ,
    generated_by            UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_documents_org ON public.documents (organization_id);
CREATE INDEX idx_documents_entity ON public.documents (entity_type, entity_id);
CREATE INDEX idx_documents_type ON public.documents (organization_id, document_type);
