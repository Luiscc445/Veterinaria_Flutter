import { useEffect, useState } from 'react'
import { CitasController } from '../../controllers'
import type { Cita } from '../../models'
import { Card, Button, Badge, Table, Modal } from '../components/ui'
import { format } from 'date-fns'

export default function CitasPage() {
  const [citas, setCitas] = useState<Cita[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedCita, setSelectedCita] = useState<Cita | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)

  useEffect(() => {
    loadCitas()
  }, [])

  const loadCitas = async () => {
    try {
      const data = await CitasController.getAll()
      setCitas(data)
    } catch (error) {
      console.error('Error loading citas:', error)
    } finally {
      setLoading(false)
    }
  }

  const confirmarCita = async (id: string) => {
    try {
      await CitasController.confirmar(id)
      loadCitas()
    } catch (error) {
      console.error('Error confirmando cita:', error)
    }
  }

  const viewDetails = (cita: Cita) => {
    setSelectedCita(cita)
    setShowDetailModal(true)
  }

  const getEstadoBadge = (estado: string) => {
    const variants: Record<string, 'success' | 'warning' | 'danger' | 'info' | 'default'> = {
      reservada: 'info',
      confirmada: 'success',
      en_sala: 'warning',
      atendida: 'default',
      cancelada: 'danger',
      reprogramada: 'warning',
    }
    return <Badge variant={variants[estado] || 'default'}>{estado}</Badge>
  }

  const columns = [
    {
      key: 'fecha_hora',
      label: 'Fecha/Hora',
      render: (cita: Cita) => (
        <div>
          <p className="font-medium text-gray-900">{format(new Date(cita.fecha_hora), 'dd/MM/yyyy')}</p>
          <p className="text-sm text-gray-500">{format(new Date(cita.fecha_hora), 'HH:mm')}</p>
        </div>
      ),
    },
    {
      key: 'mascota',
      label: 'Mascota',
      render: (cita: Cita) => (
        <div>
          <p className="font-medium text-gray-900">{cita.mascota_nombre || '-'}</p>
          <p className="text-sm text-gray-500">{cita.mascota_especie || '-'}</p>
        </div>
      ),
    },
    {
      key: 'servicio',
      label: 'Servicio',
      render: (cita: Cita) => cita.servicio_nombre || '-',
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (cita: Cita) => getEstadoBadge(cita.estado),
    },
    {
      key: 'motivo',
      label: 'Motivo',
      render: (cita: Cita) => (
        <p className="max-w-xs truncate">{cita.motivo_consulta || '-'}</p>
      ),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (cita: Cita) => (
        <div className="flex gap-2">
          <Button size="sm" variant="outline" onClick={() => viewDetails(cita)}>
            Ver
          </Button>
          {cita.estado === 'reservada' && (
            <Button size="sm" variant="success" onClick={() => confirmarCita(cita.id)}>
              Confirmar
            </Button>
          )}
        </div>
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
        <h1 className="text-3xl font-bold text-gray-900">Gestión de Citas</h1>
        <p className="text-gray-600 mt-1">Administra las citas veterinarias</p>
      </div>

      {/* Table */}
      <Table
        columns={columns}
        data={citas}
        keyExtractor={(cita) => cita.id}
        emptyMessage="No hay citas registradas"
      />

      {/* Detail Modal */}
      {selectedCita && (
        <Modal
          isOpen={showDetailModal}
          onClose={() => setShowDetailModal(false)}
          title="Detalles de la Cita"
          size="lg"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm font-medium text-gray-500">Fecha y Hora</p>
                <p className="mt-1 text-sm text-gray-900">
                  {format(new Date(selectedCita.fecha_hora), 'dd/MM/yyyy HH:mm')}
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Estado</p>
                <div className="mt-1">{getEstadoBadge(selectedCita.estado)}</div>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Mascota</p>
                <p className="mt-1 text-sm text-gray-900">{selectedCita.mascota_nombre || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Especie</p>
                <p className="mt-1 text-sm text-gray-900">{selectedCita.mascota_especie || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Servicio</p>
                <p className="mt-1 text-sm text-gray-900">{selectedCita.servicio_nombre || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Duración Estimada</p>
                <p className="mt-1 text-sm text-gray-900">
                  {selectedCita.duracion_estimada_min ? `${selectedCita.duracion_estimada_min} min` : '-'}
                </p>
              </div>
            </div>

            {selectedCita.motivo_consulta && (
              <div>
                <p className="text-sm font-medium text-gray-500">Motivo de Consulta</p>
                <p className="mt-1 text-sm text-gray-900">{selectedCita.motivo_consulta}</p>
              </div>
            )}

            {selectedCita.observaciones && (
              <div>
                <p className="text-sm font-medium text-gray-500">Observaciones</p>
                <p className="mt-1 text-sm text-gray-900">{selectedCita.observaciones}</p>
              </div>
            )}
          </div>
        </Modal>
      )}
    </div>
  )
}
