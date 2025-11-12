import { useState, FormEvent } from 'react'
import { supabase } from '../../../services/supabase'
import { useNavigate } from 'react-router-dom'

type ViewOption = {
  id: string
  label: string
  icon: string
  description: string
  path: string
  sessionType: string
  allowedRoles: string[]
}

const viewOptions: ViewOption[] = [
  {
    id: 'dashboard',
    label: 'Dashboard Veterinario',
    icon: '🏥',
    description: 'Vista completa del sistema',
    path: '/dashboard',
    sessionType: 'veterinario',
    allowedRoles: ['admin', 'medico', 'recepcion']
  },
  {
    id: 'laboratorio',
    label: 'Laboratorio',
    icon: '🔬',
    description: 'Gestión de análisis y resultados',
    path: '/laboratorio',
    sessionType: 'laboratorio',
    allowedRoles: ['admin', 'laboratorista']
  },
  {
    id: 'ecografia',
    label: 'Ecografía',
    icon: '📡',
    description: 'Gestión de estudios ecográficos',
    path: '/ecografia',
    sessionType: 'ecografia',
    allowedRoles: ['admin', 'ecografista']
  }
]

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [showViewSelector, setShowViewSelector] = useState(false)
  const [userRole, setUserRole] = useState<string>('')
  const [availableViews, setAvailableViews] = useState<ViewOption[]>([])
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

      // 4. Verificar que no sea un tutor
      if (userData.rol === 'tutor') {
        await supabase.auth.signOut()
        throw new Error('Los tutores deben usar la aplicación móvil. Este es el panel administrativo.')
      }

      // 5. Guardar el rol y filtrar vistas disponibles
      const rol = userData.rol
      localStorage.setItem('userRole', rol)
      setUserRole(rol)

      // Filtrar vistas disponibles según el rol
      const available = viewOptions.filter(view => view.allowedRoles.includes(rol))
      setAvailableViews(available)

      // Si solo hay una vista disponible, ir directamente
      if (available.length === 1) {
        selectView(available[0])
      } else {
        // Mostrar selector de vistas
        setShowViewSelector(true)
        setLoading(false)
      }
    } catch (err: any) {
      setError(err.message || 'Error al iniciar sesión')
      setLoading(false)
    }
  }

  const selectView = (view: ViewOption) => {
    localStorage.setItem('sessionType', view.sessionType)
    localStorage.setItem('userRole', userRole)
    navigate(view.path)
  }

  const handleBackToLogin = () => {
    setShowViewSelector(false)
    setAvailableViews([])
    setUserRole('')
    supabase.auth.signOut()
  }

  // Vista selector de accesos
  if (showViewSelector) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-500 to-primary-700 px-4">
        <div className="max-w-4xl w-full">
          <div className="bg-white rounded-2xl shadow-2xl p-8">
            <div className="text-center mb-8">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-primary-100 rounded-full mb-4">
                <span className="text-4xl">🐾</span>
              </div>
              <h1 className="text-3xl font-bold text-gray-900">Selecciona tu Vista</h1>
              <p className="text-gray-600 mt-2">Elige desde dónde quieres trabajar hoy</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
              {availableViews.map((view) => (
                <button
                  key={view.id}
                  onClick={() => selectView(view)}
                  className="group relative bg-gradient-to-br from-gray-50 to-white border-2 border-gray-200 rounded-xl p-6 hover:border-primary-500 hover:shadow-lg transition-all duration-200 text-left"
                >
                  <div className="text-center mb-4">
                    <div className="text-5xl mb-3">{view.icon}</div>
                    <h3 className="text-lg font-bold text-gray-900 group-hover:text-primary-600 transition-colors">
                      {view.label}
                    </h3>
                  </div>
                  <p className="text-sm text-gray-600 text-center">
                    {view.description}
                  </p>
                  <div className="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity">
                    <svg className="w-6 h-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                </button>
              ))}
            </div>

            <div className="flex justify-center">
              <button
                onClick={handleBackToLogin}
                className="text-gray-600 hover:text-gray-900 transition-colors flex items-center space-x-2"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                </svg>
                <span>Cerrar sesión</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    )
  }

  // Vista de login
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
