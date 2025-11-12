import { useState, FormEvent } from 'react'
import { supabase } from '../../../services/supabase'
import { useNavigate } from 'react-router-dom'

type RoleOption = {
  id: string
  label: string
  icon: string
  description: string
  color: string
}

type ViewOption = {
  id: string
  label: string
  icon: string
  description: string
  path: string
  sessionType: string
  allowedRoles: string[]
}

const roleOptions: RoleOption[] = [
  {
    id: 'admin',
    label: 'Administrador',
    icon: '🔐',
    description: 'Acceso total al sistema',
    color: 'from-red-500 to-red-600'
  },
  {
    id: 'medico',
    label: 'Veterinario',
    icon: '👨‍⚕️',
    description: 'Gestión clínica y consultas',
    color: 'from-green-500 to-green-600'
  },
  {
    id: 'laboratorista',
    label: 'Laboratorista',
    icon: '🔬',
    description: 'Gestión de análisis',
    color: 'from-yellow-500 to-yellow-600'
  },
  {
    id: 'ecografista',
    label: 'Ecografista',
    icon: '📡',
    description: 'Estudios ecográficos',
    color: 'from-purple-500 to-purple-600'
  },
  {
    id: 'recepcion',
    label: 'Recepción',
    icon: '📋',
    description: 'Gestión de citas y tutores',
    color: 'from-blue-500 to-blue-600'
  }
]

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
  const [step, setStep] = useState<'role' | 'login' | 'view'>('role')
  const [selectedRole, setSelectedRole] = useState<string>('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [userRole, setUserRole] = useState<string>('')
  const [availableViews, setAvailableViews] = useState<ViewOption[]>([])
  const navigate = useNavigate()

  const handleRoleSelect = (roleId: string) => {
    setSelectedRole(roleId)
    setStep('login')
    setError(null)
  }

  const handleBackToRoleSelector = () => {
    setStep('role')
    setSelectedRole('')
    setEmail('')
    setPassword('')
    setError(null)
  }

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

      // 5. Verificar que el rol seleccionado coincida con el rol del usuario
      if (userData.rol !== selectedRole) {
        await supabase.auth.signOut()
        throw new Error(`Este usuario no tiene permisos de ${roleOptions.find(r => r.id === selectedRole)?.label}. Tu rol es: ${roleOptions.find(r => r.id === userData.rol)?.label}`)
      }

      // 6. Guardar el rol y filtrar vistas disponibles
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
        setStep('view')
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
    setStep('login')
    setAvailableViews([])
    setUserRole('')
    supabase.auth.signOut()
  }

  // PASO 1: Selector de Rol
  if (step === 'role') {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-500 to-primary-700 px-4 py-8">
        <div className="max-w-6xl w-full">
          <div className="bg-white rounded-2xl shadow-2xl p-8">
            <div className="text-center mb-8">
              <div className="inline-flex items-center justify-center w-20 h-20 bg-primary-100 rounded-full mb-4">
                <span className="text-5xl">🐾</span>
              </div>
              <h1 className="text-4xl font-bold text-gray-900 mb-2">RamboPet</h1>
              <h2 className="text-2xl font-semibold text-gray-700 mb-2">Sistema de Gestión Veterinaria</h2>
              <p className="text-gray-600">Selecciona tu rol para continuar</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {roleOptions.map((role) => (
                <button
                  key={role.id}
                  onClick={() => handleRoleSelect(role.id)}
                  className="group relative bg-white border-2 border-gray-200 rounded-2xl p-8 hover:border-transparent hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-1"
                >
                  <div className={`absolute inset-0 bg-gradient-to-br ${role.color} opacity-0 group-hover:opacity-100 rounded-2xl transition-opacity duration-300`}></div>

                  <div className="relative z-10">
                    <div className="text-center mb-4">
                      <div className="text-6xl mb-4 transform group-hover:scale-110 transition-transform duration-300">
                        {role.icon}
                      </div>
                      <h3 className="text-2xl font-bold text-gray-900 group-hover:text-white transition-colors mb-2">
                        {role.label}
                      </h3>
                    </div>
                    <p className="text-sm text-gray-600 group-hover:text-white transition-colors text-center">
                      {role.description}
                    </p>

                    <div className="mt-6 flex justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                      <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
                      </svg>
                    </div>
                  </div>
                </button>
              ))}
            </div>

            <div className="mt-8 text-center">
              <p className="text-sm text-gray-500">Panel Administrativo - Solo personal autorizado</p>
            </div>
          </div>
        </div>
      </div>
    )
  }

  // PASO 2: Login con rol seleccionado
  if (step === 'login') {
    const selectedRoleInfo = roleOptions.find(r => r.id === selectedRole)

    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-500 to-primary-700 px-4">
        <div className="max-w-md w-full">
          <div className="bg-white rounded-2xl shadow-2xl p-8">
            {/* Botón volver */}
            <button
              onClick={handleBackToRoleSelector}
              className="flex items-center text-gray-600 hover:text-gray-900 transition-colors mb-6"
            >
              <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
              <span className="text-sm">Cambiar rol</span>
            </button>

            <div className="text-center mb-8">
              <div className={`inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br ${selectedRoleInfo?.color} rounded-full mb-4`}>
                <span className="text-4xl">{selectedRoleInfo?.icon}</span>
              </div>
              <h1 className="text-3xl font-bold text-gray-900">Acceso {selectedRoleInfo?.label}</h1>
              <p className="text-gray-600 mt-2">{selectedRoleInfo?.description}</p>
            </div>

            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6 text-sm">
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
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  placeholder="tu@email.com"
                  autoFocus
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
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  placeholder="••••••••"
                />
              </div>

              <button
                type="submit"
                disabled={loading}
                className={`w-full bg-gradient-to-r ${selectedRoleInfo?.color} text-white py-3 rounded-lg text-lg font-semibold hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed`}
              >
                {loading ? 'Iniciando sesión...' : 'Iniciar sesión'}
              </button>
            </form>
          </div>
        </div>
      </div>
    )
  }

  // PASO 3: Selector de vista (solo para admin)
  if (step === 'view') {
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

  // Fallback (no debería llegar aquí)
  return null
}
