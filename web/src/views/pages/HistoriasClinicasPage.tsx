import { useEffect, useState } from 'react'
import { HistoriasClinicasController } from '../../controllers'
import type { HistoriaClinica } from '../../models'
import { Card, Table, Button, Modal } from '../components/ui'
import { format } from 'date-fns'

export default function HistoriasClinicasPage() {
  const [historias, setHistorias] = useState<HistoriaClinica[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedHistoria, setSelectedHistoria] = useState<HistoriaClinica | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)

  useEffect(() => {
    loadHistorias()
  }, [])

  const loadHistorias = async () => {
    try {
      const data = await HistoriasClinicasController.getAll()
      setHistorias(data)
    } catch (error) {
      console.error('Error loading historias:', error)
    } finally {
      setLoading(false)
    }
  }

  const viewDetails = (historia: HistoriaClinica) => {
    setSelectedHistoria(historia)
    setShowDetailModal(true)
  }

  const columns = [
    {
      key: 'numero',
      label: 'Número',
      render: (historia: HistoriaClinica) => (
        <p className="font-medium text-gray-900">{historia.numero_historia}</p>
      ),
    },
    {
      key: 'mascota',
      label: 'Mascota',
      render: (historia: HistoriaClinica) => (
        <div>
          <p className="font-medium text-gray-900">{historia.mascota_nombre || '-'}</p>
          <p className="text-sm text-gray-500">{historia.mascota_especie || '-'}</p>
        </div>
      ),
    },
    {
      key: 'fecha',
      label: 'Fecha Apertura',
      render: (historia: HistoriaClinica) => (
        <p className="text-sm text-gray-900">
          {format(new Date(historia.fecha_apertura), 'dd/MM/yyyy')}
        </p>
      ),
    },
    {
      key: 'tutor',
      label: 'Tutor',
      render: (historia: HistoriaClinica) => historia.tutor_nombre || '-',
    },
    {
      key: 'episodios',
      label: 'Episodios',
      render: (historia: HistoriaClinica) => (
        <p className="text-sm text-gray-900">{historia.total_episodios || 0}</p>
      ),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (historia: HistoriaClinica) => (
        <Button size="sm" variant="outline" onClick={() => viewDetails(historia)}>
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
        <h1 className="text-3xl font-bold text-gray-900">Historias Clínicas</h1>
        <p className="text-gray-600 mt-1">Gestiona los historiales médicos de las mascotas</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Historias</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{historias.length}</p>
            </div>
            <div className="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">📋</span>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Episodios</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">
                {historias.reduce((sum, h) => sum + (h.total_episodios || 0), 0)}
              </p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">📝</span>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Promedio por Historia</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">
                {historias.length > 0
                  ? Math.round(historias.reduce((sum, h) => sum + (h.total_episodios || 0), 0) / historias.length)
                  : 0}
              </p>
            </div>
            <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">📊</span>
            </div>
          </div>
        </Card>
      </div>

      {/* Table */}
      <Table
        columns={columns}
        data={historias}
        keyExtractor={(historia) => historia.id}
        emptyMessage="No hay historias clínicas registradas"
      />

      {/* Detail Modal */}
      {selectedHistoria && (
        <Modal
          isOpen={showDetailModal}
          onClose={() => setShowDetailModal(false)}
          title={`Historia Clínica #${selectedHistoria.numero_historia}`}
          size="lg"
        >
          <div className="space-y-6">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm font-medium text-gray-500">Número de Historia</p>
                <p className="mt-1 text-sm text-gray-900">{selectedHistoria.numero_historia}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Fecha de Apertura</p>
                <p className="mt-1 text-sm text-gray-900">
                  {format(new Date(selectedHistoria.fecha_apertura), 'dd/MM/yyyy')}
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Mascota</p>
                <p className="mt-1 text-sm text-gray-900">{selectedHistoria.mascota_nombre || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Especie</p>
                <p className="mt-1 text-sm text-gray-900">{selectedHistoria.mascota_especie || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Tutor</p>
                <p className="mt-1 text-sm text-gray-900">{selectedHistoria.tutor_nombre || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Total Episodios</p>
                <p className="mt-1 text-sm text-gray-900 font-bold">{selectedHistoria.total_episodios || 0}</p>
              </div>
            </div>

            {selectedHistoria.observaciones_generales && (
              <div>
                <p className="text-sm font-medium text-gray-500">Observaciones Generales</p>
                <p className="mt-1 text-sm text-gray-900">{selectedHistoria.observaciones_generales}</p>
              </div>
            )}

            <div className="border-t pt-4">
              <h4 className="text-sm font-medium text-gray-900 mb-3">Información Adicional</h4>
              <div className="bg-gray-50 p-4 rounded-lg">
                <p className="text-sm text-gray-600">
                  Esta historia clínica contiene {selectedHistoria.total_episodios || 0} episodio(s) médico(s).
                  Para ver los detalles de cada episodio, acceda a la sección de Episodios desde el menú principal.
                </p>
              </div>
            </div>
          </div>
        </Modal>
      )}
    </div>
  )
}
