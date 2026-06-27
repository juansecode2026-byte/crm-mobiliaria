import Link from 'next/link'

const features = [
  {
    icon: '📋',
    title: 'Pipeline Kanban',
    description: 'Visualizá el estado de cada negociación en tiempo real. Arrastrá oportunidades entre etapas con un click.',
  },
  {
    icon: '💳',
    title: 'Cuotas post-venta',
    description: 'El módulo que Tokko Broker no tiene. Registrá pagos, generá tablas de amortización y seguí cada cuota vencida.',
  },
  {
    icon: '🏠',
    title: 'Portal del comprador',
    description: 'Tus compradores acceden a su propio portal para ver sus cuotas, pagos y recibos. Sin llamadas al agente.',
  },
  {
    icon: '🔗',
    title: 'Integración con portales',
    description: 'Conectá ZonaProp, Argenprop, MercadoLibre y Facebook Ads. Los leads llegan directo al CRM.',
  },
  {
    icon: '⚡',
    title: 'Automatización n8n',
    description: 'Alertas de cuotas vencidas por WhatsApp, recordatorios automáticos y flujos personalizados sin código.',
  },
  {
    icon: '🔒',
    title: 'Seguridad RLS',
    description: 'Cada agente ve solo sus clientes. Cada gerente ve su empresa. La seguridad vive en la base de datos, no en el código.',
  },
]

const comparativa = [
  { feature: 'Cuotas post-venta', crm: true, tokko: false },
  { feature: 'Portal del comprador', crm: true, tokko: false },
  { feature: 'Seguridad RLS nativa (BD)', crm: true, tokko: false },
  { feature: 'Real-time (WebSockets)', crm: true, tokko: false },
  { feature: 'Serverless / sin infra', crm: true, tokko: false },
  { feature: 'Integración Facebook Ads', crm: true, tokko: true },
  { feature: 'Integración ZonaProp', crm: true, tokko: true },
  { feature: 'Pipeline Kanban', crm: true, tokko: true },
  { feature: 'Tabla de amortización', crm: true, tokko: false },
  { feature: 'Automatización WhatsApp', crm: true, tokko: false },
]

