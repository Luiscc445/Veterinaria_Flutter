// Modelo de Consultorio (Arquitectura MVC)
// Representa salas de atención veterinaria

export interface Consultorio {
  id: string
  nombre: string
  numero: string
  piso?: string
  equipamiento?: string[]
  capacidad: number
  activo: boolean
  created_at: string
  updated_at: string
  deleted_at?: string
}

export interface ConsultorioFormData {
  nombre: string
  numero: string
  piso?: string
  equipamiento?: string[]
  capacidad?: number
}

export interface ConsultorioUpdateData {
  nombre?: string
  numero?: string
  piso?: string
  equipamiento?: string[]
  capacidad?: number
  activo?: boolean
}
