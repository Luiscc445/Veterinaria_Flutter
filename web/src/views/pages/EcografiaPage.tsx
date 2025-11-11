import { useState, useEffect } from 'react'
import { supabase } from '../../services/supabase'
import { Card, Button, Badge, Table, Modal } from '../components/ui'

interface Estudio {
  id: string
  mascota_id: string
  tipo_estudio: string
  fecha_solicitud: string
  fecha_realizacion?: string
  estado: 'agendado' | 'realizado' | 'interpretado'
  observaciones?: string
  imagenes?: string[]
  mascota?: {
    nombre: string
    especie: string
  }
}

export default function EcografiaPage() {
  const [estudios, setEstudios] = useState<Estudio[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedEstudio, setSelectedEstudio] = useState<Estudio | null>(null)
  const [showModal, setShowModal] = useState(false)
  const [filter, setFilter] = useState<'all' | 'agendado' | 'realizado'>('all')

  useEffect(() => {
    loadEstudios()
  }, [])

  const loadEstudios = async () => {
    try {
      setLoading(true)
      // Simulación de datos - en producción esto vendría de la base de datos
      const mockData: Estudio[] = [
        {
          id: '1',
          mascota_id: '1',
          tipo_estudio: 'Ecografía Abdominal',
          fecha_solicitud: '2025-11-10',
          estado: 'agendado',
          mascota: { nombre: 'Max', especie: 'Canino' }
        },
        {
          id: '2',
          mascota_id: '2',
          tipo_estudio: 'Ecografía Cardíaca',
          fecha_solicitud: '2025-11-08',
          fecha_realizacion: '2025-11-09',
          estado: 'realizado',
          observaciones: 'Estudio realizado sin hallazgos significativos',
          mascota: { nombre: 'Luna', especie: 'Felino' }
        },
        {
          id: '3',
          mascota_id: '3',
          tipo_estudio: 'Ecografía de Gestación',
          fecha_solicitud: '2025-11-09',
          fecha_realizacion: '2025-11-10',
          estado: 'interpretado',
          observaciones: 'Se confirma gestación de 3 cachorros',
          mascota: { nombre: 'Bella', especie: 'Canino' }
        },
      ]
      setEstudios(mockData)
    } catch (error) {
      console.error('Error loading estudios:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleUpdateStatus = async (estudioId: string, newStatus: Estudio['estado']) => {
    setEstudios(prev => prev.map(e =>
      e.id === estudioId ? { ...e, estado: newStatus, fecha_realizacion: new Date().toISOString() } : e
    ))
  }

  const getFilteredEstudios = () => {
    if (filter === 'agendado') {
      return estudios.filter(e => e.estado === 'agendado')
    } else if (filter === 'realizado') {
      return estudios.filter(e => e.estado === 'realizado' || e.estado === 'interpretado')
    }
    return estudios
  }

  const columns = [
    {
      key: 'mascota',
      label: 'Mascota',
      render: (item: Estudio) => (
        <div>
          <p className="font-medium text-gray-900">{item.mascota?.nombre}</p>
          <p className="text-sm text-gray-500">{item.mascota?.especie}</p>
        </div>
      ),
    },
    {
      key: 'tipo',
      label: 'Tipo de Estudio',
      render: (item: Estudio) => item.tipo_estudio,
    },
    {
      key: 'fecha_solicitud',
      label: 'Fecha Solicitud',
      render: (item: Estudio) => new Date(item.fecha_solicitud).toLocaleDateString('es-ES'),
    },
    {
      key: 'fecha_realizacion',
      label: 'Fecha Realización',
      render: (item: Estudio) =>
        item.fecha_realizacion
          ? new Date(item.fecha_realizacion).toLocaleDateString('es-ES')
          : '-',
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (item: Estudio) => (
        <Badge
          variant={
            item.estado === 'interpretado' ? 'success' :
            item.estado === 'realizado' ? 'warning' : 'secondary'
          }
        >
          {item.estado === 'agendado' ? 'Agendado' :
           item.estado === 'realizado' ? 'Realizado' : 'Interpretado'}
        </Badge>
      ),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (item: Estudio) => (
        <div className="flex space-x-2">
          <Button
            size="sm"
            variant="outline"
            onClick={() => {
              setSelectedEstudio(item)
              setShowModal(true)
            }}
          >
            Ver Detalles
          </Button>
          {item.estado === 'agendado' && (
            <Button
              size="sm"
              variant="primary"
              onClick={() => handleUpdateStatus(item.id, 'realizado')}
            >
              Marcar Realizado
            </Button>
          )}
          {item.estado === 'realizado' && (
            <Button
              size="sm"
              variant="success"
              onClick={() => handleUpdateStatus(item.id, 'interpretado')}
            >
              Interpretar
            </Button>
          )}
        </div>
      ),
    },
  ]

  const stats = {
    total: estudios.length,
    agendados: estudios.filter(e => e.estado === 'agendado').length,
    realizados: estudios.filter(e => e.estado === 'realizado').length,
    interpretados: estudios.filter(e => e.estado === 'interpretado').length,
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Cargando estudios...</div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Ecografía</h1>
        <p className="text-gray-600 mt-2">Gestión de estudios ecográficos y diagnóstico por imagen</p>
      </div>

      {/* Estadísticas */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">📡</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Total Estudios</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">📅</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Agendados</p>
              <p className="text-2xl font-bold text-yellow-600">{stats.agendados}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">🔬</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Realizados</p>
              <p className="text-2xl font-bold text-orange-600">{stats.realizados}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">✅</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Interpretados</p>
              <p className="text-2xl font-bold text-green-600">{stats.interpretados}</p>
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
            variant={filter === 'agendado' ? 'warning' : 'outline'}
            onClick={() => setFilter('agendado')}
          >
            Agendados ({stats.agendados})
          </Button>
          <Button
            variant={filter === 'realizado' ? 'success' : 'outline'}
            onClick={() => setFilter('realizado')}
          >
            Realizados ({stats.realizados + stats.interpretados})
          </Button>
        </div>
      </Card>

      {/* Tabla de estudios */}
      <Card>
        <Table
          columns={columns}
          data={getFilteredEstudios()}
          keyExtractor={(item) => item.id}
        />
      </Card>

      {/* Modal de detalles */}
      {selectedEstudio && (
        <Modal
          isOpen={showModal}
          onClose={() => setShowModal(false)}
          title="Detalles del Estudio Ecográfico"
          size="lg"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-gray-600">Mascota</p>
                <p className="font-medium">{selectedEstudio.mascota?.nombre}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Tipo de Estudio</p>
                <p className="font-medium">{selectedEstudio.tipo_estudio}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Fecha Solicitud</p>
                <p className="font-medium">
                  {new Date(selectedEstudio.fecha_solicitud).toLocaleDateString('es-ES')}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-600">Fecha Realización</p>
                <p className="font-medium">
                  {selectedEstudio.fecha_realizacion
                    ? new Date(selectedEstudio.fecha_realizacion).toLocaleDateString('es-ES')
                    : 'Pendiente'}
                </p>
              </div>
              <div className="col-span-2">
                <p className="text-sm text-gray-600">Estado</p>
                <Badge
                  variant={
                    selectedEstudio.estado === 'interpretado' ? 'success' :
                    selectedEstudio.estado === 'realizado' ? 'warning' : 'secondary'
                  }
                >
                  {selectedEstudio.estado}
                </Badge>
              </div>
            </div>

            {selectedEstudio.observaciones && (
              <div>
                <p className="text-sm text-gray-600 mb-2">Observaciones</p>
                <div className="bg-gray-50 p-4 rounded-lg">
                  <p className="text-gray-900">{selectedEstudio.observaciones}</p>
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