const planes = [
  {
    nombre: 'Starter',
    precio: 'USD 49',
    periodo: '/mes',
    descripcion: 'Para agencias que están empezando',
    planFeatures: ['Hasta 5 agentes', 'Hasta 50 propiedades', 'Pipeline Kanban', 'Integración 1 portal', 'Soporte por email'],
    cta: 'Empezar gratis 14 días',
    destacado: false,
  },
  {
    nombre: 'Pro',
    precio: 'USD 129',
    periodo: '/mes',
    descripcion: 'Para agencias en crecimiento',
    planFeatures: ['Hasta 20 agentes', 'Propiedades ilimitadas', 'Módulo de cuotas completo', 'Portal del comprador', 'Todos los portales', 'Automatización n8n', 'Soporte prioritario'],
    cta: 'Empezar gratis 14 días',
    destacado: true,
  },
  {
    nombre: 'Enterprise',
    precio: 'A consultar',
    periodo: '',
    descripcion: 'Para redes inmobiliarias',
    planFeatures: ['Agentes ilimitados', 'Múltiples sucursales', 'API pública', 'White-label', 'Onboarding personalizado', 'SLA garantizado'],
    cta: 'Contactar ventas',
    destacado: false,
  },
]

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-white text-gray-900">

      {/* NAVBAR */}
      <nav className="fixed top-0 inset-x-0 z-50 bg-white/95 backdrop-blur border-b border-gray-100">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between h-16">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-blue-700 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">CR</span>
            </div>
            <span className="font-bold text-lg text-gray-900">CRM Mobiliaria</span>
          </div>
          <div className="flex items-center gap-3">
            <Link href="/login" className="text-sm font-medium text-gray-600 hover:text-gray-900 transition-colors">
              Iniciar sesión
            </Link>
            <Link href="#pricing" className="text-sm font-medium bg-blue-700 text-white px-4 py-2 rounded-lg hover:bg-blue-800 transition-colors">
              Solicitar demo
            </Link>
          </div>
        </div>
      </nav>

      {/* HERO */}
      <section className="pt-32 pb-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto text-center">
          <div className="inline-flex items-center gap-2 bg-blue-50 text-blue-700 text-sm font-medium px-4 py-1.5 rounded-full mb-6">
            <span>🚀</span>
            <span>Nuevo en 2026 — Construido para LATAM</span>
          </div>
          <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 leading-tight mb-6">
            El CRM para inmobiliarias
            <span className="text-blue-700 block">que Tokko Broker no puede darte</span>
          </h1>
          <p className="text-xl text-gray-500 mb-10 max-w-2xl mx-auto leading-relaxed">
            Gestioná propiedades, contactos y pipeline como siempre — pero con el módulo de cuotas post-venta que ningún otro CRM inmobiliario de LATAM tiene.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="#pricing" className="bg-blue-700 text-white px-8 py-4 rounded-xl font-semibold text-lg hover:bg-blue-800 transition-colors shadow-lg shadow-blue-200">
              Empezar gratis 14 días
            </Link>
            <Link href="#features" className="bg-gray-50 text-gray-700 px-8 py-4 rounded-xl font-semibold text-lg hover:bg-gray-100 transition-colors border border-gray-200">
              Ver funciones →
            </Link>
          </div>
          <p className="mt-4 text-sm text-gray-400">Sin tarjeta de crédito · Configuración en 10 minutos</p>
        </div>

        {/* Pipeline dashboard mockup */}
        <div className="max-w-5xl mx-auto mt-16">
          <div className="bg-gray-900 rounded-2xl p-1 shadow-2xl">
            <div className="bg-gray-800 rounded-xl p-4">
              <div className="flex items-center gap-2 mb-4">
                <div className="w-3 h-3 rounded-full bg-red-500" />
                <div className="w-3 h-3 rounded-full bg-yellow-500" />
                <div className="w-3 h-3 rounded-full bg-green-500" />
                <div className="flex-1 bg-gray-700 rounded-md h-6 ml-4" />
              </div>
              <div className="grid grid-cols-4 gap-3">
                {(['Prospecto', 'Interesado', 'Negociando', 'Cierre'] as const).map((stage, i) => (
                  <div key={stage} className="bg-gray-700 rounded-lg p-3">
                    <div className="text-xs text-gray-400 font-medium mb-2">{stage}</div>
                    {Array.from({ length: i === 1 ? 3 : i === 2 ? 2 : 1 }).map((_, j) => (
                      <div key={j} className="bg-gray-600 rounded p-2 mb-2">
                        <div className="h-2 bg-gray-500 rounded mb-1 w-3/4" />
                        <div className="h-2 bg-gray-500 rounded w-1/2" />
                      </div>
                    ))}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* PAIN POINTS */}
      <section className="py-16 bg-gray-50 px-4 sm:px-6 lg:px-8">
        <div className="max-w-5xl mx-auto">
          <h2 className="text-center text-2xl font-bold text-gray-900 mb-12">¿Te suena familiar?</h2>
          <div className="grid md:grid-cols-3 gap-6">
            {[
              { emoji: '📊', title: 'Cuotas en planillas Excel', body: 'Llevar el seguimiento de cuotas y pagos en Excel es lento, propenso a errores y no escala. Un solo error puede costar una relación con el cliente.' },
              { emoji: '🔍', title: 'Sin visibilidad del pipeline', body: 'No sabés en qué etapa están las negociaciones, cuántas van a cerrar este mes, ni cuáles oportunidades están paradas hace semanas.' },
              { emoji: '📞', title: 'Leads que se pierden', body: 'Los leads de ZonaProp y Facebook llegan por email o WhatsApp y se mezclan. Sin un sistema central, se pierden antes de que alguien los contacte.' },
            ].map(({ emoji, title, body }) => (
              <div key={title} className="bg-white rounded-xl p-6 border border-gray-200 shadow-sm">
                <div className="text-3xl mb-4">{emoji}</div>
                <h3 className="font-semibold text-gray-900 mb-2">{title}</h3>
                <p className="text-gray-500 text-sm leading-relaxed">{body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* FEATURES */}
      <section id="features" className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-5xl mx-auto">
          <div className="text-center mb-14">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Todo lo que necesitás, sin lo que no necesitás</h2>
            <p className="text-gray-500 text-lg">Diseñado desde cero para el mercado inmobiliario de LATAM en 2026.</p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {features.map(({ icon, title, description }) => (
              <div key={title} className="p-6 rounded-xl border border-gray-200 hover:border-blue-200 hover:shadow-md transition-all">
                <div className="text-3xl mb-3">{icon}</div>
                <h3 className="font-semibold text-gray-900 mb-2">{title}</h3>
                <p className="text-gray-500 text-sm leading-relaxed">{description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* COMPARATIVA */}
      <section className="py-20 bg-gray-50 px-4 sm:px-6 lg:px-8">
        <div className="max-w-3xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">CRM Mobiliaria vs Tokko Broker</h2>
            <p className="text-gray-500">12 años de deuda técnica vs un sistema construido hoy para hoy.</p>
          </div>
          <div className="bg-white rounded-2xl border border-gray-200 overflow-hidden shadow-sm">
            <div className="grid grid-cols-3 bg-gray-50 border-b border-gray-200">
              <div className="p-4 text-sm font-medium text-gray-500">Función</div>
              <div className="p-4 text-sm font-semibold text-blue-700 text-center">CRM Mobiliaria</div>
              <div className="p-4 text-sm font-medium text-gray-500 text-center">Tokko Broker</div>
            </div>
            {comparativa.map(({ feature, crm, tokko }, i) => (
              <div key={feature} className={`grid grid-cols-3 border-b border-gray-100 last:border-0 ${i % 2 === 0 ? 'bg-white' : 'bg-gray-50/50'}`}>
                <div className="p-4 text-sm text-gray-700">{feature}</div>
                <div className="p-4 text-center">{crm ? <span className="text-green-500 font-bold">✓</span> : <span className="text-red-400">✗</span>}</div>
                <div className="p-4 text-center">{tokko ? <span className="text-green-500 font-bold">✓</span> : <span className="text-red-400">✗</span>}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* PRICING */}
      <section id="pricing" className="py-20 px-4 sm:px-6 lg:px-8">
        <div className="max-w-5xl mx-auto">
          <div className="text-center mb-14">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Precios simples, sin sorpresas</h2>
            <p className="text-gray-500 text-lg">14 días gratis en todos los planes. Sin tarjeta de crédito.</p>
          </div>
          <div className="grid md:grid-cols-3 gap-6">
            {planes.map(({ nombre, precio, periodo, descripcion, planFeatures, cta, destacado }) => (
              <div key={nombre} className={`rounded-2xl p-6 border-2 ${destacado ? 'border-blue-700 bg-blue-700 text-white shadow-xl shadow-blue-200' : 'border-gray-200 bg-white'}`}>
                {destacado && <div className="text-blue-200 text-xs font-semibold uppercase tracking-wider mb-3">Más popular</div>}
                <div className="mb-4">
                  <h3 className={`text-xl font-bold ${destacado ? 'text-white' : 'text-gray-900'}`}>{nombre}</h3>
                  <p className={`text-sm mt-1 ${destacado ? 'text-blue-200' : 'text-gray-500'}`}>{descripcion}</p>
                </div>
                <div className="mb-6">
                  <span className={`text-4xl font-bold ${destacado ? 'text-white' : 'text-gray-900'}`}>{precio}</span>
                  <span className={`text-sm ${destacado ? 'text-blue-200' : 'text-gray-500'}`}>{periodo}</span>
                </div>
                <ul className="space-y-2 mb-8">
                  {planFeatures.map(f => (
                    <li key={f} className={`flex items-center gap-2 text-sm ${destacado ? 'text-blue-100' : 'text-gray-600'}`}>
                      <span className={destacado ? 'text-blue-200' : 'text-blue-700'}>✓</span>
                      {f}
                    </li>
                  ))}
                </ul>
                <Link href="/login" className={`block text-center py-3 px-6 rounded-xl font-semibold text-sm transition-colors ${destacado ? 'bg-white text-blue-700 hover:bg-blue-50' : 'bg-blue-700 text-white hover:bg-blue-800'}`}>
                  {cta}
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* FINAL CTA */}
      <section className="py-20 bg-blue-700 px-4 sm:px-6 lg:px-8">
        <div className="max-w-3xl mx-auto text-center">
          <h2 className="text-3xl font-bold text-white mb-4">Empezá hoy. Configuración en 10 minutos.</h2>
          <p className="text-blue-200 text-lg mb-8">Sin migraciones complicadas. Sin contratos anuales. Sin un equipo de IT.</p>
          <Link href="/login" className="inline-block bg-white text-blue-700 px-10 py-4 rounded-xl font-bold text-lg hover:bg-blue-50 transition-colors shadow-lg">
            Empezar gratis 14 días →
          </Link>
          <p className="mt-4 text-blue-200 text-sm">Sin tarjeta de crédito · Cancelá cuando quieras</p>
        </div>
      </section>

      {/* FOOTER */}
      <footer className="bg-gray-900 text-gray-400 py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-6xl mx-auto">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 mb-8">
            <div>
              <div className="flex items-center gap-2 mb-4">
                <div className="w-7 h-7 bg-blue-600 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-xs">CR</span>
                </div>
                <span className="font-semibold text-white text-sm">CRM Mobiliaria</span>
              </div>
              <p className="text-sm text-gray-500 leading-relaxed">El CRM para inmobiliarias de LATAM que tiene lo que los demás no tienen.</p>
            </div>
            {[
              { title: 'Producto', links: ['Funciones', 'Precios', 'Seguridad', 'Integraciones'] },
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
            <div className="flex gap-4 text-sm">
              <Link href="/login" className="hover:text-white transition-colors">Iniciar sesión</Link>
              <Link href="/portal/login" className="hover:text-white transition-colors">Portal comprador</Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}
