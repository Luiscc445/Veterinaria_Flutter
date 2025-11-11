import { useState, useEffect } from 'react'
import { supabase } from '../../services/supabase'
import { Card, Button, Badge, Modal, Table } from '../components/ui'

interface Usuario {
  id: string
  email: string
  nombre_completo: string
  telefono: string
  rol: string
  activo: boolean
  created_at: string
  auth_user_id: string | null
}

interface Tutor {
  id: string
  user_id: string
  dni: string
  direccion: string
  ciudad: string
  provincia: string
  usuario?: Usuario
  mascotas?: Mascota[]
}

interface Mascota {
  id: string
  nombre: string
  especie: string
  raza: string
  sexo: string
  fecha_nacimiento: string
  estado: string
  esterilizado: boolean
  foto_url?: string
}

export default function UsuariosRegistradosPage() {
  const [tutores, setTutores] = useState<Tutor[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedTutor, setSelectedTutor] = useState<Tutor | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)
  const [filter, setFilter] = useState<'all' | 'active' | 'inactive'>('all')

  useEffect(() => {
    fetchTutores()
  }, [])

  const fetchTutores = async () => {
    try {
      setLoading(true)

      // Obtener tutores con sus usuarios y mascotas
      const { data: tutoresData, error: tutoresError } = await supabase
        .from('tutores')
        .select(`
          *,
          usuario:users!tutores_user_id_fkey (
            id,
            email,
            nombre_completo,
            telefono,
            rol,
            activo,
            created_at,
            auth_user_id
          )
        `)
        .order('created_at', { ascending: false })

      if (tutoresError) throw tutoresError

      // Para cada tutor, obtener sus mascotas
      const tutoresConMascotas = await Promise.all(
        (tutoresData || []).map(async (tutor) => {
          const { data: mascotasData } = await supabase
            .from('mascotas')
            .select('*')
            .eq('tutor_id', tutor.id)
            .order('nombre')

          return {
            ...tutor,
            mascotas: mascotasData || []
          }
        })
      )

      setTutores(tutoresConMascotas)
    } catch (error) {
      console.error('Error al cargar tutores:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleToggleStatus = async (tutorId: string, currentStatus: boolean) => {
    try {
      const tutor = tutores.find(t => t.id === tutorId)
      if (!tutor?.user_id) return

      const { error } = await supabase
        .from('users')
        .update({ activo: !currentStatus })
        .eq('id', tutor.user_id)

      if (error) throw error

      fetchTutores()
    } catch (error) {
      console.error('Error al cambiar estado:', error)
    }
  }

  const handleViewDetails = (tutor: Tutor) => {
    setSelectedTutor(tutor)
    setShowDetailModal(true)
  }

  const getFilteredTutores = () => {
    if (filter === 'active') {
      return tutores.filter(t => t.usuario?.activo === true)
    } else if (filter === 'inactive') {
      return tutores.filter(t => t.usuario?.activo === false)
    }
    return tutores
  }

  const columns = [
    {
      key: 'usuario',
      label: 'Usuario',
      render: (tutor: Tutor) => (
        <div>
          <p className="font-medium text-gray-900">{tutor.usuario?.nombre_completo || 'Sin nombre'}</p>
          <p className="text-sm text-gray-600">{tutor.usuario?.email}</p>
        </div>
      ),
    },
    {
      key: 'dni',
      label: 'DNI',
      render: (tutor: Tutor) => <span className="text-gray-900">{tutor.dni}</span>,
    },
    {
      key: 'contacto',
      label: 'Contacto',
      render: (tutor: Tutor) => (
        <div className="text-sm">
          <p className="text-gray-900">{tutor.usuario?.telefono}</p>
          <p className="text-gray-600">{tutor.ciudad}, {tutor.provincia}</p>
        </div>
      ),
    },
    {
      key: 'mascotas',
      label: 'Mascotas',
      render: (tutor: Tutor) => (
        <div className="flex items-center space-x-2">
          <span className="text-2xl">🐾</span>
          <span className="font-semibold text-primary-600">{tutor.mascotas?.length || 0}</span>
        </div>
      ),
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (tutor: Tutor) => (
        <Badge color={tutor.usuario?.activo ? 'success' : 'danger'}>
          {tutor.usuario?.activo ? 'Activo' : 'Inactivo'}
        </Badge>
      ),
    },
    {
      key: 'fecha',
      label: 'Registro',
      render: (tutor: Tutor) => (
        <span className="text-sm text-gray-600">
          {tutor.usuario?.created_at
            ? new Date(tutor.usuario.created_at).toLocaleDateString('es-ES')
            : '-'
          }
        </span>
      ),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (tutor: Tutor) => (
        <div className="flex space-x-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => handleViewDetails(tutor)}
          >
            Ver detalles
          </Button>
          <Button
            variant={tutor.usuario?.activo ? 'danger' : 'success'}
            size="sm"
            onClick={() => handleToggleStatus(tutor.id, tutor.usuario?.activo || false)}
          >
            {tutor.usuario?.activo ? 'Desactivar' : 'Activar'}
          </Button>
        </div>
      ),
    },
  ]

  const stats = {
    total: tutores.length,
    activos: tutores.filter(t => t.usuario?.activo).length,
    inactivos: tutores.filter(t => t.usuario?.activo === false).length,
    totalMascotas: tutores.reduce((sum, t) => sum + (t.mascotas?.length || 0), 0),
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Cargando usuarios registrados...</div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Usuarios Registrados</h1>
          <p className="text-gray-600 mt-2">Gestiona los usuarios que se han registrado desde la aplicación móvil</p>
        </div>
      </div>

      {/* Estadísticas */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">👥</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Total Usuarios</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
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
              <p className="text-2xl font-bold text-green-600">{stats.activos}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">❌</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Inactivos</p>
              <p className="text-2xl font-bold text-red-600">{stats.inactivos}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">🐾</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Total Mascotas</p>
              <p className="text-2xl font-bold text-primary-600">{stats.totalMascotas}</p>
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
            variant={filter === 'active' ? 'success' : 'outline'}
            onClick={() => setFilter('active')}
          >
            Activos ({stats.activos})
          </Button>
          <Button
            variant={filter === 'inactive' ? 'danger' : 'outline'}
            onClick={() => setFilter('inactive')}
          >
            Inactivos ({stats.inactivos})
          </Button>
        </div>
      </Card>

      {/* Tabla de usuarios */}
      <Card>
        <Table
          columns={columns}
          data={getFilteredTutores()}
          keyExtractor={(tutor) => tutor.id}
        />
      </Card>

      {/* Modal de detalles */}
      {selectedTutor && (
        <Modal
          isOpen={showDetailModal}
          onClose={() => setShowDetailModal(false)}
          title="Detalles del Usuario y Mascotas"
          size="lg"
        >
          <div className="space-y-6">
            {/* Información del Usuario */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                <span className="mr-2">👤</span>
                Información del Tutor
              </h3>
              <div className="bg-gray-50 rounded-lg p-4 space-y-2">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-600">Nombre completo</p>
                    <p className="font-medium">{selectedTutor.usuario?.nombre_completo}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Email</p>
                    <p className="font-medium">{selectedTutor.usuario?.email}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">DNI</p>
                    <p className="font-medium">{selectedTutor.dni}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Teléfono</p>
                    <p className="font-medium">{selectedTutor.usuario?.telefono}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Dirección</p>
                    <p className="font-medium">{selectedTutor.direccion}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Ciudad</p>
                    <p className="font-medium">{selectedTutor.ciudad}, {selectedTutor.provincia}</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Mascotas */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                <span className="mr-2">🐾</span>
                Mascotas ({selectedTutor.mascotas?.length || 0})
              </h3>
              {selectedTutor.mascotas && selectedTutor.mascotas.length > 0 ? (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {selectedTutor.mascotas.map((mascota) => (
                    <div key={mascota.id} className="bg-gray-50 rounded-lg p-4">
                      <div className="flex items-start space-x-3">
                        {mascota.foto_url ? (
                          <img
                            src={mascota.foto_url}
                            alt={mascota.nombre}
                            className="w-16 h-16 rounded-full object-cover"
                          />
                        ) : (
                          <div className="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center">
                            <span className="text-2xl">🐾</span>
                          </div>
                        )}
                        <div className="flex-1">
                          <div className="flex items-center justify-between mb-2">
                            <h4 className="font-semibold text-gray-900">{mascota.nombre}</h4>
                            <Badge color={mascota.estado === 'aprobado' ? 'success' : 'warning'}>
                              {mascota.estado}
                            </Badge>
                          </div>
                          <div className="space-y-1 text-sm">
                            <p className="text-gray-600">
                              <span className="font-medium">{mascota.especie}</span> • {mascota.raza}
                            </p>
                            <p className="text-gray-600">
                              {mascota.sexo} • {mascota.esterilizado ? 'Esterilizado' : 'No esterilizado'}
                            </p>
                            <p className="text-gray-600">
                              Nacimiento: {new Date(mascota.fecha_nacimiento).toLocaleDateString('es-ES')}
                            </p>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="bg-gray-50 rounded-lg p-8 text-center">
                  <span className="text-4xl">🐾</span>
                  <p className="text-gray-600 mt-2">Este tutor no tiene mascotas registradas</p>
                </div>
              )}
            </div>

            <div className="flex justify-end">
              <Button variant="outline" onClick={() => setShowDetailModal(false)}>
                Cerrar
              </Button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  )
}
