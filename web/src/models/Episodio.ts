// Modelo de Episodio (Arquitectura MVC)
// Representa consultas/eventos individuales dentro de una historia clínica

import type { TipoServicio } from './Servicio'

export interface Episodio {
  id: string
  historia_clinica_id: string
  cita_id?: string
  profesional_id: string
  fecha_episodio: string
  tipo_episodio: TipoServicio
  motivo_consulta: string
  anamnesis?: string
  examen_fisico?: string
  temperatura_celsius?: number
  frecuencia_cardiaca?: number
  frecuencia_respiratoria?: number
  peso_kg?: number
  diagnostico?: string
  plan_tratamiento?: string
  indicaciones_tutor?: string
  proxima_visita?: string
  observaciones?: string
  created_at: string
  updated_at: string
  deleted_at?: string

  // Datos relacionados
  profesional_nombre?: string
  mascota_nombre?: string
  numero_historia?: string
}

export interface EpisodioFormData {
  historia_clinica_id: string
  cita_id?: string
  profesional_id: string
  tipo_episodio: TipoServicio
  motivo_consulta: string
  anamnesis?: string
  examen_fisico?: string
  temperatura_celsius?: number
  frecuencia_cardiaca?: number
  frecuencia_respiratoria?: number
  peso_kg?: number
  diagnostico?: string
  plan_tratamiento?: string
  indicaciones_tutor?: string
  proxima_visita?: string
  observaciones?: string
}

export interface EpisodioUpdateData {
  anamnesis?: string
  examen_fisico?: string
  temperatura_celsius?: number
  frecuencia_cardiaca?: number
  frecuencia_respiratoria?: number
  peso_kg?: number
  diagnostico?: string
  plan_tratamiento?: string
  indicaciones_tutor?: string
  proxima_visita?: string
  observaciones?: string
}
