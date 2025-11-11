import { useEffect, useState } from 'react'
import { supabase } from '../../services/supabase'
import { Card, Badge } from '../components/ui'

interface ProfesionalStats {
  id: string
  user_id: string
  matricula_profesional: string
  especialidades: string[]
  anios_experiencia: number
  activo: boolean
  usuario?: {
    nombre_completo: string
    email: string
    telefono: string
  }
}

interface EspecialidadCount {
  nombre: string
  count: number
}

export default function ProfesionalesPage() {
  const [profesionales, setProfesionales] = useState<ProfesionalStats[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadProfesionales()
  }, [])

  const loadProfesionales = async () => {
    try {
      const { data, error } = await supabase
        .from('profesionales')
        .select(`
          *,
          usuario:user_id (
            nombre_completo,
            email,
            telefono
          )
        `)
        .eq('activo', true)
        .order('created_at', { ascending: false })

      if (error) throw error
      setProfesionales(data || [])
    } catch (error) {
      console.error('Error loading profesionales:', error)
    } finally {
      setLoading(false)
    }
  }

  // Contar especialidades
  const getEspecialidadesCount = (): EspecialidadCount[] => {
    const especialidadesMap = new Map<string, number>()

    profesionales.forEach(prof => {
      if (prof.especialidades && Array.isArray(prof.especialidades)) {
        prof.especialidades.forEach(esp => {
          especialidadesMap.set(esp, (especialidadesMap.get(esp) || 0) + 1)
        })
      }
    })

    return Array.from(especialidadesMap.entries())
      .map(([nombre, count]) => ({ nombre, count }))
      .sort((a, b) => b.count - a.count)
  }

  // Agrupar por años de experiencia
  const getExperienciaDistribucion = () => {
    const distribucion = {
      junior: 0,      // 0-2 años
      intermedio: 0,  // 3-5 años
      senior: 0,      // 6-10 años
      experto: 0,     // 10+ años
    }

    profesionales.forEach(prof => {
      const anos = prof.anios_experiencia || 0
      if (anos <= 2) distribucion.junior++
      else if (anos <= 5) distribucion.intermedio++
      else if (anos <= 10) distribucion.senior++
      else distribucion.experto++
    })

    return distribucion
  }

  const especialidadesCount = getEspecialidadesCount()
  const experienciaDistribucion = getExperienciaDistribucion()
  const promedioExperiencia = profesionales.length > 0
    ? (profesionales.reduce((sum, p) => sum + (p.anios_experiencia || 0), 0) / profesionales.length).toFixed(1)
    : 0

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Estadísticas de Profesionales</h1>
        <p className="text-gray-600 mt-2">Visualiza las métricas del personal veterinario</p>
      </div>

      {/* Estadísticas principales */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">👨‍⚕️</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Total Profesionales</p>
              <p className="text-2xl font-bold text-gray-900">{profesionales.length}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">✅</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Activos</p>
              <p className="text-2xl font-bold text-green-600">{profesionales.filter(p => p.activo).length}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">🎓</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Especialidades</p>
              <p className="text-2xl font-bold text-purple-600">{especialidadesCount.length}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">📊</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Experiencia Promedio</p>
              <p className="text-2xl font-bold text-orange-600">{promedioExperiencia} años</p>
            </div>
          </div>
        </Card>
      </div>

      {/* Gráfico de Especialidades */}
      <Card>
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Distribución por Especialidad</h2>
        <div className="space-y-3">
          {especialidadesCount.length > 0 ? (
            especialidadesCount.map((esp, index) => (
              <div key={index}>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm font-medium text-gray-700">{esp.nombre}</span>
                  <span className="text-sm text-gray-600">{esp.count} profesional{esp.count !== 1 ? 'es' : ''}</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div
                    className="bg-primary-600 h-3 rounded-full transition-all"
                    style={{ width: `${(esp.count / profesionales.length) * 100}%` }}
                  />
                </div>
              </div>
            ))
          ) : (
            <p className="text-gray-500 text-center py-4">No hay especialidades registradas</p>
          )}
        </div>
      </Card>

      {/* Gráfico de Experiencia */}
      <Card>
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Distribución por Experiencia</h2>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-blue-900">Junior</span>
              <span className="text-xs text-blue-700">0-2 años</span>
            </div>
            <p className="text-3xl font-bold text-blue-600">{experienciaDistribucion.junior}</p>
            <div className="w-full bg-blue-200 rounded-full h-2 mt-2">
              <div
                className="bg-blue-600 h-2 rounded-full"
                style={{ width: profesionales.length > 0 ? `${(experienciaDistribucion.junior / profesionales.length) * 100}%` : '0%' }}
              />
            </div>
          </div>

          <div className="bg-green-50 rounded-lg p-4 border border-green-200">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-green-900">Intermedio</span>
              <span className="text-xs text-green-700">3-5 años</span>
            </div>
            <p className="text-3xl font-bold text-green-600">{experienciaDistribucion.intermedio}</p>
            <div className="w-full bg-green-200 rounded-full h-2 mt-2">
              <div
                className="bg-green-600 h-2 rounded-full"
                style={{ width: profesionales.length > 0 ? `${(experienciaDistribucion.intermedio / profesionales.length) * 100}%` : '0%' }}
              />
            </div>
          </div>

          <div className="bg-orange-50 rounded-lg p-4 border border-orange-200">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-orange-900">Senior</span>
              <span className="text-xs text-orange-700">6-10 años</span>
            </div>
            <p className="text-3xl font-bold text-orange-600">{experienciaDistribucion.senior}</p>
            <div className="w-full bg-orange-200 rounded-full h-2 mt-2">
              <div
                className="bg-orange-600 h-2 rounded-full"
                style={{ width: profesionales.length > 0 ? `${(experienciaDistribucion.senior / profesionales.length) * 100}%` : '0%' }}
              />
            </div>
          </div>

          <div className="bg-purple-50 rounded-lg p-4 border border-purple-200">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-purple-900">Experto</span>
              <span className="text-xs text-purple-700">10+ años</span>
            </div>
            <p className="text-3xl font-bold text-purple-600">{experienciaDistribucion.experto}</p>
            <div className="w-full bg-purple-200 rounded-full h-2 mt-2">
              <div
                className="bg-purple-600 h-2 rounded-full"
                style={{ width: profesionales.length > 0 ? `${(experienciaDistribucion.experto / profesionales.length) * 100}%` : '0%' }}
              />
            </div>
          </div>
        </div>
      </Card>

      {/* Lista de Profesionales */}
      <Card>
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Directorio de Profesionales</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {profesionales.length > 0 ? (
            profesionales.map((prof) => (
              <div key={prof.id} className="bg-gray-50 rounded-lg p-4 border border-gray-200">
                <div className="flex items-start justify-between mb-2">
                  <div>
                    <h3 className="font-semibold text-gray-900">{prof.usuario?.nombre_completo}</h3>
                    <p className="text-sm text-gray-600">{prof.matricula_profesional}</p>
                  </div>
                  <Badge variant={prof.activo ? 'success' : 'danger'}>
                    {prof.activo ? 'Activo' : 'Inactivo'}
                  </Badge>
                </div>
                <div className="space-y-1">
                  <p className="text-sm text-gray-700">
                    <span className="font-medium">Email:</span> {prof.usuario?.email}
                  </p>
                  <p className="text-sm text-gray-700">
                    <span className="font-medium">Teléfono:</span> {prof.usuario?.telefono}
                  </p>
                  <p className="text-sm text-gray-700">
                    <span className="font-medium">Experiencia:</span> {prof.anios_experiencia || 0} años
                  </p>
                  {prof.especialidades && prof.especialidades.length > 0 && (
                    <div className="flex flex-wrap gap-1 mt-2">
                      {prof.especialidades.map((esp, idx) => (
                        <span
                          key={idx}
                          className="px-2 py-1 bg-primary-100 text-primary-800 text-xs rounded-full"
                        >
                          {esp}
                        </span>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            ))
          ) : (
            <div className="col-span-2 text-center py-12">
              <span className="text-4xl">👨‍⚕️</span>
              <p className="text-gray-600 mt-4">No hay profesionales registrados</p>
              <p className="text-sm text-gray-500 mt-2">Crea profesionales desde la sección "Personal"</p>
            </div>
          )}
        </div>
      </Card>
    </div>
  )
}
