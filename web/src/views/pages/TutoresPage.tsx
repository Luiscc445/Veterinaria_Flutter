import { useEffect, useState } from 'react'
import { TutoresController } from '../../controllers'
import type { Tutor } from '../../models'
import { Card, Table, Button, Modal, Badge } from '../components/ui'

export default function TutoresPage() {
  const [tutores, setTutores] = useState<Tutor[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedTutor, setSelectedTutor] = useState<Tutor | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)

  useEffect(() => {
    loadTutores()
  }, [])

  const loadTutores = async () => {
    try {
      const data = await TutoresController.getAll()
      setTutores(data)
    } catch (error) {
      console.error('Error loading tutores:', error)
    } finally {
      setLoading(false)
    }
  }

  const viewDetails = (tutor: Tutor) => {
    setSelectedTutor(tutor)
    setShowDetailModal(true)
  }

  const columns = [
    {
      key: 'nombre',
      label: 'Tutor',
      render: (tutor: Tutor) => (
        <div>
          <p className="font-medium text-gray-900">{tutor.nombre || '-'}</p>
          <p className="text-sm text-gray-500">{tutor.email || '-'}</p>
        </div>
      ),
    },
    {
      key: 'telefono',
      label: 'Teléfono',
      render: (tutor: Tutor) => tutor.telefono || '-',
    },
    {
      key: 'direccion',
      label: 'Dirección',
      render: (tutor: Tutor) => (
        <p className="max-w-xs truncate">{tutor.direccion || '-'}</p>
      ),
    },
    {
      key: 'ciudad',
      label: 'Ciudad',
      render: (tutor: Tutor) => tutor.ciudad || '-',
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (tutor: Tutor) => (
        <Badge variant={tutor.activo ? 'success' : 'danger'}>
          {tutor.activo ? 'Activo' : 'Inactivo'}
        </Badge>
      ),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (tutor: Tutor) => (
        <Button size="sm" variant="outline" onClick={() => viewDetails(tutor)}>
          Ver
        </Button>
      ),
    },
  ]

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
        <h1 className="text-3xl font-bold text-gray-900">Gestión de Tutores</h1>
        <p className="text-gray-600 mt-1">Administra los tutores de mascotas</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Tutores</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{tutores.length}</p>
            </div>
            <div className="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">👥</span>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Tutores Activos</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">
                {tutores.filter(t => t.activo).length}
              </p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">✅</span>
            </div>
          </div>
        </Card>
      </div>

      {/* Table */}
      <Table
        columns={columns}
        data={tutores}
        keyExtractor={(tutor) => tutor.id}
        emptyMessage="No hay tutores registrados"
      />

      {/* Detail Modal */}
      {selectedTutor && (
        <Modal
          isOpen={showDetailModal}
          onClose={() => setShowDetailModal(false)}
          title="Detalles del Tutor"
          size="lg"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm font-medium text-gray-500">Nombre</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.nombre || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Email</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.email || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Teléfono</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.telefono || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Documento</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.documento || '-'}</p>
              </div>
              <div className="col-span-2">
                <p className="text-sm font-medium text-gray-500">Dirección</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.direccion || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Ciudad</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.ciudad || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">País</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.pais || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Estado</p>
                <div className="mt-1">
                  <Badge variant={selectedTutor.activo ? 'success' : 'danger'}>
                    {selectedTutor.activo ? 'Activo' : 'Inactivo'}
                  </Badge>
                </div>
              </div>
            </div>
          </div>
        </Modal>
      )}
    </div>
  )
}
