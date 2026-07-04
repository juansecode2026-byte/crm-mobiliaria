import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

function getRoleFromJWT(accessToken: string): string | undefined {
  try {
    const payload = JSON.parse(atob(accessToken.split('.')[1]))
    return payload.user_role as string | undefined
  } catch {
    return undefined
  }
}

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Public routes — skip Supabase entirely for fast response
  // /auth/callback must be public so Supabase can exchange the PKCE code
  const publicRoutes = ['/', '/login', '/portal', '/auth/callback', '/reset-password']
  if (publicRoutes.some(route => pathname === route || pathname.startsWith('/auth/'))) {
    return NextResponse.next({ request })
  }

  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // Validate session (network call — checks JWT against Supabase)
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    const url = request.nextUrl.clone()
    url.pathname = '/login'
    return NextResponse.redirect(url)
  }

  // Read role from JWT custom claims (fn_custom_jwt_claims hook)
  // getSession() reads the cookie locally — no extra network call
  const { data: { session } } = await supabase.auth.getSession()
  const role = session?.access_token
    ? getRoleFromJWT(session.access_token)
    : undefined

  // Buyer tries to access CRM routes → buyer portal
  if (role === 'buyer' && !pathname.startsWith('/mis-cuotas')) {
    const url = request.nextUrl.clone()
    url.pathname = '/mis-cuotas'
    return NextResponse.redirect(url)
  }

  // CRM user tries to access buyer portal → CRM dashboard
  if (role && role !== 'buyer' && pathname.startsWith('/mis-cuotas')) {
    const url = request.nextUrl.clone()
    url.pathname = '/dashboard'
    return NextResponse.redirect(url)
  }

  return supabaseResponse
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
