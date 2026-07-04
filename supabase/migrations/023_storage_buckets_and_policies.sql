-- ============================================================
-- MIGRATION 023: Storage — Buckets y RLS policies
--
-- Buckets:
--   property-images  → imágenes de propiedades (10 MB max, solo imágenes)
--   documents        → PDFs generados (50 MB max, solo PDF)
--
-- Path convention:
--   property-images: {organization_id}/{property_id}/{filename}
--   documents:       {organization_id}/{entity_type}/{entity_id}/{filename}
--
-- Acceso: multi-tenant por organization_id (primer segmento del path).
-- Usa (SELECT fn_*()) para evaluar una sola vez por statement.
-- ============================================================

-- ============================================================
-- Buckets
-- ============================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  (
    'property-images',
    'property-images',
    false,
    10485760,
    ARRAY['image/jpeg','image/jpg','image/png','image/webp','image/gif']
  ),
  (
    'documents',
    'documents',
    false,
    52428800,
    ARRAY['application/pdf']
  )
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- RLS — property-images
-- ============================================================
CREATE POLICY "prop_img_select" ON storage.objects
    FOR SELECT TO authenticated
    USING (
        bucket_id = 'property-images'
        AND (storage.foldername(name))[1] = (SELECT public.fn_current_organization_id())::text
    );

CREATE POLICY "prop_img_insert" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
        bucket_id = 'property-images'
        AND (storage.foldername(name))[1] = (SELECT public.fn_current_organization_id())::text
        AND (SELECT public.fn_current_role()) IN ('admin', 'manager', 'agent')
    );

CREATE POLICY "prop_img_update" ON storage.objects
    FOR UPDATE TO authenticated
    USING (
        bucket_id = 'property-images'
        AND (storage.foldername(name))[1] = (SELECT public.fn_current_organization_id())::text
        AND (SELECT public.fn_current_role()) IN ('admin', 'manager', 'agent')
    );

CREATE POLICY "prop_img_delete" ON storage.objects
    FOR DELETE TO authenticated
    USING (
        bucket_id = 'property-images'
        AND (storage.foldername(name))[1] = (SELECT public.fn_current_organization_id())::text
        AND (SELECT public.fn_is_admin_or_manager())
    );

-- ============================================================
-- RLS — documents
-- Lectura: todos los roles de la org excepto buyer.
-- Escritura: solo agent / manager / admin.
-- La granularidad fina (buyer ve solo sus docs) la controla
-- la policy en public.documents (migration 009).
-- ============================================================
CREATE POLICY "docs_select" ON storage.objects
    FOR SELECT TO authenticated
    USING (
        bucket_id = 'documents'
        AND (storage.foldername(name))[1] = (SELECT public.fn_current_organization_id())::text
        AND (SELECT public.fn_current_role()) != 'buyer'
    );

CREATE POLICY "docs_insert" ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
        bucket_id = 'documents'
        AND (storage.foldername(name))[1] = (SELECT public.fn_current_organization_id())::text
        AND (SELECT public.fn_current_role()) IN ('admin', 'manager', 'agent')
    );

CREATE POLICY "docs_delete" ON storage.objects
    FOR DELETE TO authenticated
    USING (
        bucket_id = 'documents'
        AND (storage.foldername(name))[1] = (SELECT public.fn_current_organization_id())::text
        AND (SELECT public.fn_is_admin_or_manager())
    );
