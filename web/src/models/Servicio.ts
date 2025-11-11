// Modelo de Servicio (Arquitectura MVC)
// Representa catálogo de servicios veterinarios

export type TipoServicio =
  | 'consulta_general'
  | 'vacunacion'
  | 'desparasitacion'
  | 'cirugia'
  | 'emergencia'
  | 'control'
  | 'estetica'
  | 'laboratorio'
  | 'hospitalizacion'
  | 'eutanasia'

export interface Servicio {
  id: string
  nombre: string
  tipo: TipoServicio
  descripcion?: string
  duracion_minutos: number
  precio_base?: number
  requiere_especializacion: boolean
  activo: boolean
  created_at: string
  updated_at: string
  deleted_at?: string
}

export interface ServicioFormData {
  nombre: string
  tipo: TipoServicio
  descripcion?: string
  duracion_minutos: number
  precio_base?: number
  requiere_especializacion?: boolean
}

export interface ServicioUpdateData {
  nombre?: string
  tipo?: TipoServicio
  descripcion?: string
  duracion_minutos?: number
  precio_base?: number
  requiere_especializacion?: boolean
  activo?: boolean
}
