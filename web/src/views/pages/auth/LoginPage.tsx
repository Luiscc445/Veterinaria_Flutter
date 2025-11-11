import { useState, FormEvent } from 'react'
import { supabase } from '../../../services/supabase'
import { useNavigate } from 'react-router-dom'

type SessionType = 'veterinario' | 'laboratorio' | 'ecografia'

export default function LoginPage() {
  const [sessionType, setSessionType] = useState<SessionType>('veterinario')
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
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (error) throw error

      // Guardar el tipo de sesión en localStorage
      localStorage.setItem('sessionType', sessionType)

      // Redirigir según el tipo de sesión
      if (sessionType === 'veterinario') {
        navigate('/dashboard')
      } else if (sessionType === 'laboratorio') {
        navigate('/laboratorio')
      } else if (sessionType === 'ecografia') {
        navigate('/ecografia')
      }
    } catch (err: any) {
      setError(err.message || 'Error al iniciar sesión')
    } finally {
      setLoading(false)
    }
  }

  const sessionOptions = [
    { type: 'veterinario' as SessionType, label: 'Veterinario', icon: '👨‍⚕️', description: 'Consultas y atención médica' },
    { type: 'laboratorio' as SessionType, label: 'Laboratorio', icon: '🔬', description: 'Análisis y pruebas' },
    { type: 'ecografia' as SessionType, label: 'Ecografía', icon: '📡', description: 'Estudios de imagen' },
  ]

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

          {/* Selector de Tipo de Sesión */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-3 text-center">
              Selecciona el tipo de sesión
            </label>
            <div className="grid grid-cols-3 gap-3">
              {sessionOptions.map((option) => (
                <button
                  key={option.type}
                  type="button"
                  onClick={() => setSessionType(option.type)}
                  className={`p-3 rounded-lg border-2 transition-all ${
                    sessionType === option.type
                      ? 'border-primary-500 bg-primary-50 shadow-md'
                      : 'border-gray-200 bg-white hover:border-primary-300'
                  }`}
                >
                  <div className="text-3xl mb-1">{option.icon}</div>
                  <div className="text-xs font-medium text-gray-900">{option.label}</div>
                  <div className="text-[10px] text-gray-600 mt-1">{option.description}</div>
                </button>
              ))}
            </div>
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
                className="input-field"
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
                className="input-field"
                placeholder="••••••••"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full btn-primary py-3 text-lg disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Iniciando sesión...' : 'Iniciar sesión'}
            </button>
          </form>

          <p className="mt-6 text-center text-sm text-gray-600">
            Sistema administrativo - Solo personal autorizado
          </p>
        </div>
      </div>
    </div>
  )
}
