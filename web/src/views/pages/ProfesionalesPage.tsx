import { useEffect, useState } from 'react'
import { ProfesionalesController } from '../../controllers'
import type { Profesional } from '../../models'
import { Card, Table, Button, Modal, Badge } from '../components/ui'

export default function ProfesionalesPage() {
  const [profesionales, setProfesionales] = useState<Profesional[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedProfesional, setSelectedProfesional] = useState<Profesional | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)

  useEffect(() => {
    loadProfesionales()
  }, [])

  const loadProfesionales = async () => {
    try {
      const data = await ProfesionalesController.getAll()
      setProfesionales(data)
    } catch (error) {
      console.error('Error loading profesionales:', error)
    } finally {
      setLoading(false)
    }
  }

  const viewDetails = (profesional: Profesional) => {
    setSelectedProfesional(profesional)
    setShowDetailModal(true)
  }

  const columns = [
    {
      key: 'nombre',
      label: 'Profesional',
      render: (profesional: Profesional) => (
        <div>
          <p className="font-medium text-gray-900">{profesional.nombre || '-'}</p>
          <p className="text-sm text-gray-500">{profesional.especialidad || '-'}</p>
        </div>
      ),
    },
    {
      key: 'registro',
      label: 'Registro',
      render: (profesional: Profesional) => profesional.numero_registro_profesional || '-',
    },
    {
      key: 'telefono',
      label: 'Teléfono',
      render: (profesional: Profesional) => profesional.telefono || '-',
    },
    {
      key: 'email',
      label: 'Email',
      render: (profesional: Profesional) => profesional.email || '-',
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (profesional: Profesional) => (
        <Badge variant={profesional.activo ? 'success' : 'danger'}>
          {profesional.activo ? 'Activo' : 'Inactivo'}
        </Badge>
      ),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (profesional: Profesional) => (
        <Button size="sm" variant="outline" onClick={() => viewDetails(profesional)}>
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
        <h1 className="text-3xl font-bold text-gray-900">Gestión de Profesionales</h1>
        <p className="text-gray-600 mt-1">Administra médicos veterinarios y personal</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Profesionales</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{profesionales.length}</p>
            </div>
            <div className="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">👨‍⚕️</span>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Activos</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">
                {profesionales.filter(p => p.activo).length}
              </p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">✅</span>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Especialidades</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">
                {new Set(profesionales.map(p => p.especialidad).filter(Boolean)).size}
              </p>
            </div>
            <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">🎓</span>
            </div>
          </div>
        </Card>
      </div>

      {/* Table */}
      <Table
        columns={columns}
        data={profesionales}
        keyExtractor={(profesional) => profesional.id}
        emptyMessage="No hay profesionales registrados"
      />

      {/* Detail Modal */}
      {selectedProfesional && (
        <Modal
          isOpen={showDetailModal}
          onClose={() => setShowDetailModal(false)}
          title="Detalles del Profesional"
          size="lg"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm font-medium text-gray-500">Nombre</p>
                <p className="mt-1 text-sm text-gray-900">{selectedProfesional.nombre || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Especialidad</p>
                <p className="mt-1 text-sm text-gray-900">{selectedProfesional.especialidad || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Registro Profesional</p>
                <p className="mt-1 text-sm text-gray-900">{selectedProfesional.numero_registro_profesional || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Email</p>
                <p className="mt-1 text-sm text-gray-900">{selectedProfesional.email || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Teléfono</p>
                <p className="mt-1 text-sm text-gray-900">{selectedProfesional.telefono || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Estado</p>
                <div className="mt-1">
                  <Badge variant={selectedProfesional.activo ? 'success' : 'danger'}>
                    {selectedProfesional.activo ? 'Activo' : 'Inactivo'}
                  </Badge>
                </div>
              </div>
            </div>

            {selectedProfesional.firma_digital_url && (
              <div>
                <p className="text-sm font-medium text-gray-500">Firma Digital</p>
                <img
                  src={selectedProfesional.firma_digital_url}
                  alt="Firma digital"
                  className="mt-2 max-w-xs border rounded"
                />
              </div>
            )}
          </div>
        </Modal>
      )}
    </div>
  )
}
