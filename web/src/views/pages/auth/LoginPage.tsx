import { useState, FormEvent } from 'react'
import { supabase } from '../../../services/supabase'
import { useNavigate } from 'react-router-dom'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const navigate = useNavigate()

  const handleLogin = async (e: FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      // 1. Autenticar usuario
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (authError) throw authError
      if (!authData.user) throw new Error('No se pudo iniciar sesión')

      // 2. Obtener el rol del usuario desde la base de datos
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select('rol, nombre_completo, activo')
        .eq('auth_user_id', authData.user.id)
        .single()

      if (userError) throw new Error('No se encontró información del usuario')
      if (!userData) throw new Error('Usuario no encontrado en el sistema')

      // 3. Verificar que el usuario esté activo
      if (!userData.activo) {
        await supabase.auth.signOut()
        throw new Error('Tu cuenta está desactivada. Contacta al administrador.')
      }

      // 4. Redirigir según el rol REAL del usuario
      const rol = userData.rol

      switch (rol) {
        case 'admin':
        case 'medico':
          // Admin y médicos van al dashboard completo (menú veterinario)
          localStorage.setItem('sessionType', 'veterinario')
          localStorage.setItem('userRole', rol)
          navigate('/dashboard')
          break

        case 'laboratorista':
          // Laboratoristas van a vista de laboratorio
          localStorage.setItem('sessionType', 'laboratorio')
          localStorage.setItem('userRole', rol)
          navigate('/laboratorio')
          break

        case 'ecografista':
          // Ecografistas van a vista de ecografía
          localStorage.setItem('sessionType', 'ecografia')
          localStorage.setItem('userRole', rol)
          navigate('/ecografia')
          break

        case 'recepcion':
          // Recepción va al dashboard
          localStorage.setItem('sessionType', 'veterinario')
          localStorage.setItem('userRole', rol)
          navigate('/dashboard')
          break

        case 'tutor':
          // Los tutores NO deberían acceder al dashboard web
          await supabase.auth.signOut()
          throw new Error('Los tutores deben usar la aplicación móvil. Este es el panel administrativo.')

        default:
          await supabase.auth.signOut()
          throw new Error(`Rol no reconocido: ${rol}`)
      }
    } catch (err: any) {
      setError(err.message || 'Error al iniciar sesión')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-500 to-primary-700 px-4">
      <div className="max-w-md w-full">
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-16 h-16 bg-primary-100 rounded-full mb-4">
              <svg className="w-10 h-10 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h1 className="text-3xl font-bold text-gray-900">RamboPet</h1>
            <p className="text-gray-600 mt-2">Sistema de Gestión Veterinaria</p>
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6">
              {error}
            </div>
          )}

          <form onSubmit={handleLogin} className="space-y-6">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                Correo electrónico
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="tu@email.com"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Contraseña
              </label>
              <input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="••••••••"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full bg-primary-600 text-white py-3 rounded-lg text-lg font-semibold hover:bg-primary-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Iniciando sesión...' : 'Iniciar sesión'}
            </button>
          </form>

          <div className="mt-6 text-center">
            <p className="text-sm text-gray-600">Panel Administrativo</p>
            <p className="text-xs text-gray-500 mt-1">Solo personal autorizado</p>
          </div>
        </div>
      </div>
    </div>
  )
}
