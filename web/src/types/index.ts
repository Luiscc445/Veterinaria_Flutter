export type UserRole = 'admin' | 'medico' | 'recepcion' | 'tutor'

export type EstadoMascota = 'pendiente' | 'aprobado' | 'rechazado'

export type EstadoCita = 'reservada' | 'confirmada' | 'en_sala' | 'atendida' | 'reprogramada' | 'cancelada'

export interface User {
  id: string
  auth_user_id: string
  email: string
  nombre_completo: string
  telefono?: string
  rol: UserRole
  avatar_url?: string
  activo: boolean
  created_at: string
}

export interface Tutor {
  id: string
  user_id: string
  dni?: string
  direccion?: string
  ciudad?: string
  provincia?: string
  telefono_emergencia?: string
  contacto_emergencia?: string
}

export interface Mascota {
  id: string
  tutor_id: string
  nombre: string
  especie: string
  raza?: string
  sexo?: string
  fecha_nacimiento?: string
  peso_kg?: number
  color?: string
  microchip?: string
  foto_url?: string
  estado: EstadoMascota
  alergias?: string
  condiciones_preexistentes?: string
  esterilizado: boolean
  activo: boolean
  created_at: string
}

export interface Cita {
  id: string
  mascota_id: string
  tutor_id: string
  servicio_id: string
  profesional_id: string
  consultorio_id?: string
  fecha_hora: string
  fecha_hora_fin?: string
  estado: EstadoCita
  motivo_consulta?: string
  observaciones?: string
  created_at: string
}

export interface Servicio {
  id: string
  nombre: string
  tipo: string
  descripcion?: string
  duracion_minutos: number
  precio_base?: number
  activo: boolean
}

export interface Profesional {
  id: string
  user_id: string
  matricula_profesional: string
  especialidades?: string[]
  activo: boolean
}

export interface Farmaco {
  id: string
  nombre_comercial: string
  nombre_generico: string
  laboratorio?: string
  principio_activo: string
  stock_minimo: number
  activo: boolean
}

export interface LoteFarmaco {
  id: string
  farmaco_id: string
  numero_lote: string
  fecha_vencimiento: string
  cantidad_inicial: number
  cantidad_actual: number
  precio_compra?: number
  precio_venta?: number
  activo: boolean
}
