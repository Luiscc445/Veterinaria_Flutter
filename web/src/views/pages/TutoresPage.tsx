import { useEffect, useState } from 'react'
import { supabase } from '../../services/supabase'
import { isAdminClientAvailable, createUser } from '../../services/supabaseAdmin'
import { Card, Table, Button, Modal, Badge, Input, SuccessModal } from '../components/ui'

interface Tutor {
  id: string
  user_id: string
  dni: string
  direccion: string
  ciudad: string
  provincia: string
  created_at: string
  usuario?: {
    email: string
    nombre_completo: string
    telefono: string
    activo: boolean
  }
}

export default function TutoresPage() {
  const [tutores, setTutores] = useState<Tutor[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedTutor, setSelectedTutor] = useState<Tutor | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)
  const [showFormModal, setShowFormModal] = useState(false)
  const [showPasswordModal, setShowPasswordModal] = useState(false)
  const [showSuccessModal, setShowSuccessModal] = useState(false)
  const [successData, setSuccessData] = useState<{ email: string; password: string } | null>(null)
  const [isEditing, setIsEditing] = useState(false)
  const [agregarMascota, setAgregarMascota] = useState(false)

  // Formulario de tutor
  const [formData, setFormData] = useState({
    email: '',
    nombre_completo: '',
    telefono: '',
    dni: '',
    direccion: '',
    ciudad: '',
    provincia: '',
    password: '',
  })

  // Formulario de mascota (opcional al crear tutor)
  const [mascotaData, setMascotaData] = useState({
    nombre: '',
    especie: 'Canino',
    raza: '',
    sexo: 'Macho',
    fecha_nacimiento: '',
    peso_kg: '',
    color: '',
  })

  const [passwordData, setPasswordData] = useState({
    nueva_password: '',
    confirmar_password: '',
  })

  useEffect(() => {
    loadTutores()
  }, [])

  const loadTutores = async () => {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from('tutores')
        .select(`
          *,
          usuario:users!tutores_user_id_fkey (
            email,
            nombre_completo,
            telefono,
            activo
          )
        `)
        .order('created_at', { ascending: false })

      if (error) throw error
      setTutores(data || [])
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

  const handleCreate = () => {
    setIsEditing(false)
    setAgregarMascota(false)
    setFormData({
      email: '',
      nombre_completo: '',
      telefono: '',
      dni: '',
      direccion: '',
      ciudad: '',
      provincia: '',
      password: '',
    })
    setMascotaData({
      nombre: '',
      especie: 'Canino',
      raza: '',
      sexo: 'Macho',
      fecha_nacimiento: '',
      peso_kg: '',
      color: '',
    })
    setShowFormModal(true)
  }

  const handleEdit = (tutor: Tutor) => {
    setIsEditing(true)
    setSelectedTutor(tutor)
    setFormData({
      email: tutor.usuario?.email || '',
      nombre_completo: tutor.usuario?.nombre_completo || '',
      telefono: tutor.usuario?.telefono || '',
      dni: tutor.dni,
      direccion: tutor.direccion,
      ciudad: tutor.ciudad,
      provincia: tutor.provincia,
      password: '',
    })
    setShowFormModal(true)
  }

  const handleDelete = async (tutor: Tutor) => {
    if (!confirm(`¿Estás seguro de eliminar al tutor ${tutor.usuario?.nombre_completo}?`)) return

    try {
      // Eliminar tutor (esto también eliminará el usuario por la política de CASCADE)
      const { error: deleteTutorError } = await supabase
        .from('tutores')
        .delete()
        .eq('id', tutor.id)

      if (deleteTutorError) throw deleteTutorError

      // Eliminar usuario
      const { error: deleteUserError } = await supabase
        .from('users')
        .delete()
        .eq('id', tutor.user_id)

      if (deleteUserError) throw deleteUserError

      loadTutores()
    } catch (error) {
      console.error('Error al eliminar:', error)
      alert('Error al eliminar el tutor')
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    try {
      if (isEditing && selectedTutor) {
        // Actualizar usuario
        const { error: updateUserError } = await supabase
          .from('users')
          .update({
            email: formData.email,
            nombre_completo: formData.nombre_completo,
            telefono: formData.telefono,
          })
          .eq('id', selectedTutor.user_id)

        if (updateUserError) throw updateUserError

        // Actualizar tutor
        const { error: updateTutorError } = await supabase
          .from('tutores')
          .update({
            dni: formData.dni,
            direccion: formData.direccion,
            ciudad: formData.ciudad,
            provincia: formData.provincia,
          })
          .eq('id', selectedTutor.id)

        if (updateTutorError) throw updateTutorError
      } else {
        // Crear nuevo tutor
        if (!formData.password) {
          alert('Debes ingresar una contraseña para el nuevo tutor')
          return
        }

        if (formData.password.length < 6) {
          alert('La contraseña debe tener al menos 6 caracteres')
          return
        }

        // Verificar que el cliente admin esté disponible
        if (!isAdminClientAvailable()) {
          alert(
            '⚠️ No se puede crear tutores.\n\n' +
            'El sistema requiere configuración adicional:\n' +
            '1. Agrega VITE_SUPABASE_SERVICE_ROLE_KEY en el archivo .env\n' +
            '2. Reinicia el servidor\n\n' +
            'Consulta la documentación en database/CONFIGURAR_CAMBIO_PASSWORDS.md'
          )
          return
        }

        // 1. Crear usuario en Supabase Authentication usando cliente admin
        const createUserResult = await createUser(
          formData.email,
          formData.password,
          { nombre_completo: formData.nombre_completo }
        )

        if (!createUserResult.success) {
          throw new Error(createUserResult.error || 'Error al crear usuario en Authentication')
        }

        if (!createUserResult.userId) {
          throw new Error('No se obtuvo el ID del usuario creado')
        }

        // 2. Crear en tabla users
        const { data: userData, error: userError } = await supabase
          .from('users')
          .insert({
            auth_user_id: createUserResult.userId,
            email: formData.email,
            nombre_completo: formData.nombre_completo,
            telefono: formData.telefono,
            rol: 'tutor',
            activo: true,
          })
          .select()
          .single()

        if (userError) throw userError

        // 3. Crear tutor
        const { error: tutorError } = await supabase
          .from('tutores')
          .insert({
            user_id: userData.id,
            dni: formData.dni,
            direccion: formData.direccion,
            ciudad: formData.ciudad,
            provincia: formData.provincia,
          })

        if (tutorError) throw tutorError

        // Guardar datos para mostrar en el modal de éxito
        setSuccessData({
          email: formData.email,
          password: formData.password
        })
      }

      // Cerrar formulario
      setShowFormModal(false)

      // Recargar la lista de tutores para mostrar el nuevo tutor
      await loadTutores()

      // Mostrar modal de éxito
      setShowSuccessModal(true)
    } catch (error) {
      console.error('Error al guardar:', error)
      alert('Error al guardar el tutor')
    }
  }

  const handleToggleStatus = async (tutor: Tutor) => {
    try {
      const { error } = await supabase
        .from('users')
        .update({ activo: !tutor.usuario?.activo })
        .eq('id', tutor.user_id)

      if (error) throw error
      loadTutores()
    } catch (error) {
      console.error('Error al cambiar estado:', error)
    }
  }

  const columns = [
    {
      key: 'nombre',
      label: 'Tutor',
      render: (tutor: Tutor) => (
        <div>
          <p className="font-medium text-gray-900">{tutor.usuario?.nombre_completo || '-'}</p>
          <p className="text-sm text-gray-500">{tutor.usuario?.email || '-'}</p>
        </div>
      ),
    },
    {
      key: 'dni',
      label: 'DNI',
      render: (tutor: Tutor) => tutor.dni,
    },
    {
      key: 'telefono',
      label: 'Teléfono',
      render: (tutor: Tutor) => tutor.usuario?.telefono || '-',
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
      render: (tutor: Tutor) => `${tutor.ciudad}, ${tutor.provincia}`,
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (tutor: Tutor) => (
        <Badge variant={tutor.usuario?.activo ? 'success' : 'danger'}>
          {tutor.usuario?.activo ? 'Activo' : 'Inactivo'}
        </Badge>
      ),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (tutor: Tutor) => (
        <div className="flex space-x-2">
          <Button size="sm" variant="outline" onClick={() => viewDetails(tutor)}>
            Ver
          </Button>
          <Button size="sm" variant="secondary" onClick={() => handleEdit(tutor)}>
            Editar
          </Button>
          <Button
            size="sm"
            variant={tutor.usuario?.activo ? 'warning' : 'success'}
            onClick={() => handleToggleStatus(tutor)}
          >
            {tutor.usuario?.activo ? 'Desactivar' : 'Activar'}
          </Button>
          <Button size="sm" variant="danger" onClick={() => handleDelete(tutor)}>
            Eliminar
          </Button>
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
          <h1 className="text-3xl font-bold text-gray-900">Gestión de Tutores</h1>
          <p className="text-gray-600 mt-1">Administra los tutores de mascotas</p>
        </div>
        <Button onClick={handleCreate}>
          Agregar Tutor
        </Button>
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
                {tutores.filter(t => t.usuario?.activo).length}
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
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.usuario?.nombre_completo || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Email</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.usuario?.email || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Teléfono</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.usuario?.telefono || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">DNI</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.dni || '-'}</p>
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
                <p className="text-sm font-medium text-gray-500">Provincia</p>
                <p className="mt-1 text-sm text-gray-900">{selectedTutor.provincia || '-'}</p>
              </div>
              <div>
                <p className="text-sm font-medium text-gray-500">Estado</p>
                <div className="mt-1">
                  <Badge variant={selectedTutor.usuario?.activo ? 'success' : 'danger'}>
                    {selectedTutor.usuario?.activo ? 'Activo' : 'Inactivo'}
                  </Badge>
                </div>
              </div>
            </div>
          </div>
        </Modal>
      )}

      {/* Form Modal */}
      <Modal
        isOpen={showFormModal}
        onClose={() => setShowFormModal(false)}
        title={isEditing ? 'Editar Tutor' : 'Nuevo Tutor'}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Nombre Completo"
              value={formData.nombre_completo}
              onChange={(e) => setFormData({ ...formData, nombre_completo: e.target.value })}
              required
            />
            <Input
              label="Email"
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              required
            />
            <Input
              label="Teléfono"
              value={formData.telefono}
              onChange={(e) => setFormData({ ...formData, telefono: e.target.value })}
              required
            />
            <Input
              label="DNI"
              value={formData.dni}
              onChange={(e) => setFormData({ ...formData, dni: e.target.value })}
              required
            />
            <div className="col-span-2">
              <Input
                label="Dirección"
                value={formData.direccion}
                onChange={(e) => setFormData({ ...formData, direccion: e.target.value })}
                required
              />
            </div>
            <Input
              label="Ciudad"
              value={formData.ciudad}
              onChange={(e) => setFormData({ ...formData, ciudad: e.target.value })}
              required
            />
            <Input
              label="Provincia"
              value={formData.provincia}
              onChange={(e) => setFormData({ ...formData, provincia: e.target.value })}
              required
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

      {/* Modal de Éxito */}
      <SuccessModal
        isOpen={showSuccessModal}
        onClose={() => setShowSuccessModal(false)}
        title="¡Tutor Creado Exitosamente!"
        message="El nuevo tutor ha sido registrado correctamente en el sistema."
        details={successData ? [
          { label: 'Email', value: successData.email },
          { label: 'Contraseña', value: successData.password },
          { label: 'Tipo de Usuario', value: 'Tutor' },
          { label: 'Acceso', value: 'Aplicación Móvil' },
          { label: 'Estado', value: 'Ya puede iniciar sesión' }
        ] : []}
      />
    </div>
  )
}
