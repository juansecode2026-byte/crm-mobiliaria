import Link from 'next/link'
import Image from 'next/image'

const features = [
  {
    tag: 'Pipeline de operaciones',
    title: 'Seguimiento y gestión de clientes',
    description: 'Visualizá en qué etapa está cada negociación. Arrastrá operaciones de Prospecto a Cierre con un clic. Nunca más pierdas el hilo de un negocio.',
    cta: 'Ver más',
    ctaHref: '#',
    imageLeft: false,
    mockup: 'kanban',
  },
  {
    tag: 'Propiedades',
    title: 'Tu inventario siempre ordenado y publicado',
    description: 'Cargá propiedades una sola vez y publicá en todos los portales automáticamente. Fotos, planos, características y estado en un solo lugar.',
    cta: 'Ver más',
    ctaHref: '#',
    imageLeft: true,
    mockup: 'properties',
  },
  {
    tag: 'Portal del comprador',
    title: 'Tus clientes, siempre informados',
    description: 'El único CRM de LATAM con portal propio para compradores. Tus clientes ven sus cuotas, pagos y documentos desde el celular. Sin llamadas innecesarias.',
    cta: 'Ver más',
    ctaHref: '#',
    imageLeft: false,
    mockup: 'portal',
  },
]

const clientes = [
  'Bienes Raíces Del Valle',
  'Inmobiliaria Medellín',
  'Constructora Pacífico',
  'Grupo Inmobiliario Norte',
  'Propiedades Bogotá',
]

