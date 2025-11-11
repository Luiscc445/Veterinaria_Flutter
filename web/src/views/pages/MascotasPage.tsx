import { useEffect, useState } from 'react'
import { MascotasController } from '../../controllers'
import type { Mascota } from '../../models'
import { Card, Button, Badge, Modal, Table } from '../components/ui'

export default function MascotasPage() {
  const [mascotas, setMascotas] = useState<Mascota[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<'all' | 'pendiente' | 'aprobado'>('all')
  const [selectedMascota, setSelectedMascota] = useState<Mascota | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)

  useEffect(() => {
    loadMascotas()
  }, [filter])

  const loadMascotas = async () => {
    try {
      const data = await MascotasController.getAll(filter)
      setMascotas(data)
    } catch (error) {
      console.error('Error loading mascotas:', error)
    } finally {
      setLoading(false)
    }
  }

  const aprobarMascota = async (id: string) => {
    try {
      await MascotasController.aprobar(id)
      loadMascotas()
    } catch (error) {
      console.error('Error aprobando mascota:', error)
    }
  }

  const rechazarMascota = async (id: string) => {
    try {
      await MascotasController.rechazar(id, 'Rechazado por administración')
      loadMascotas()
    } catch (error) {
      console.error('Error rechazando mascota:', error)
    }
  }

  const viewDetails = (mascota: Mascota) => {
    setSelectedMascota(mascota)
    setShowDetailModal(true)
  }

  const getEstadoBadge = (estado: string) => {
    const variants = {
      aprobado: 'success',
      pendiente: 'warning',
      rechazado: 'danger',
    } as const
    return <Badge variant={variants[estado as keyof typeof variants] || 'default'}>{estado}</Badge>
  }

  const columns = [
    {
      key: 'nombre',
      label: 'Nombre',
      render: (mascota: Mascota) => (
        <div className="flex items-center">
          {mascota.foto_url ? (
            <img src={mascota.foto_url} alt={mascota.nombre} className="w-10 h-10 rounded-full mr-3 object-cover" />
          ) : (
            <div className="w-10 h-10 rounded-full mr-3 bg-primary-100 flex items-center justify-center">
              <span className="text-lg">🐾</span>
            </div>
          )}
          <div>
            <p className="font-medium text-gray-900">{mascota.nombre}</p>
            <p className="text-sm text-gray-500">{mascota.microchip || 'Sin microchip'}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'especie',
      label: 'Especie',
    },
    {
      key: 'raza',
      label: 'Raza',
      render: (mascota: Mascota) => mascota.raza || '-',
    },
    {
      key: 'sexo',
      label: 'Sexo',
      render: (mascota: Mascota) => mascota.sexo || '-',
    },
    {
      key: 'edad',
      label: 'Edad',
      render: (mascota: Mascota) => {
        if (!mascota.fecha_nacimiento) return '-'
        const edad = new Date().getFullYear() - new Date(mascota.fecha_nacimiento).getFullYear()
        return `${edad} años`
      },
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (mascota: Mascota) => getEstadoBadge(mascota.estado),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (mascota: Mascota) => (
        <div className="flex gap-2">
          <Button size="sm" variant="outline" onClick={() => viewDetails(mascota)}>
            Ver
          </Button>
          {mascota.estado === 'pendiente' && (
            <>
              <Button size="sm" variant="success" onClick={() => aprobarMascota(mascota.id)}>
                Aprobar
              </Button>
              <Button size="sm" variant="danger" onClick={() => rechazarMascota(mascota.id)}>
                Rechazar
              </Button>
            </>
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
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Gestión de Mascotas</h1>
          <p className="text-gray-600 mt-1">Administra y aprueba registros de mascotas</p>
        </div>
      </div>

      {/* Filters */}
      <Card>
        <div className="flex gap-3">
          <Button
            variant={filter === 'all' ? 'primary' : 'secondary'}
            onClick={() => setFilter('all')}
          >
            Todas ({mascotas.length})
          </Button>
          <Button
            variant={filter === 'pendiente' ? 'warning' : 'secondary'}
            onClick={() => setFilter('pendiente')}
          >
            Pendientes
          </Button>
          <Button
            variant={filter === 'aprobado' ? 'success' : 'secondary'}
            onClick={() => setFilter('aprobado')}
          >
            Aprobadas
          </Button>
        </div>
      </Card>

      {/* Table */}
      <Table
        columns={columns}
        data={mascotas}
        keyExtractor={(mascota) => mascota.id}
        emptyMessage={`No hay mascotas ${filter !== 'all' ? filter + 's' : ''}`}
      />

      {/* Detail Modal */}
      {selectedMascota && (
        <Modal
          isOpen={showDetailModal}
          onClose={() => setShowDetailModal(false)}
          title={`Detalles de ${selectedMascota.nombre}`}
          size="lg"
        >
          <div className="space-y-6">
            {/* Imagen */}
            {selectedMascota.foto_url && (
              <div className="flex justify-center">
                <img
                  src={selectedMascota.foto_url}
                  alt={selectedMascota.nombre}
                  className="w-48 h-48 rounded-lg object-cover"
                />
              </div>
            )}

            {/* Información general */}
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm font-medium text-gray-500">Nombre</p>
                <p className="mt-1 text-sm text-gray-900">{selectedMascota.nombre}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Especie</p>
                <p className="mt-1 text-sm text-gray-900">{selectedMascota.especie}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Raza</p>
                <p className="mt-1 text-sm text-gray-900">{selectedMascota.raza || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Sexo</p>
                <p className="mt-1 text-sm text-gray-900">{selectedMascota.sexo || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Fecha de Nacimiento</p>
                <p className="mt-1 text-sm text-gray-900">
                  {selectedMascota.fecha_nacimiento
                    ? new Date(selectedMascota.fecha_nacimiento).toLocaleDateString()
                    : '-'}
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Peso</p>
                <p className="mt-1 text-sm text-gray-900">
                  {selectedMascota.peso_kg ? `${selectedMascota.peso_kg} kg` : '-'}
                </p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Color</p>
                <p className="mt-1 text-sm text-gray-900">{selectedMascota.color || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Microchip</p>
                <p className="mt-1 text-sm text-gray-900">{selectedMascota.microchip || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Esterilizado</p>
                <p className="mt-1 text-sm text-gray-900">{selectedMascota.esterilizado ? 'Sí' : 'No'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Estado</p>
                <div className="mt-1">{getEstadoBadge(selectedMascota.estado)}</div>
              </div>
            </div>

            {/* Señas particulares */}
            {selectedMascota.senias_particulares && (
              <div>
                <p className="text-sm font-medium text-gray-500">Señas Particulares</p>
                <p className="mt-1 text-sm text-gray-900">{selectedMascota.senias_particulares}</p>
              </div>
            )}

            {/* Alergias */}
            {selectedMascota.alergias && (
              <div>
                <p className="text-sm font-medium text-gray-500">Alergias</p>
                <p className="mt-1 text-sm text-gray-900">{selectedMascota.alergias}</p>
              </div>
            )}

            {/* Condiciones preexistentes */}
            {selectedMascota.condiciones_preexistentes && (
              <div>
                <p className="text-sm font-medium text-gray-500">Condiciones Preexistentes</p>
                <p className="mt-1 text-sm text-gray-900">{selectedMascota.condiciones_preexistentes}</p>
              </div>
            )}
          </div>
        </Modal>
      )}
    </div>
  )
}
