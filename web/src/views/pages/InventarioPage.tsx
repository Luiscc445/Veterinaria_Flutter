import { useEffect, useState } from 'react'
import { FarmacosController } from '../../controllers'
import type { Farmaco } from '../../models'
import { Card, Badge, Table, Modal, Button } from '../components/ui'

export default function InventarioPage() {
  const [farmacos, setFarmacos] = useState<Farmaco[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedFarmaco, setSelectedFarmaco] = useState<Farmaco | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)
  const [filter, setFilter] = useState<'all' | 'low'>('all')

  useEffect(() => {
    loadInventario()
  }, [])

  const loadInventario = async () => {
    try {
      const data = await FarmacosController.getAll()
      setFarmacos(data)
    } catch (error) {
      console.error('Error loading inventario:', error)
    } finally {
      setLoading(false)
    }
  }

  const viewDetails = (farmaco: Farmaco) => {
    setSelectedFarmaco(farmaco)
    setShowDetailModal(true)
  }

  const getEstadoStock = (farmaco: Farmaco) => {
    const stockTotal = farmaco.stock_total || 0
    if (stockTotal === 0) return { label: 'Sin stock', variant: 'danger' as const }
    if (stockTotal < farmaco.stock_minimo) return { label: 'Stock bajo', variant: 'warning' as const }
    return { label: 'Normal', variant: 'success' as const }
  }

  const filteredFarmacos = farmacos.filter(farmaco => {
    if (filter === 'low') {
      return (farmaco.stock_total || 0) < farmaco.stock_minimo
    }
    return true
  })

  const columns = [
    {
      key: 'nombre',
      label: 'Medicamento',
      render: (farmaco: Farmaco) => (
        <div>
          <p className="font-medium text-gray-900">{farmaco.nombre_comercial}</p>
          <p className="text-sm text-gray-500">{farmaco.nombre_generico}</p>
        </div>
      ),
    },
    {
      key: 'laboratorio',
      label: 'Laboratorio',
      render: (farmaco: Farmaco) => farmaco.laboratorio || '-',
    },
    {
      key: 'presentacion',
      label: 'Presentación',
      render: (farmaco: Farmaco) => farmaco.presentacion || '-',
    },
    {
      key: 'stock',
      label: 'Stock',
      render: (farmaco: Farmaco) => (
        <div>
          <p className="font-medium text-gray-900">{farmaco.stock_total || 0}</p>
          <p className="text-sm text-gray-500">Mínimo: {farmaco.stock_minimo}</p>
        </div>
      ),
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (farmaco: Farmaco) => {
        const estado = getEstadoStock(farmaco)
        return <Badge variant={estado.variant}>{estado.label}</Badge>
      },
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (farmaco: Farmaco) => (
        <Button size="sm" variant="outline" onClick={() => viewDetails(farmaco)}>
          Ver
        </Button>
      ),
    },
  ]

  const stockBajo = farmacos.filter(f => (f.stock_total || 0) < f.stock_minimo).length

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
        <h1 className="text-3xl font-bold text-gray-900">Gestión de Inventario</h1>
        <p className="text-gray-600 mt-1">Administra el stock de medicamentos y suministros</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Medicamentos</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{farmacos.length}</p>
            </div>
            <div className="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">💊</span>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Stock Bajo</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{stockBajo}</p>
            </div>
            <div className="w-12 h-12 bg-yellow-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">⚠️</span>
            </div>
          </div>
        </Card>

        <Card>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Stock Total</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">
                {farmacos.reduce((sum, f) => sum + (f.stock_total || 0), 0)}
              </p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">📦</span>
            </div>
          </div>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <div className="flex gap-3">
          <Button
            variant={filter === 'all' ? 'primary' : 'secondary'}
            onClick={() => setFilter('all')}
          >
            Todos ({farmacos.length})
          </Button>
          <Button
            variant={filter === 'low' ? 'warning' : 'secondary'}
            onClick={() => setFilter('low')}
          >
            Stock Bajo ({stockBajo})
          </Button>
        </div>
      </Card>

      {/* Table */}
      <Table
        columns={columns}
        data={filteredFarmacos}
        keyExtractor={(farmaco) => farmaco.id}
        emptyMessage={filter === 'low' ? 'No hay medicamentos con stock bajo' : 'No hay medicamentos registrados'}
      />

      {/* Detail Modal */}
      {selectedFarmaco && (
        <Modal
          isOpen={showDetailModal}
          onClose={() => setShowDetailModal(false)}
          title={selectedFarmaco.nombre_comercial}
          size="lg"
        >
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm font-medium text-gray-500">Nombre Comercial</p>
                <p className="mt-1 text-sm text-gray-900">{selectedFarmaco.nombre_comercial}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Nombre Genérico</p>
                <p className="mt-1 text-sm text-gray-900">{selectedFarmaco.nombre_generico}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Laboratorio</p>
                <p className="mt-1 text-sm text-gray-900">{selectedFarmaco.laboratorio || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Presentación</p>
                <p className="mt-1 text-sm text-gray-900">{selectedFarmaco.presentacion || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Forma Farmacéutica</p>
                <p className="mt-1 text-sm text-gray-900">{selectedFarmaco.forma_farmaceutica || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Vía de Administración</p>
                <p className="mt-1 text-sm text-gray-900">{selectedFarmaco.via_administracion || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Stock Total</p>
                <p className="mt-1 text-sm text-gray-900 font-bold">{selectedFarmaco.stock_total || 0}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Stock Mínimo</p>
                <p className="mt-1 text-sm text-gray-900">{selectedFarmaco.stock_minimo}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Estado</p>
                <div className="mt-1">
                  <Badge variant={getEstadoStock(selectedFarmaco).variant}>
                    {getEstadoStock(selectedFarmaco).label}
                  </Badge>
                </div>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Requiere Receta</p>
                <p className="mt-1 text-sm text-gray-900">{selectedFarmaco.requiere_receta ? 'Sí' : 'No'}</p>
              </div>
            </div>

            {selectedFarmaco.contraindicaciones && (
              <div>
                <p className="text-sm font-medium text-gray-500">Contraindicaciones</p>
                <p className="mt-1 text-sm text-gray-900">{selectedFarmaco.contraindicaciones}</p>
              </div>
            )}
          </div>
        </Modal>
      )}
    </div>
  )
}
