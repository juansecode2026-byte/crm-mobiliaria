'use client'

import { useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

export default function PortalLoginPage() {
  const router = useRouter()
  const supabase = createClient()

  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError(null)

    const { data, error: authError } = await supabase.auth.signInWithPassword({ email, password })

    if (authError) {
      setError('Email o contraseña incorrectos. Si es tu primera vez, revisá el email de invitación.')
      setLoading(false)
      return
    }

    const role = data.user?.app_metadata?.user_role as string | undefined

    if (role !== 'buyer') {
      // CRM user landed on buyer portal — redirect to CRM
      router.push('/crm/dashboard')
    } else {
      router.push('/portal/mis-cuotas')
    }

    router.refresh()
  }

  async function handleForgotPassword() {
    if (!email) {
      setError('Ingresá tu email para recuperar la contraseña.')
      return
    }
    setLoading(true)
    await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    })
    setError(null)
    alert(`Email de recuperación enviado a ${email}`)
    setLoading(false)
  }

  return (
    <div className="min-h-screen bg-amber-50 flex flex-col">

      {/* Top bar */}
      <div className="bg-white border-b border-amber-100 px-4 py-3 flex items-center justify-between">
        <Link href="/" className="flex items-center gap-2">
          <div className="w-7 h-7 bg-amber-600 rounded-lg flex items-center justify-center">
            <span className="text-white font-bold text-xs">🏠</span>
          </div>
          <span className="font-bold text-gray-900">CRM Mobiliaria</span>
        </Link>
        <Link href="/login" className="text-xs text-gray-500 hover:text-gray-700 transition-colors">
          ¿Sos agente? Iniciá sesión aquí →
        </Link>
      </div>

      {/* Login card */}
      <div className="flex-1 flex items-center justify-center px-4 py-12">
        <div className="w-full max-w-sm">

          <div className="text-center mb-8">
            <div className="w-14 h-14 bg-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
              <span className="text-2xl">🏠</span>
            </div>

            {/* Badge */}
            <div className="inline-flex items-center gap-1.5 bg-amber-100 text-amber-800 text-xs font-semibold px-3 py-1 rounded-full mb-3">
              <span>Portal del Comprador</span>
            </div>

            <h1 className="text-2xl font-bold text-gray-900">Tu portal de cuotas</h1>
            <p className="text-gray-500 text-sm mt-1 leading-relaxed">
              Accedé a tu estado de cuenta, historial de pagos y comprobantes
            </p>
          </div>

          {error && (
            <div className="mb-4 p-3 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm">
              {error}
            </div>
          )}

          <form onSubmit={handleLogin} className="bg-white rounded-2xl border border-amber-200 p-6 shadow-sm space-y-4">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1.5">
                Email
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                required
                autoComplete="email"
                placeholder="tu@email.com"
                className="w-full px-3 py-2.5 border border-gray-300 rounded-lg text-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent transition"
              />
            </div>

            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label htmlFor="password" className="block text-sm font-medium text-gray-700">
                  Contraseña
                </label>
                <button
                  type="button"
                  onClick={handleForgotPassword}
                  className="text-xs text-amber-600 hover:text-amber-800 transition-colors"
                >
                  ¿Olvidaste tu contraseña?
                </button>
              </div>
              <input
                id="password"
                type="password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                required
                autoComplete="current-password"
                placeholder="••••••••"
                className="w-full px-3 py-2.5 border border-gray-300 rounded-lg text-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent transition"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-amber-600 text-white py-2.5 px-4 rounded-lg font-semibold text-sm hover:bg-amber-700 transition-colors disabled:opacity-60 disabled:cursor-not-allowed"
            >
              {loading ? 'Ingresando...' : 'Ingresar al portal'}
            </button>
          </form>

          {/* Help text */}
          <div className="mt-6 bg-white rounded-xl border border-amber-200 p-4">
            <p className="text-xs text-gray-500 leading-relaxed">
              <strong className="text-gray-700">¿Primera vez?</strong> Buscá el email de invitación que te envió tu agente inmobiliario. Si no lo encontrás, contactá a la inmobiliaria.
            </p>
          </div>

          <div className="mt-4 text-center">
            <Link href="/login" className="text-xs text-gray-400 hover:text-gray-600 transition-colors">
              ← Volver a inicio
            </Link>
          </div>

        </div>
      </div>

      {/* Footer */}
      <div className="text-center py-4 text-xs text-gray-400">
        © 2026 CRM Mobiliaria ·{' '}
        <a href="#" className="hover:text-gray-600">Ayuda</a>
        {' · '}
        <a href="#" className="hover:text-gray-600">Privacidad</a>
      </div>
    </div>
  )
}
