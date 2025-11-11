// Modelo de Profesional (Arquitectura MVC)
// Representa médicos veterinarios

export interface HorarioAtencion {
  lunes?: { inicio: string; fin: string }
  martes?: { inicio: string; fin: string }
  miercoles?: { inicio: string; fin: string }
  jueves?: { inicio: string; fin: string }
  viernes?: { inicio: string; fin: string }
  sabado?: { inicio: string; fin: string }
  domingo?: { inicio: string; fin: string }
}

export interface Profesional {
  id: string
  user_id: string
  matricula_profesional: string
  especialidades?: string[]
  biografia?: string
  anios_experiencia?: number
  horario_atencion?: HorarioAtencion
  activo: boolean
  created_at: string
  updated_at: string
  deleted_at?: string

  // Datos relacionados del usuario
  user_nombre?: string
  user_email?: string
  user_telefono?: string
  user_avatar?: string
}

export interface ProfesionalFormData {
  user_id: string
  matricula_profesional: string
  especialidades?: string[]
  biografia?: string
  anios_experiencia?: number
  horario_atencion?: HorarioAtencion
}

export interface ProfesionalUpdateData {
  matricula_profesional?: string
  especialidades?: string[]
  biografia?: string
  anios_experiencia?: number
  horario_atencion?: HorarioAtencion
  activo?: boolean
}
