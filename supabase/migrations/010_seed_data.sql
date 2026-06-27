-- ============================================================
-- MIGRATION 010: Seed Data (Demo Organization)
-- Run ONLY on development / staging. NEVER on production.
-- ============================================================

-- Demo organization
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

-- Note: profiles are created automatically via fn_handle_new_auth_user trigger
-- when users are invited through Supabase Auth.
-- To create seed users: use Supabase Dashboard > Authentication > Users
-- and set app_metadata: {"organization_id": "00000000-0000-0000-0000-000000000001", "role": "agent"}

-- Sample contacts
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

-- Sample properties
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

-- Sample opportunity (pipeline)
INSERT INTO public.opportunities (id, organization_id, contact_id, property_id, stage, title, offered_price, offered_currency)
VALUES
    ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
     '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001',
     'interesado', 'Juan García - Depto Palermo', 180000, 'USD'),

    ('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001',
     '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002',
     'negociando', 'María López - Casa Belgrano', 310000, 'USD');

-- Sample closed sale with financing
INSERT INTO public.sales (
    id, organization_id, opportunity_id, contact_id, property_id,
    sale_price, sale_currency, sale_date, has_financing,
    down_payment, down_payment_currency, financed_amount
)
VALUES (
    '40000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    NULL,
    '10000000-0000-0000-0000-000000000003',
    '20000000-0000-0000-0000-000000000003',
    150000, 'USD',
    '2026-01-15',
    TRUE,
    30000, 'USD',
    120000
);

-- Sample amortization schedule (French system, 12 installments)
INSERT INTO public.amortization_schedules (
    id, organization_id, sale_id, amortization_type,
    principal, interest_rate, total_installments, currency,
    start_date, total_principal, total_interest, total_amount, is_active
)
VALUES (
    '50000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000001',
    'fixed',
    120000, 0, 12, 'USD',
    '2026-02-15',
    120000, 0, 120000,
    TRUE
);

-- Sample amortization lines (12 equal installments of $10,000 USD)
INSERT INTO public.amortization_lines (schedule_id, organization_id, installment_number, due_date, principal_amount, total_amount, outstanding_balance, currency)
SELECT
    '50000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    n,
    ('2026-02-15'::DATE + ((n - 1) * INTERVAL '1 month'))::DATE,
    10000,
    10000,
    120000 - (n * 10000),
    'USD'
FROM generate_series(1, 12) AS n;
-- The trigger fn_create_cuota_from_amortization_line will auto-create the 12 cuotas
