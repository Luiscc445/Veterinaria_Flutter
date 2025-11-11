import { useState, useEffect } from 'react'
import { supabase } from '../../services/supabase'
import { isAdminClientAvailable, updateUserPassword, createUser } from '../../services/supabaseAdmin'
import { Card, Button, Badge, Modal, Table, Input, Select } from '../components/ui'

interface PersonalUsuario {
  id: string
  auth_user_id: string | null
  email: string
  nombre_completo: string
  telefono: string
  rol: 'admin' | 'medico' | 'laboratorista' | 'ecografista' | 'recepcion'
  activo: boolean
  created_at: string
  profesional?: {
    id: string
    matricula_profesional: string
    especialidades: string[]
  }
}

export default function PersonalPage() {
  const [personal, setPersonal] = useState<PersonalUsuario[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedPersonal, setSelectedPersonal] = useState<PersonalUsuario | null>(null)
  const [showDetailModal, setShowDetailModal] = useState(false)
  const [showFormModal, setShowFormModal] = useState(false)
  const [showPasswordModal, setShowPasswordModal] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const [filter, setFilter] = useState<'all' | 'medico' | 'laboratorista' | 'ecografista'>('all')

  const [formData, setFormData] = useState({
    email: '',
    nombre_completo: '',
    telefono: '',
    rol: 'medico' as 'medico' | 'laboratorista' | 'ecografista' | 'recepcion',
    password: '',
    matricula_profesional: '',
    especialidades: '',
  })

  const [passwordData, setPasswordData] = useState({
    nueva_password: '',
    confirmar_password: '',
  })

  useEffect(() => {
    loadPersonal()
  }, [])

  const loadPersonal = async () => {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from('users')
        .select(`
          *,
          profesional:profesionales (
            id,
            matricula_profesional,
            especialidades
          )
        `)
        .in('rol', ['medico', 'laboratorista', 'ecografista', 'recepcion', 'admin'])
        .order('created_at', { ascending: false })

      if (error) throw error
      setPersonal(data || [])
    } catch (error) {
      console.error('Error loading personal:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleCreate = () => {
    setIsEditing(false)
    setFormData({
      email: '',
      nombre_completo: '',
      telefono: '',
      rol: 'medico',
      password: '',
      matricula_profesional: '',
      especialidades: '',
    })
    setShowFormModal(true)
  }

  const handleEdit = (person: PersonalUsuario) => {
    setIsEditing(true)
    setSelectedPersonal(person)
    setFormData({
      email: person.email,
      nombre_completo: person.nombre_completo,
      telefono: person.telefono,
      rol: person.rol as any,
      password: '',
      matricula_profesional: person.profesional?.matricula_profesional || '',
      especialidades: person.profesional?.especialidades?.join(', ') || '',
    })
    setShowFormModal(true)
  }

  const handleDelete = async (person: PersonalUsuario) => {
    if (!confirm(`¿Estás seguro de eliminar a ${person.nombre_completo}?`)) return

    try {
      // Si es médico, eliminar primero el registro de profesionales
      if (person.profesional) {
        await supabase.from('profesionales').delete().eq('user_id', person.id)
      }

      // Eliminar usuario
      const { error } = await supabase.from('users').delete().eq('id', person.id)
      if (error) throw error

      loadPersonal()
    } catch (error) {
      console.error('Error al eliminar:', error)
      alert('Error al eliminar el personal')
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    try {
      if (isEditing && selectedPersonal) {
        // Actualizar usuario existente
        const { error: updateError } = await supabase
          .from('users')
          .update({
            email: formData.email,
            nombre_completo: formData.nombre_completo,
            telefono: formData.telefono,
            rol: formData.rol,
          })
          .eq('id', selectedPersonal.id)

        if (updateError) throw updateError

        // Si es médico y tiene matrícula, actualizar profesional
        if (formData.rol === 'medico' && formData.matricula_profesional) {
          const especialidadesArray = formData.especialidades
            .split(',')
            .map(e => e.trim())
            .filter(e => e)

          if (selectedPersonal.profesional) {
            await supabase
              .from('profesionales')
              .update({
                matricula_profesional: formData.matricula_profesional,
                especialidades: especialidadesArray,
              })
              .eq('user_id', selectedPersonal.id)
          } else {
            await supabase.from('profesionales').insert({
              user_id: selectedPersonal.id,
              matricula_profesional: formData.matricula_profesional,
              especialidades: especialidadesArray,
              activo: true,
            })
          }
        }
      } else {
        // Crear nuevo usuario
        if (!formData.password) {
          alert('Debes ingresar una contraseña')
          return
        }

        if (formData.password.length < 6) {
          alert('La contraseña debe tener al menos 6 caracteres')
          return
        }

        // Verificar que el cliente admin esté disponible
        console.log('🔍 Verificando cliente admin disponible:', isAdminClientAvailable())

        if (!isAdminClientAvailable()) {
          const mensaje =
            '⚠️ No se puede crear usuarios.\n\n' +
            'El sistema requiere configuración adicional:\n' +
            '1. Verifica que VITE_SUPABASE_SERVICE_ROLE_KEY esté en .env\n' +
            '2. Reinicia el servidor (npm run dev)\n' +
            '3. Verifica que la clave sea correcta\n\n' +
            'Estado actual: Cliente admin NO disponible'

          console.error(mensaje)
          alert(mensaje)
          return
        }

        console.log('✅ Cliente admin disponible. Creando usuario...')

        // 1. Crear usuario en Supabase Authentication usando cliente admin
        const createUserResult = await createUser(
          formData.email,
          formData.password,
          { nombre_completo: formData.nombre_completo }
        )

        console.log('📊 Resultado de createUser:', createUserResult)

        if (!createUserResult.success) {
          const error = createUserResult.error || 'Error al crear usuario en Authentication'
          console.error('❌ Error en createUser:', error)
          throw new Error(error)
        }

        if (!createUserResult.userId) {
          console.error('❌ No se obtuvo userId')
          throw new Error('No se obtuvo el ID del usuario creado')
        }

        console.log('✅ Usuario creado en auth.users con ID:', createUserResult.userId)

        // 2. Crear en tabla users con el auth_user_id
        console.log('📝 Insertando en tabla users...')
        const { data: userData, error: userError } = await supabase
          .from('users')
          .insert({
            auth_user_id: createUserResult.userId,
            email: formData.email,
            nombre_completo: formData.nombre_completo,
            telefono: formData.telefono,
            rol: formData.rol,
            activo: true,
          })
          .select()
          .single()

        if (userError) {
          console.error('❌ Error al insertar en users:', userError)
          throw userError
        }

        console.log('✅ Usuario insertado en tabla users:', userData)

        // 3. Si es médico, crear en profesionales
        if (formData.rol === 'medico' && formData.matricula_profesional) {
          const especialidadesArray = formData.especialidades
            .split(',')
            .map(e => e.trim())
            .filter(e => e)

          console.log('📝 Insertando en tabla profesionales...')
          console.log('   - user_id:', userData.id)
          console.log('   - matricula:', formData.matricula_profesional)
          console.log('   - especialidades:', especialidadesArray)

          const { error: profError } = await supabase.from('profesionales').insert({
            user_id: userData.id,
            matricula_profesional: formData.matricula_profesional,
            especialidades: especialidadesArray,
            activo: true,
          })

          if (profError) {
            console.error('❌ Error al insertar en profesionales:', profError)
            throw profError
          }

          console.log('✅ Profesional insertado correctamente')
        }

        console.log('🎉 PROCESO COMPLETO - Usuario creado exitosamente')
        alert(`✅ Usuario creado exitosamente!\n\nEmail: ${formData.email}\nContraseña: ${formData.password}\n\nEl usuario ya puede iniciar sesión en el sistema.`)
      }

      setShowFormModal(false)
      loadPersonal()
    } catch (error: any) {
      console.error('Error al guardar:', error)

      // Mostrar error detallado
      let errorMessage = 'Error al guardar el personal'

      if (error.message) {
        errorMessage += `:\n${error.message}`
      }

      if (error.details) {
        errorMessage += `\n\nDetalles: ${error.details}`
      }

      if (error.hint) {
        errorMessage += `\n\nSugerencia: ${error.hint}`
      }

      alert(errorMessage)
    }
  }

  const handleChangePassword = (person: PersonalUsuario) => {
    setSelectedPersonal(person)
    setPasswordData({ nueva_password: '', confirmar_password: '' })
    setShowPasswordModal(true)
  }

  const handlePasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (passwordData.nueva_password !== passwordData.confirmar_password) {
      alert('Las contraseñas no coinciden')
      return
    }

    if (passwordData.nueva_password.length < 6) {
      alert('La contraseña debe tener al menos 6 caracteres')
      return
    }

    if (!selectedPersonal?.auth_user_id) {
      alert('⚠️ Este usuario no tiene cuenta de autenticación. No se puede cambiar la contraseña.')
      return
    }

    try {
      // Intentar cambiar la contraseña usando el cliente admin
      if (isAdminClientAvailable()) {
        const result = await updateUserPassword(
          selectedPersonal.auth_user_id,
          passwordData.nueva_password
        )

        if (result.success) {
          alert(
            `✅ Contraseña actualizada exitosamente!\n\n` +
            `Usuario: ${selectedPersonal.email}\n` +
            `Nueva contraseña: ${passwordData.nueva_password}\n\n` +
            `El usuario ya puede iniciar sesión con la nueva contraseña.`
          )
          setShowPasswordModal(false)
          return
        } else {
          throw new Error(result.error || 'Error desconocido al actualizar contraseña')
        }
      } else {
        // Si no hay cliente admin, ofrecer método alternativo
        throw new Error('ADMIN_CLIENT_NOT_CONFIGURED')
      }
    } catch (error: any) {
      console.error('Error al cambiar contraseña:', error)

      // Si el cliente admin no está configurado o hay error, ofrecer alternativa
      const mensaje = error.message === 'ADMIN_CLIENT_NOT_CONFIGURED'
        ? `⚠️ El cambio directo de contraseñas requiere configuración adicional.\n\n` +
          `Para habilitar esta función:\n` +
          `1. Copia tu Service Role Key de Supabase\n` +
          `2. Agrégala en el archivo .env como VITE_SUPABASE_SERVICE_ROLE_KEY\n\n` +
          `ALTERNATIVA ACTUAL:\n` +
          `¿Quieres enviar un link de recuperación por email?\n\n` +
          `Se enviará a: ${selectedPersonal?.email}`
        : `❌ Error: ${error.message}\n\n` +
          `¿Quieres intentar con el método de link de recuperación?\n\n` +
          `Se enviará un email a: ${selectedPersonal?.email}`

      const usarLinkRecuperacion = confirm(mensaje)

      if (usarLinkRecuperacion) {
        try {
          const { error: resetError } = await supabase.auth.resetPasswordForEmail(
            selectedPersonal!.email,
            {
              redirectTo: `${window.location.origin}/reset-password`,
            }
          )

          if (resetError) throw resetError

          alert(
            `✅ Link de recuperación enviado!\n\n` +
            `Se ha enviado un correo a ${selectedPersonal?.email}\n\n` +
            `El usuario debe:\n` +
            `1. Revisar su email\n` +
            `2. Hacer clic en el link\n` +
            `3. Ingresar su nueva contraseña`
          )
          setShowPasswordModal(false)
        } catch (resetError: any) {
          alert(`❌ Error al enviar link de recuperación: ${resetError.message}`)
        }
      }
    }
  }

  const handleToggleStatus = async (person: PersonalUsuario) => {
    try {
      const { error } = await supabase
        .from('users')
        .update({ activo: !person.activo })
        .eq('id', person.id)

      if (error) throw error
      loadPersonal()
    } catch (error) {
      console.error('Error al cambiar estado:', error)
    }
  }

  const getFilteredPersonal = () => {
    if (filter === 'all') return personal
    return personal.filter(p => p.rol === filter)
  }

  const columns = [
    {
      key: 'nombre',
      label: 'Personal',
      render: (person: PersonalUsuario) => (
        <div>
          <p className="font-medium text-gray-900">{person.nombre_completo}</p>
          <p className="text-sm text-gray-500">{person.email}</p>
        </div>
      ),
    },
    {
      key: 'rol',
      label: 'Rol',
      render: (person: PersonalUsuario) => (
        <Badge
          variant={
            person.rol === 'admin' ? 'danger' :
            person.rol === 'medico' ? 'primary' :
            person.rol === 'laboratorista' ? 'warning' : 'secondary'
          }
        >
          {person.rol === 'medico' ? 'Veterinario' :
           person.rol === 'laboratorista' ? 'Laboratorista' :
           person.rol === 'ecografista' ? 'Ecografista' :
           person.rol === 'recepcion' ? 'Recepción' : 'Admin'}
        </Badge>
      ),
    },
    {
      key: 'telefono',
      label: 'Teléfono',
      render: (person: PersonalUsuario) => person.telefono,
    },
    {
      key: 'matricula',
      label: 'Matrícula',
      render: (person: PersonalUsuario) => person.profesional?.matricula_profesional || '-',
    },
    {
      key: 'estado',
      label: 'Estado',
      render: (person: PersonalUsuario) => (
        <Badge variant={person.activo ? 'success' : 'danger'}>
          {person.activo ? 'Activo' : 'Inactivo'}
        </Badge>
      ),
    },
    {
      key: 'acciones',
      label: 'Acciones',
      render: (person: PersonalUsuario) => (
        <div className="flex space-x-2">
          <Button size="sm" variant="outline" onClick={() => handleEdit(person)}>
            Editar
          </Button>
          <Button size="sm" variant="secondary" onClick={() => handleChangePassword(person)}>
            Contraseña
          </Button>
          <Button
            size="sm"
            variant={person.activo ? 'warning' : 'success'}
            onClick={() => handleToggleStatus(person)}
          >
            {person.activo ? 'Desactivar' : 'Activar'}
          </Button>
          <Button size="sm" variant="danger" onClick={() => handleDelete(person)}>
            Eliminar
          </Button>
        </div>
      ),
    },
  ]

  const stats = {
    total: personal.length,
    medicos: personal.filter(p => p.rol === 'medico').length,
    laboratoristas: personal.filter(p => p.rol === 'laboratorista').length,
    ecografistas: personal.filter(p => p.rol === 'ecografista').length,
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-600">Cargando personal...</div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Gestión de Personal</h1>
          <p className="text-gray-600 mt-2">Administra el personal del sistema (veterinarios, laboratoristas, ecografistas)</p>
        </div>
        <Button onClick={handleCreate}>
          Agregar Personal
        </Button>
      </div>

      {/* Estadísticas */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">👥</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Total Personal</p>
              <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">👨‍⚕️</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Veterinarios</p>
              <p className="text-2xl font-bold text-green-600">{stats.medicos}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">🔬</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Laboratoristas</p>
              <p className="text-2xl font-bold text-yellow-600">{stats.laboratoristas}</p>
            </div>
          </div>
        </Card>

        <Card hover>
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0 w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
              <span className="text-2xl">📡</span>
            </div>
            <div>
              <p className="text-sm text-gray-600">Ecografistas</p>
              <p className="text-2xl font-bold text-purple-600">{stats.ecografistas}</p>
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
            variant={filter === 'medico' ? 'success' : 'outline'}
            onClick={() => setFilter('medico')}
          >
            Veterinarios ({stats.medicos})
          </Button>
          <Button
            variant={filter === 'laboratorista' ? 'warning' : 'outline'}
            onClick={() => setFilter('laboratorista')}
          >
            Laboratoristas ({stats.laboratoristas})
          </Button>
          <Button
            variant={filter === 'ecografista' ? 'secondary' : 'outline'}
            onClick={() => setFilter('ecografista')}
          >
            Ecografistas ({stats.ecografistas})
          </Button>
        </div>
      </Card>

      {/* Tabla */}
      <Card>
        <Table
          columns={columns}
          data={getFilteredPersonal()}
          keyExtractor={(person) => person.id}
        />
      </Card>

      {/* Modal de Formulario */}
      <Modal
        isOpen={showFormModal}
        onClose={() => setShowFormModal(false)}
        title={isEditing ? 'Editar Personal' : 'Nuevo Personal'}
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
            <Select
              label="Rol"
              value={formData.rol}
              onChange={(e) => setFormData({ ...formData, rol: e.target.value as any })}
              required
            >
              <option value="medico">Veterinario</option>
              <option value="laboratorista">Laboratorista</option>
              <option value="ecografista">Ecografista</option>
              <option value="recepcion">Recepción</option>
            </Select>

            {!isEditing && (
              <div className="col-span-2">
                <Input
                  label="Contraseña"
                  type="password"
                  value={formData.password}
                  onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                  required={!isEditing}
                  placeholder="Mínimo 6 caracteres"
                />
                <p className="text-xs text-gray-500 mt-1">
                  Anota esta contraseña. Deberás crearla manualmente en Supabase Authentication.
                </p>
              </div>
            )}
          </div>

          {formData.rol === 'medico' && (
            <div className="border-t pt-4 mt-4">
              <h3 className="font-semibold text-gray-900 mb-3">Datos del Veterinario</h3>
              <div className="grid grid-cols-2 gap-4">
                <Input
                  label="Matrícula Profesional"
                  value={formData.matricula_profesional}
                  onChange={(e) => setFormData({ ...formData, matricula_profesional: e.target.value })}
                  required={formData.rol === 'medico'}
                />
                <Input
                  label="Especialidades (separadas por coma)"
                  value={formData.especialidades}
                  onChange={(e) => setFormData({ ...formData, especialidades: e.target.value })}
                  placeholder="Medicina General, Cirugía"
                />
              </div>
            </div>
          )}

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

      {/* Modal de Cambiar Contraseña */}
      <Modal
        isOpen={showPasswordModal}
        onClose={() => setShowPasswordModal(false)}
        title="Cambiar Contraseña"
        size="md"
      >
        <form onSubmit={handlePasswordSubmit} className="space-y-4">
          <div className="bg-blue-50 border border-blue-200 p-3 rounded-lg mb-4">
            <p className="text-sm text-blue-800">
              <strong>Usuario:</strong> {selectedPersonal?.nombre_completo}
            </p>
            <p className="text-sm text-blue-800">
              <strong>Email:</strong> {selectedPersonal?.email}
            </p>
          </div>

          <Input
            label="Nueva Contraseña"
            type="password"
            value={passwordData.nueva_password}
            onChange={(e) => setPasswordData({ ...passwordData, nueva_password: e.target.value })}
            required
            placeholder="Mínimo 6 caracteres"
          />

          <Input
            label="Confirmar Contraseña"
            type="password"
            value={passwordData.confirmar_password}
            onChange={(e) => setPasswordData({ ...passwordData, confirmar_password: e.target.value })}
            required
            placeholder="Repite la contraseña"
          />

          <div className="bg-yellow-50 border border-yellow-200 p-3 rounded-lg">
            <p className="text-xs text-yellow-800">
              ⚠️ Deberás cambiar la contraseña manualmente en Supabase Dashboard
            </p>
          </div>

          <div className="flex justify-end space-x-3 pt-4">
            <Button type="button" variant="outline" onClick={() => setShowPasswordModal(false)}>
              Cancelar
            </Button>
            <Button type="submit">
              Cambiar Contraseña
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
