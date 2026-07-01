-- ============================================================
-- MIGRATION 010: Seed Data (Organización Demo)
-- Ejecutar SOLO en desarrollo / staging. NUNCA en producción.
-- ============================================================

-- Organización demo
INSERT INTO public.organizations (id, name, slug, legal_name, tax_id, country_code, timezone, currency, plan)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Inmobiliaria Demo SA',
    'inmo-demo',
    'Inmobiliaria Demo Sociedad Anónima',
    '30-12345678-9',
    'AR',
    'America/Argentina/Buenos_Aires',
    'ARS',
    'pro'
);

-- Nota: los perfiles se crean automáticamente via trigger fn_handle_new_auth_user
-- al invitar usuarios desde Supabase Auth.
-- Para crear usuarios demo: Supabase Dashboard → Authentication → Users
-- app_metadata: {"organization_id": "00000000-0000-0000-0000-000000000001", "role": "agent"}

-- Contactos de muestra
INSERT INTO public.contacts (id, organization_id, first_name, last_name, email, phone, contact_type, lead_source, city, province, tags)
VALUES
    ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
     'Juan', 'García', 'juan.garcia@email.com', '+54 11 1234-5678', 'lead', 'zonaprop', 'Buenos Aires', 'CABA', ARRAY['inversor']),
    ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001',
     'María', 'López', 'maria.lopez@email.com', '+54 11 8765-4321', 'prospect', 'facebook_ads', 'Buenos Aires', 'CABA', ARRAY['urgente', 'familia']),
    ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001',
     'Carlos', 'Rodríguez', 'carlos.rodriguez@email.com', '+54 11 5555-0001', 'buyer', 'referral', 'Córdoba', 'Córdoba', ARRAY[]),
    ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001',
     'Ana', 'Martínez', 'ana.martinez@email.com', '+54 11 5555-0002', 'owner', 'direct', 'Buenos Aires', 'CABA', ARRAY['propietario']);

-- Propiedades de muestra
INSERT INTO public.properties (
    id, organization_id, internal_code, title, description,
    property_type, operation_type, status, price, currency,
    address, city, province, country_code, neighborhood,
    total_area_m2, covered_area_m2, rooms, bedrooms, bathrooms
)
VALUES
    ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
     'APT-001', 'Departamento 3 ambientes en Palermo',
     'Luminoso departamento con vista al parque. Piso 8 con balcón corrido.',
     'apartment', 'sale', 'available', 185000, 'USD',
     'Av. Santa Fe 3100', 'Buenos Aires', 'CABA', 'AR', 'Palermo',
     85, 78, 3, 2, 1),

    ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001',
     'CASA-001', 'Casa 4 ambientes en Belgrano',
     'Casa con jardín y quincho. Ideal para familia.',
     'house', 'sale', 'available', 320000, 'USD',
     'Av. Cabildo 2500', 'Buenos Aires', 'CABA', 'AR', 'Belgrano',
     200, 180, 4, 3, 2),

    ('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001',
     'APT-002', 'Departamento 2 ambientes en Villa Urquiza',
     'Moderno departamento a estrenar. Cocina integrada.',
     'apartment', 'rent', 'available', 150000, 'ARS',
     'Av. Forest 1200', 'Buenos Aires', 'CABA', 'AR', 'Villa Urquiza',
     52, 50, 2, 1, 1);

-- Operaciones de muestra (pipeline)
INSERT INTO public.operations (id, organization_id, contact_id, property_id, stage, title, offered_price, offered_currency)
VALUES
    ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
     '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
     'interesado', 'Juan García - Depto Palermo', 180000, 'USD'),

    ('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001',
     '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002',
     'negociando', 'María López - Casa Belgrano', 310000, 'USD'),

    -- Operación cerrada (vendido)
    ('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001',
     '10000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000003',
     'vendido', 'Carlos Rodríguez - Depto Villa Urquiza',
     150000, 'USD');

-- Cerrar la operación con datos de venta
UPDATE public.operations
SET
    closed_price = 148000,
    closed_currency = 'USD',
    closed_date = '2026-01-15',
    commission_rate = 3.00,
    commission_amount = 4440,
    commission_currency = 'USD'
WHERE id = '30000000-0000-0000-0000-000000000003';
