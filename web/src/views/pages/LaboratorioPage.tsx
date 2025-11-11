import { useState, useEffect } from 'react'
import { supabase } from '../../services/supabase'
import { Card, Button, Badge, Table, Modal } from '../components/ui'

interface Analisis {
  id: string
  mascota_id: string
  tipo_analisis: string
  fecha_solicitud: string
  fecha_resultado?: string
  estado: 'pendiente' | 'en_proceso' | 'completado'
  resultados?: string
  mascota?: {
    nombre: string
    especie: string
  }
}

export default function LaboratorioPage() {
  const [analisis, setAnalisis] = useState<Analisis[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedAnalisis, setSelectedAnalisis] = useState<Analisis | null>(null)
  const [showModal, setShowModal] = useState(false)
  const [filter, setFilter] = useState<'all' | 'pendiente' | 'completado'>('all')

  useEffect(() => {
    loadAnalisis()
  }, [])

  const loadAnalisis = async () => {
    try {
      setLoading(true)
      // Simulación de datos - en producción esto vendría de la base de datos
      const mockData: Analisis[] = [
        {
          id: '1',
          mascota_id: '1',
          tipo_analisis: 'Hemograma Completo',
          fecha_solicitud: '2025-11-10',
          estado: 'pendiente',
          mascota: { nombre: 'Max', especie: 'Canino' }
        },
        {
          id: '2',
          mascota_id: '2',
          tipo_analisis: 'Bioquímica Sanguínea',
          fecha_solicitud: '2025-11-09',
          fecha_resultado: '2025-11-10',
          estado: 'completado',
          resultados: 'Valores dentro de parámetros normales',
          mascota: { nombre: 'Luna', especie: 'Felino' }
        },
        {
          id: '3',
          mascota_id: '3',
          tipo_analisis: 'Urianálisis',
          fecha_solicitud: '2025-11-10',
          estado: 'en_proceso',
          mascota: { nombre: 'Rocky', especie: 'Canino' }
        },
      ]
      setAnalisis(mockData)
    } catch (error) {
      console.error('Error loading analisis:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleUpdateStatus = async (analisisId: string, newStatus: Analisis['estado']) => {
    // Actualizar estado del análisis
    setAnalisis(prev => prev.map(a =>
      a.id === analisisId ? { ...a, estado: newStatus } : a
    ))
  }

  const getFilteredAnalisis = () => {
    if (filter === 'pendiente') {
      return analisis.filter(a => a.estado === 'pendiente')
    } else if (filter === 'completado') {
      return analisis.filter(a => a.estado === 'completado')
    }
    return analisis
  }

  const columns = [
    {
      key: 'mascota',
      label: 'Mascota',
      render: (item: Analisis) => (
        <div>
          <p className="font-medium text-gray-900">{item.mascota?.nombre}</p>
          <p className="text-sm text-gray-500">{item.mascota?.especie}</p>
        </div>
      ),
    },
    {
      key: 'tipo',
      label: 'Tipo de Análisis',
      render: (item: Analisis) => item.tipo_analisis,
    },
    {
      key: 'fecha_solicitud',
      label: 'Fecha Solicitud',
      render: (item: Analisis) => new Date(item.fecha_solicitud).toLocaleDateString('es-ES'),
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (item: Analisis) => (
        <Badge
          variant={
            item.estado === 'completado' ? 'success' :
            item.estado === 'en_proceso' ? 'warning' : 'secondary'
          }
        >
          {item.estado === 'pendiente' ? 'Pendiente' :
           item.estado === 'en_proceso' ? 'En Proceso' : 'Completado'}
        </Badge>
      ),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (item: Analisis) => (
        <div className="flex space-x-2">
          <Button
            size="sm"
            variant="outline"
            onClick={() => {
              setSelectedAnalisis(item)
              setShowModal(true)
            }}
          >
            Ver Detalles
          </Button>
          {item.estado !== 'completado' && (
            <Button
              size="sm"
              variant="primary"
              onClick={() => handleUpdateStatus(item.id, 'completado')}
            >
              Marcar Completado
            </Button>
          )}
        </div>
      ),
    },
  ]

  const stats = {
    total: analisis.length,
    pendientes: analisis.filter(a => a.estado === 'pendiente').length,
    enProceso: analisis.filter(a => a.estado === 'en_proceso').length,
    completados: analisis.filter(a => a.estado === 'completado').length,
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Cargando análisis...</div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Laboratorio</h1>
        <p className="text-gray-600 mt-2">Gestión de análisis y pruebas de laboratorio</p>
      </div>

      {/* Estadísticas */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">🔬</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Total Análisis</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">⏳</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Pendientes</p>
              <p className="text-2xl font-bold text-yellow-600">{stats.pendientes}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">🔄</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">En Proceso</p>
              <p className="text-2xl font-bold text-orange-600">{stats.enProceso}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">✅</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Completados</p>
              <p className="text-2xl font-bold text-green-600">{stats.completados}</p>
            </div>
          </div>
        </Card>
      </div>

      {/* Filtros */}
      <Card>
        <div className="flex space-x-2">
          <Button
            variant={filter === 'all' ? 'primary' : 'outline'}
            onClick={() => setFilter('all')}
          >
            Todos ({stats.total})
          </Button>
          <Button
            variant={filter === 'pendiente' ? 'warning' : 'outline'}
            onClick={() => setFilter('pendiente')}
          >
            Pendientes ({stats.pendientes})
          </Button>
          <Button
            variant={filter === 'completado' ? 'success' : 'outline'}
            onClick={() => setFilter('completado')}
          >
            Completados ({stats.completados})
          </Button>
        </div>
      </Card>

      {/* Tabla de análisis */}
      <Card>
        <Table
          columns={columns}
          data={getFilteredAnalisis()}
          keyExtractor={(item) => item.id}
        />
      </Card>

      {/* Modal de detalles */}
      {selectedAnalisis && (
        <Modal
          isOpen={showModal}
          onClose={() => setShowModal(false)}
          title="Detalles del Análisis"
          size="lg"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-gray-600">Mascota</p>
                <p className="font-medium">{selectedAnalisis.mascota?.nombre}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Tipo de Análisis</p>
                <p className="font-medium">{selectedAnalisis.tipo_analisis}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Fecha Solicitud</p>
                <p className="font-medium">
                  {new Date(selectedAnalisis.fecha_solicitud).toLocaleDateString('es-ES')}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Estado</p>
                <Badge
                  variant={
                    selectedAnalisis.estado === 'completado' ? 'success' :
                    selectedAnalisis.estado === 'en_proceso' ? 'warning' : 'secondary'
                  }
                >
                  {selectedAnalisis.estado}
                </Badge>
              </div>
            </div>

            {selectedAnalisis.resultados && (
              <div>
                <p className="text-sm text-gray-600 mb-2">Resultados</p>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <p className="text-gray-900">{selectedAnalisis.resultados}</p>
                </div>
              </div>
            )}

            <div className="flex justify-end">
              <Button variant="outline" onClick={() => setShowModal(false)}>
                Cerrar
              </Button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  )
}
