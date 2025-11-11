import { useEffect, useState } from 'react'
import { FarmacosController } from '../../controllers'
import type { Farmaco } from '../../models'
import { Card, Badge, Table, Modal, Button, Input, Select } from '../components/ui'

export default function InventarioPage() {
  const [farmacos, setFarmacos] = useState<Farmaco[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedFarmaco, setSelectedFarmaco] = useState<Farmaco | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)
  const [showFormModal, setShowFormModal] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const [filter, setFilter] = useState<'all' | 'low'>('all')

  // Formulario
  const [formData, setFormData] = useState({
    nombre_comercial: '',
    nombre_generico: '',
    principio_activo: '',
    laboratorio: '',
    concentracion: '',
    forma_farmaceutica: '',
    via_administracion: [] as string[],
    presentacion: '',
    stock_total: 0,
    stock_minimo: 10,
    requiere_receta: false,
    contraindicaciones: '',
    activo: true,
  })

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

  const handleCreate = () => {
    setIsEditing(false)
    setFormData({
      nombre_comercial: '',
      nombre_generico: '',
      principio_activo: '',
      laboratorio: '',
      concentracion: '',
      forma_farmaceutica: '',
      via_administracion: [],
      presentacion: '',
      stock_total: 0,
      stock_minimo: 10,
      requiere_receta: false,
      contraindicaciones: '',
      activo: true,
    })
    setShowFormModal(true)
  }

  const handleEdit = (farmaco: Farmaco) => {
    setIsEditing(true)
    setSelectedFarmaco(farmaco)
    setFormData({
      nombre_comercial: farmaco.nombre_comercial,
      nombre_generico: farmaco.nombre_generico,
      principio_activo: farmaco.principio_activo || '',
      laboratorio: farmaco.laboratorio || '',
      concentracion: farmaco.concentracion || '',
      forma_farmaceutica: farmaco.forma_farmaceutica || '',
      via_administracion: Array.isArray(farmaco.via_administracion) ? farmaco.via_administracion : [],
      presentacion: farmaco.presentacion || '',
      stock_total: farmaco.stock_total || 0,
      stock_minimo: farmaco.stock_minimo,
      requiere_receta: farmaco.requiere_receta,
      contraindicaciones: farmaco.contraindicaciones || '',
      activo: farmaco.activo,
    })
    setShowFormModal(true)
  }

  const handleDelete = async (farmaco: Farmaco) => {
    if (!confirm(`¿Estás seguro de eliminar ${farmaco.nombre_comercial}?`)) return

    try {
      await FarmacosController.delete(farmaco.id)
      loadInventario()
    } catch (error) {
      console.error('Error al eliminar:', error)
      alert('Error al eliminar el medicamento')
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    try {
      if (isEditing && selectedFarmaco) {
        await FarmacosController.update(selectedFarmaco.id, formData)
      } else {
        await FarmacosController.create(formData)
      }

      setShowFormModal(false)
      loadInventario()
    } catch (error) {
      console.error('Error al guardar:', error)
      alert('Error al guardar el medicamento')
    }
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
        <div className="flex space-x-2">
          <Button size="sm" variant="outline" onClick={() => viewDetails(farmaco)}>
            Ver
          </Button>
          <Button size="sm" variant="secondary" onClick={() => handleEdit(farmaco)}>
            Editar
          </Button>
          <Button size="sm" variant="danger" onClick={() => handleDelete(farmaco)}>
            Eliminar
          </Button>
        </div>
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
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Gestión de Inventario</h1>
          <p className="text-gray-600 mt-1">Administra el stock de medicamentos y suministros</p>
        </div>
        <Button onClick={handleCreate}>
          Agregar Medicamento
        </Button>
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
                <p className="mt-1 text-sm text-gray-900">
                  {Array.isArray(selectedFarmaco.via_administracion)
                    ? selectedFarmaco.via_administracion.join(', ')
                    : selectedFarmaco.via_administracion || '-'
                  }
                </p>
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

      {/* Form Modal */}
      <Modal
        isOpen={showFormModal}
        onClose={() => setShowFormModal(false)}
        title={isEditing ? 'Editar Medicamento' : 'Nuevo Medicamento'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Nombre Comercial"
              value={formData.nombre_comercial}
              onChange={(e) => setFormData({ ...formData, nombre_comercial: e.target.value })}
              required
            />
            <Input
              label="Nombre Genérico"
              value={formData.nombre_generico}
              onChange={(e) => setFormData({ ...formData, nombre_generico: e.target.value })}
              required
            />
            <Input
              label="Principio Activo"
              value={formData.principio_activo}
              onChange={(e) => setFormData({ ...formData, principio_activo: e.target.value })}
              required
            />
            <Input
              label="Laboratorio"
              value={formData.laboratorio}
              onChange={(e) => setFormData({ ...formData, laboratorio: e.target.value })}
            />
            <Input
              label="Concentración"
              value={formData.concentracion}
              onChange={(e) => setFormData({ ...formData, concentracion: e.target.value })}
              placeholder="Ej: 500mg"
            />
            <Input
              label="Forma Farmacéutica"
              value={formData.forma_farmaceutica}
              onChange={(e) => setFormData({ ...formData, forma_farmaceutica: e.target.value })}
              placeholder="Ej: Comprimido, Jarabe"
            />
            <Input
              label="Presentación"
              value={formData.presentacion}
              onChange={(e) => setFormData({ ...formData, presentacion: e.target.value })}
              placeholder="Ej: Caja x 20"
            />
            <Select
              label="Vía de Administración"
              value={formData.via_administracion[0] || ''}
              onChange={(e) => setFormData({ ...formData, via_administracion: [e.target.value] })}
            >
              <option value="">Seleccionar</option>
              <option value="oral">Oral</option>
              <option value="topica">Tópica</option>
              <option value="inyectable">Inyectable</option>
              <option value="oftálmica">Oftálmica</option>
              <option value="ótica">Ótica</option>
            </Select>
            <Input
              label="Stock Total"
              type="number"
              value={formData.stock_total}
              onChange={(e) => setFormData({ ...formData, stock_total: parseInt(e.target.value) || 0 })}
              required
            />
            <Input
              label="Stock Mínimo"
              type="number"
              value={formData.stock_minimo}
              onChange={(e) => setFormData({ ...formData, stock_minimo: parseInt(e.target.value) || 0 })}
              required
            />
          </div>

          <div className="flex items-center space-x-4">
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={formData.requiere_receta}
                onChange={(e) => setFormData({ ...formData, requiere_receta: e.target.checked })}
                className="mr-2"
              />
              Requiere Receta
            </label>
            <label className="flex items-center">
              <input
                type="checkbox"
                checked={formData.activo}
                onChange={(e) => setFormData({ ...formData, activo: e.target.checked })}
                className="mr-2"
              />
              Activo
            </label>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Contraindicaciones
            </label>
            <textarea
              value={formData.contraindicaciones}
              onChange={(e) => setFormData({ ...formData, contraindicaciones: e.target.value })}
              className="input-field"
              rows={3}
              placeholder="Describe las contraindicaciones del medicamento"
            />
          </div>

          <div className="flex justify-end space-x-3 pt-4">
            <Button type="button" variant="outline" onClick={() => setShowFormModal(false)}>
              Cancelar
            </Button>
            <Button type="submit">
              {isEditing ? 'Actualizar' : 'Crear'}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