const stats = [
  { num: '+500', label: 'inmobiliarias activas' },
  { num: '8', label: 'países de LATAM' },
  { num: '12.000', label: 'operaciones cerradas' },
  { num: '99.9%', label: 'uptime garantizado' },
]

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-white text-gray-900">

      {/* ── NAVBAR ── */}
      <nav className="fixed top-0 inset-x-0 z-50 bg-white border-b border-gray-100">
        <div className="max-w-6xl mx-auto px-6 flex items-center justify-between h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center">
            <Image src="/logo.png" alt="CRM Mobiliaria" width={160} height={48} className="h-10 w-auto" priority />
          </Link>

          {/* Links centro */}
          <div className="hidden md:flex items-center gap-8">
            <Link href="#funcionalidades" className="text-sm text-gray-600 hover:text-gray-900 transition-colors">Funcionalidades</Link>
            <Link href="#precios" className="text-sm text-gray-600 hover:text-gray-900 transition-colors">Planes y precios</Link>
            <Link href="#integraciones" className="text-sm text-gray-600 hover:text-gray-900 transition-colors">Integraciones</Link>
            <Link href="#" className="text-sm text-gray-600 hover:text-gray-900 transition-colors">Blog</Link>
          </div>

          {/* Auth derecha */}
          <div className="flex items-center gap-4">
            <Link href="/login" className="text-sm text-gray-600 hover:text-gray-900 transition-colors">
              Ingresar
            </Link>
            <Link href="#precios" className="text-sm font-semibold bg-blue-700 text-white px-4 py-2 rounded-lg hover:bg-blue-800 transition-colors">
              Comenzar
            </Link>
          </div>
        </div>
      </nav>

      {/* ── HERO ── */}
      <section className="pt-28 pb-20 px-6">
        <div className="max-w-6xl mx-auto flex items-center gap-16">

          {/* Texto izquierda */}
          <div className="flex-1 max-w-xl">
            <div className="inline-flex items-center gap-2 bg-blue-50 text-blue-700 text-xs font-semibold px-3 py-1.5 rounded-full mb-6">
              <span className="w-1.5 h-1.5 bg-blue-500 rounded-full"></span>
              Nuevo en 2026 — Diseñado para Colombia y LATAM
            </div>
            <h1 className="text-4xl lg:text-5xl font-bold text-gray-900 leading-tight mb-5">
              Hacemos tu gestión
              <span className="text-blue-700"> más inteligente</span>
            </h1>
            <p className="text-lg text-gray-500 leading-relaxed mb-8">
              Queremos ser parte de tu equipo. Con las herramientas de CRM Mobiliaria logramos una comunicación más efectiva con tus prospectos, un seguimiento eficiente de tus operaciones y la publicación de tus propiedades en todos los portales del mercado.
            </p>
            <div className="flex items-center gap-4">
              <Link href="#precios" className="bg-blue-700 text-white px-6 py-3 rounded-lg font-semibold text-sm hover:bg-blue-800 transition-colors shadow-sm">
                ¡Probalo ahora!
              </Link>
              <Link href="#funcionalidades" className="text-sm text-gray-600 hover:text-gray-900 transition-colors flex items-center gap-1">
                Ver funcionalidades →
              </Link>
            </div>
          </div>

          {/* Ilustración/Mockup derecha */}
          <div className="flex-1 relative hidden lg:block">
            <div className="relative bg-gradient-to-br from-blue-50 to-blue-100 rounded-2xl p-6 shadow-lg">
              {/* Mini Dashboard mockup */}
              <div className="bg-white rounded-xl shadow-sm p-4 mb-3">
                <div className="flex items-center gap-2 mb-3">
                  <div className="w-2 h-2 rounded-full bg-blue-600"></div>
                  <span className="text-xs font-semibold text-gray-700">Pipeline — Julio 2026</span>
                  <div className="ml-auto text-xs text-gray-400">24 operaciones</div>
                </div>
                <div className="grid grid-cols-4 gap-2">
                  {[
                    { label: 'Prospecto', count: 7, color: 'bg-gray-100' },
                    { label: 'Interesado', count: 5, color: 'bg-blue-50' },
                    { label: 'Negociando', count: 4, color: 'bg-amber-50' },
                    { label: 'Cierre', count: 3, color: 'bg-green-50' },
                  ].map(({ label, count, color }) => (
                    <div key={label} className={`${color} rounded-lg p-2 text-center`}>
                      <div className="text-lg font-bold text-gray-800">{count}</div>
                      <div className="text-[10px] text-gray-500 font-medium">{label}</div>
                    </div>
                  ))}
                </div>
              </div>
              {/* Mini cards flotantes */}
              <div className="grid grid-cols-2 gap-2">
                <div className="bg-white rounded-lg p-3 shadow-sm">
                  <div className="text-xs text-gray-400 mb-1">Cierres del mes</div>
                  <div className="text-xl font-bold text-gray-900">6</div>
                  <div className="text-xs text-green-500 font-medium">▲ +2 vs anterior</div>
                </div>
                <div className="bg-white rounded-lg p-3 shadow-sm">
                  <div className="text-xs text-gray-400 mb-1">Propiedades</div>
                  <div className="text-xl font-bold text-gray-900">87</div>
                  <div className="text-xs text-blue-500 font-medium">+5 este mes</div>
                </div>
              </div>
              {/* Notificación flotante */}
              <div className="absolute -top-4 -right-4 bg-white rounded-xl shadow-lg p-3 flex items-center gap-2 border border-gray-100">
                <div className="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center text-sm">✅</div>
                <div>
                  <div className="text-xs font-semibold text-gray-800">Operación cerrada</div>
                  <div className="text-[10px] text-gray-400">USD 148.000 · hace 2h</div>
                </div>
              </div>
              {/* Badge flotante abajo */}
              <div className="absolute -bottom-4 -left-4 bg-blue-700 rounded-xl shadow-lg p-3 text-white">
                <div className="text-xs font-medium opacity-80">Leads captados hoy</div>
                <div className="text-xl font-bold">+12</div>
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* ── STATS ── */}
      <section className="py-10 border-y border-gray-100 bg-gray-50">
        <div className="max-w-4xl mx-auto px-6 flex flex-wrap justify-center gap-12">
          {stats.map(({ num, label }) => (
            <div key={label} className="text-center">
              <div className="text-3xl font-bold text-gray-900">{num}</div>
              <div className="text-sm text-gray-500 mt-1">{label}</div>
            </div>
          ))}
        </div>
      </section>

      {/* ── FEATURE SECTIONS ── */}
      <section id="funcionalidades" className="py-6">

        {/* Renová tu sitio web / Publicación en portales */}
        <div className="py-20 px-6">
          <div className="max-w-6xl mx-auto text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-3">Publicá en todos los portales</h2>
            <p className="text-gray-500 max-w-xl mx-auto">
              Te acompañamos en tu visibilidad digital. Publicá tus propiedades en Fincaraíz, Metrocuadrado y +10 portales desde un solo lugar. Los leads llegan directo al CRM.
            </p>
          </div>
          {/* Screenshot portales */}
          <div className="max-w-4xl mx-auto bg-gradient-to-br from-blue-50 to-gray-50 rounded-2xl p-8 border border-blue-100">
            <div className="bg-white rounded-xl shadow-sm p-5">
              <div className="flex items-center gap-3 pb-4 border-b border-gray-100 mb-4">
                <div className="w-8 h-8 bg-blue-700 rounded-lg flex items-center justify-center text-white text-xs font-bold">CR</div>
                <div>
                  <div className="text-sm font-semibold text-gray-800">APT-001 · Depto 3 amb. Palermo</div>
                  <div className="text-xs text-gray-400">USD 185.000 · 85m²</div>
                </div>
                <div className="ml-auto flex gap-2">
                  <span className="text-xs bg-green-100 text-green-700 font-semibold px-2 py-1 rounded-full">Disponible</span>
                  <span className="text-xs bg-blue-100 text-blue-700 font-semibold px-2 py-1 rounded-full">Publicada</span>
                </div>
              </div>
              <div className="text-xs text-gray-400 mb-3 font-medium uppercase tracking-wide">Publicada en</div>
              <div className="flex flex-wrap gap-2">
                {['Fincaraíz', 'Metrocuadrado', 'ZonaProp', 'Properati', 'MercadoLibre', 'Facebook Ads'].map(p => (
                  <span key={p} className="text-xs border border-gray-200 rounded-md px-3 py-1.5 text-gray-600 font-medium">{p}</span>
                ))}
              </div>
            </div>
          </div>
          <div className="flex flex-wrap justify-center gap-8 mt-8 text-sm text-gray-500">
            <div className="flex items-center gap-2"><span className="text-blue-600">→</span> Compatible con todo tipo de inmobiliaria</div>
            <div className="flex items-center gap-2"><span className="text-blue-600">→</span> 100% responsive para celulares</div>
            <div className="flex items-center gap-2"><span className="text-blue-600">→</span> Múltiples filtros de búsqueda</div>
            <div className="flex items-center gap-2"><span className="text-blue-600">→</span> Optimización SEO incluida</div>
          </div>
          <div className="text-center mt-8">
            <Link href="#" className="text-sm font-semibold border border-gray-300 text-gray-700 px-5 py-2.5 rounded-lg hover:bg-gray-50 transition-colors">
              Seguir explorando
            </Link>
          </div>
        </div>

        {/* Features alternadas */}
        {features.map(({ tag, title, description, cta, ctaHref, imageLeft, mockup }) => (
          <div key={tag} className={`py-20 px-6 ${imageLeft ? 'bg-gray-50' : 'bg-white'}`}>
            <div className={`max-w-6xl mx-auto flex items-center gap-16 ${imageLeft ? 'flex-row-reverse' : ''}`}>

              <div className="flex-1 max-w-lg">
                <div className="text-xs font-semibold text-blue-600 uppercase tracking-wider mb-3">{tag}</div>
                <h2 className="text-3xl font-bold text-gray-900 mb-4">{title}</h2>
                <p className="text-gray-500 leading-relaxed mb-6">{description}</p>
                <Link href={ctaHref} className="inline-flex items-center text-sm font-semibold text-blue-700 hover:text-blue-800 transition-colors">
                  {cta} →
                </Link>
              </div>

              <div className="flex-1 hidden lg:block">
                {mockup === 'kanban' && (
                  <div className="bg-white border border-gray-200 rounded-2xl shadow-sm p-5">
                    <div className="text-xs font-semibold text-gray-400 uppercase mb-3">Pipeline de Operaciones</div>
                    <div className="flex gap-3 overflow-hidden">
                      {[
                        { label: 'Prospecto', color: 'bg-gray-100 text-gray-600', cards: ['Roberto Silva · PH Recoleta', 'Ana Gómez · Casa Palermo'] },
                        { label: 'Interesado', color: 'bg-blue-100 text-blue-700', cards: ['Juan García · Depto Palermo'] },
                        { label: 'Negociando', color: 'bg-amber-100 text-amber-700', cards: ['María López · Casa Belgrano'] },
                        { label: 'Cierre', color: 'bg-green-100 text-green-700', cards: ['Valeria Torres · Casa San Isidro'] },
                      ].map(({ label, color, cards }) => (
                        <div key={label} className="flex-1">
                          <div className={`text-[10px] font-bold px-2 py-1 rounded-full mb-2 text-center ${color}`}>{label}</div>
                          {cards.map(c => (
                            <div key={c} className="bg-gray-50 border border-gray-200 rounded-lg p-2 mb-2">
                              <div className="text-[10px] font-semibold text-gray-700 leading-tight">{c}</div>
                            </div>
                          ))}
                        </div>
                      ))}
                    </div>
                  </div>
                )}
                {mockup === 'properties' && (
                  <div className="bg-white border border-gray-200 rounded-2xl shadow-sm p-5">
                    <div className="text-xs font-semibold text-gray-400 uppercase mb-3">Propiedades — 87 activas</div>
                    <div className="space-y-2">
                      {[
                        { code: 'APT-001', name: 'Depto 3 amb. Palermo', price: 'USD 185.000', status: 'Disponible', sc: 'bg-green-100 text-green-700' },
                        { code: 'CASA-001', name: 'Casa 4 amb. Belgrano', price: 'USD 320.000', status: 'Reservada', sc: 'bg-amber-100 text-amber-700' },
                        { code: 'PH-001', name: 'PH Recoleta', price: 'USD 420.000', status: 'Disponible', sc: 'bg-green-100 text-green-700' },
                      ].map(({ code, name, price, status, sc }) => (
                        <div key={code} className="flex items-center gap-3 p-2 rounded-lg bg-gray-50 border border-gray-100">
                          <div className="w-8 h-8 bg-blue-50 rounded-lg flex items-center justify-center text-[10px] font-bold text-blue-700">{code.split('-')[0]}</div>
                          <div className="flex-1">
                            <div className="text-xs font-semibold text-gray-800">{name}</div>
                            <div className="text-[10px] text-gray-400">{price}</div>
                          </div>
                          <span className={`text-[10px] font-semibold px-2 py-0.5 rounded-full ${sc}`}>{status}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
                {mockup === 'portal' && (
                  <div className="bg-white border border-gray-200 rounded-2xl shadow-sm p-5">
                    <div className="text-xs font-semibold text-gray-400 uppercase mb-3">Portal del Comprador</div>
                    <div className="bg-amber-50 rounded-xl p-4 border border-amber-100">
                      <div className="flex items-center gap-2 mb-3">
                        <div className="w-8 h-8 bg-amber-500 rounded-full flex items-center justify-center text-white text-xs font-bold">CR</div>
                        <div>
                          <div className="text-xs font-semibold text-gray-800">Carlos Rodríguez</div>
                          <div className="text-[10px] text-gray-400">Depto Villa Urquiza · APT-002</div>
                        </div>
                      </div>
                      <div className="space-y-2">
                        {[
                          { label: 'Cuota Enero 2026', amount: 'USD 1.233', paid: true },
                          { label: 'Cuota Febrero 2026', amount: 'USD 1.233', paid: true },
                          { label: 'Cuota Marzo 2026', amount: 'USD 1.233', paid: false },
                        ].map(({ label, amount, paid }) => (
                          <div key={label} className="flex items-center justify-between bg-white rounded-lg p-2 border border-amber-100">
                            <span className="text-[10px] text-gray-600">{label}</span>
                            <span className="text-[10px] font-bold text-gray-800">{amount}</span>
                            <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${paid ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-600'}`}>
                              {paid ? 'Pagada' : 'Pendiente'}
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                )}
              </div>

            </div>
          </div>
        ))}
      </section>

      {/* ── APP MOBILE BANNER ── */}
      <section className="py-20 px-6 bg-white border-t border-gray-100">
        <div className="max-w-6xl mx-auto flex items-center gap-16">
          {/* Phone mockup */}
          <div className="flex-1 hidden lg:flex justify-center">
            <div className="w-56 bg-gray-900 rounded-[2.5rem] p-2 shadow-2xl">
              <div className="bg-white rounded-[2rem] overflow-hidden">
                <div className="bg-blue-700 p-4">
                  <div className="text-white text-xs font-semibold">Mis Operaciones</div>
                  <div className="text-blue-200 text-[10px]">Julio 2026</div>
                </div>
                <div className="p-3 space-y-2">
                  {[
                    { name: 'Juan García', prop: 'Depto Palermo', stage: 'Interesado', color: 'bg-blue-100 text-blue-700' },
                    { name: 'María López', prop: 'Casa Belgrano', stage: 'Negociando', color: 'bg-amber-100 text-amber-700' },
                    { name: 'Carlos R.', prop: 'Depto V. Urquiza', stage: 'Vendido', color: 'bg-green-100 text-green-700' },
                  ].map(({ name, prop, stage, color }) => (
                    <div key={name} className="bg-gray-50 rounded-lg p-2 border border-gray-100">
                      <div className="flex justify-between items-start">
                        <div>
                          <div className="text-[10px] font-bold text-gray-800">{name}</div>
                          <div className="text-[9px] text-gray-400">{prop}</div>
                        </div>
                        <span className={`text-[8px] font-bold px-1.5 py-0.5 rounded-full ${color}`}>{stage}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Texto */}
          <div className="flex-1">
            <div className="text-xs font-semibold text-blue-600 uppercase tracking-wider mb-3">App móvil</div>
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Mejorá la calidad de tu servicio
              <span className="text-blue-700"> y aumentá tus ventas</span>
            </h2>
            <p className="text-gray-500 leading-relaxed mb-6">
              Trabajá desde donde quieras. Gestioná operaciones, respondé leads y consultá tu pipeline desde el celular.
            </p>
            <div className="flex gap-3">
              <div className="flex items-center gap-2 border border-gray-200 rounded-lg px-4 py-2.5 cursor-pointer hover:bg-gray-50 transition-colors">
                <span className="text-xl">📱</span>
                <div>
                  <div className="text-[9px] text-gray-400">Próximamente en</div>
                  <div className="text-xs font-semibold text-gray-800">Google Play</div>
                </div>
              </div>
              <div className="flex items-center gap-2 border border-gray-200 rounded-lg px-4 py-2.5 cursor-pointer hover:bg-gray-50 transition-colors">
                <span className="text-xl">🍎</span>
                <div>
                  <div className="text-[9px] text-gray-400">Próximamente en</div>
                  <div className="text-xs font-semibold text-gray-800">App Store</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── STRIP BANNER ── */}
      <div className="bg-blue-50 border-y border-blue-100 py-4 px-6 flex items-center justify-between max-w-full">
        <div className="max-w-6xl mx-auto w-full flex items-center justify-between">
          <p className="text-sm text-blue-800 font-medium">
            → Gestioná tu inmobiliaria desde donde estés. ¡Empezá tu prueba gratis hoy!
          </p>
          <Link href="#precios" className="text-sm font-semibold text-blue-700 border border-blue-300 px-4 py-1.5 rounded-lg hover:bg-blue-100 transition-colors whitespace-nowrap ml-4">
            Probar ahora
          </Link>
        </div>
      </div>

      {/* ── CONFÍAN EN NOSOTROS ── */}
      <section className="py-20 px-6">
        <div className="max-w-5xl mx-auto text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-10">Ellos confían en nosotros</h2>
          <div className="flex flex-wrap justify-center gap-8 mb-14">
            {clientes.map(c => (
              <div key={c} className="text-sm font-semibold text-gray-400 border border-gray-200 rounded-lg px-5 py-2.5">
                {c}
              </div>
            ))}
          </div>
          {/* Testimonio */}
          <div className="max-w-lg mx-auto bg-white border border-gray-200 rounded-2xl p-6 shadow-sm text-left">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center text-blue-700 font-bold text-sm">JV</div>
              <div>
                <div className="font-semibold text-gray-900 text-sm">Jorge Valencia</div>
                <div className="text-xs text-gray-400">Bienes Raíces Del Valle · Medellín</div>
              </div>
            </div>
            <p className="text-gray-600 text-sm leading-relaxed">
              "Después de años buscando un CRM que se adaptara al mercado colombiano, encontramos CRM Mobiliaria. El módulo de cuotas post-venta es exactamente lo que necesitábamos. Nos ahorró horas de trabajo con Excel."
            </p>
            <div className="mt-4 text-xs text-blue-700 font-semibold cursor-pointer hover:underline">Ver todos los casos de éxito →</div>
          </div>
        </div>
      </section>

      {/* ── SOPORTE ── */}
      <section className="py-20 px-6 bg-gray-50 border-t border-gray-100">
        <div className="max-w-5xl mx-auto text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-3">Soporte</h2>
          <p className="text-gray-500 mb-10">Contamos con atención personalizada y un centro de ayuda disponible las 24 horas. Te acompañamos para que despejés todas tus dudas.</p>
          <div className="grid md:grid-cols-2 gap-4 max-w-xl mx-auto">
            <div className="bg-blue-600 rounded-2xl p-5 text-left text-white">
              <div className="text-2xl mb-3">💬</div>
              <div className="font-semibold mb-1">Chat en vivo</div>
              <div className="text-sm text-blue-200">Lunes a viernes 9h a 18h. Respondemos en menos de 5 minutos.</div>
              <div className="text-xs text-blue-300 mt-3 font-semibold">soporte@crmmobiliaria.com</div>
            </div>
            <div className="bg-white border border-gray-200 rounded-2xl p-5 text-left">
              <div className="text-2xl mb-3">📚</div>
              <div className="font-semibold text-gray-900 mb-1">Centro de ayuda</div>
              <div className="text-sm text-gray-500">Artículos, tutoriales y videos para aprender a usar el CRM a tu ritmo.</div>
              <div className="text-xs text-blue-600 mt-3 font-semibold cursor-pointer hover:underline">Visitar centro de ayuda →</div>
            </div>
          </div>
        </div>
      </section>

      {/* ── PRECIOS ── */}
      <section id="precios" className="py-20 px-6">
        <div className="max-w-5xl mx-auto">
          <div className="text-center mb-14">
            <h2 className="text-3xl font-bold text-gray-900 mb-3">Planes y precios</h2>
            <p className="text-gray-500">14 días gratis en todos los planes. Sin tarjeta de crédito. Cancelá cuando quieras.</p>
          </div>
          <div className="grid md:grid-cols-3 gap-6">
            {[
              {
                nombre: 'Starter', precio: 'USD 49', periodo: '/mes',
                desc: 'Para agencias que están comenzando',
                items: ['Hasta 5 agentes', 'Hasta 50 propiedades', 'Pipeline Kanban', '1 portal de publicación', 'Soporte por email'],
                cta: '¡Probalo ahora!', featured: false,
              },
              {
                nombre: 'Pro', precio: 'USD 129', periodo: '/mes',
                desc: 'Para agencias en crecimiento',
                items: ['Hasta 20 agentes', 'Propiedades ilimitadas', 'Módulo de cuotas', 'Portal del comprador', 'Todos los portales', 'Automatización n8n', 'Soporte prioritario'],
                cta: '¡Probalo ahora!', featured: true,
              },
              {
                nombre: 'Enterprise', precio: 'A consultar', periodo: '',
                desc: 'Para redes inmobiliarias',
                items: ['Agentes ilimitados', 'Múltiples sucursales', 'API pública', 'White-label', 'Onboarding personalizado', 'SLA garantizado'],
                cta: 'Contactar ventas', featured: false,
              },
            ].map(({ nombre, precio, periodo, desc, items, cta, featured }) => (
              <div key={nombre} className={`rounded-2xl p-6 border-2 relative ${featured ? 'border-blue-700 shadow-xl shadow-blue-100' : 'border-gray-200'}`}>
                {featured && (
                  <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-blue-700 text-white text-xs font-bold px-4 py-1 rounded-full">
                    Más popular
                  </div>
                )}
                <h3 className="text-lg font-bold text-gray-900 mb-1">{nombre}</h3>
                <p className="text-sm text-gray-400 mb-4">{desc}</p>
                <div className="mb-6">
                  <span className="text-3xl font-bold text-gray-900">{precio}</span>
                  <span className="text-sm text-gray-400">{periodo}</span>
                </div>
                <ul className="space-y-2 mb-8">
                  {items.map(i => (
                    <li key={i} className="flex items-center gap-2 text-sm text-gray-600">
                      <span className="text-blue-600 font-bold text-xs">✓</span>
                      {i}
                    </li>
                  ))}
                </ul>
                <Link
                  href="/login"
                  className={`block text-center py-2.5 px-4 rounded-xl text-sm font-semibold transition-colors ${featured ? 'bg-blue-700 text-white hover:bg-blue-800' : 'border border-gray-300 text-gray-700 hover:bg-gray-50'}`}
                >
                  {cta}
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── FOOTER ── */}
      <footer className="bg-gray-900 text-gray-400 py-14 px-6">
        <div className="max-w-6xl mx-auto">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-10">
            <div>
              <div className="mb-3">
                <Image src="/logo.png" alt="CRM Mobiliaria" width={120} height={36} className="h-8 w-auto brightness-0 invert" />
              </div>
              <p className="text-sm text-gray-500 leading-relaxed">El CRM para inmobiliarias de Colombia y LATAM.</p>
            </div>
            {[
              { title: 'Producto', links: ['Funcionalidades', 'Planes y precios', 'Integraciones', 'Seguridad'] },
              { title: 'Empresa', links: ['Nosotros', 'Blog', 'Contacto', 'Prensa'] },
              { title: 'Legal', links: ['Términos de uso', 'Privacidad', 'Cookies'] },
            ].map(({ title, links }) => (
              <div key={title}>
                <h4 className="font-semibold text-white text-sm mb-3">{title}</h4>
                <ul className="space-y-2 text-sm">
                  {links.map(l => <li key={l}><a href="#" className="hover:text-white transition-colors">{l}</a></li>)}
                </ul>
              </div>
            ))}
          </div>
          <div className="border-t border-gray-800 pt-6 flex flex-col sm:flex-row justify-between items-center gap-4">
            <p className="text-sm">© 2026 CRM Mobiliaria. Todos los derechos reservados.</p>
            <div className="flex gap-6 text-sm">
              <Link href="/login" className="hover:text-white transition-colors">Iniciar sesión</Link>
              <Link href="/portal/login" className="hover:text-white transition-colors">Portal comprador</Link>
            </div>
          </div>
        </div>
      </footer>

    </div>
  )
}
