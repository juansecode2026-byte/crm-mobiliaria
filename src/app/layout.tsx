import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'CRM Mobiliaria — El CRM para inmobiliarias de LATAM',
  description: 'Gestión completa de propiedades, contactos, pipeline y cuotas post-venta para agencias inmobiliarias de América Latina.',
  keywords: ['CRM inmobiliario', 'CRM LATAM', 'software inmobiliaria', 'gestión cuotas', 'pipeline ventas'],
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="es" className="h-full antialiased">
      <body className={`${inter.className} min-h-full flex flex-col`}>{children}</body>
    </html>
  )
}
