// Modelo de Mascota (Arquitectura MVC)
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
  estado: 'pendiente' | 'aprobado' | 'rechazado'
  alergias?: string
  condiciones_preexistentes?: string
  esterilizado: boolean
  activo: boolean
  created_at: string
}

export interface MascotaFormData {
  nombre: string
  especie: string
  raza?: string
  sexo?: string
  fecha_nacimiento?: string
  peso_kg?: number
  color?: string
  microchip?: string
  foto_url?: string
  alergias?: string
  condiciones_preexistentes?: string
  esterilizado?: boolean
}
