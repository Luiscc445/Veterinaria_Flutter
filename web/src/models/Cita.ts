// Modelo de Cita (Arquitectura MVC)
export interface Cita {
  id: string
  mascota_id: string
  tutor_id: string
  servicio_id: string
  profesional_id: string
  consultorio_id?: string
  fecha_hora: string
  fecha_hora_fin?: string
  estado: 'reservada' | 'confirmada' | 'en_sala' | 'atendida' | 'reprogramada' | 'cancelada'
  motivo_consulta?: string
  observaciones?: string
  created_at: string
  // Datos relacionados
  mascota_nombre?: string
  mascota_especie?: string
  servicio_nombre?: string
  profesional_nombre?: string
}

export interface CitaFormData {
  mascota_id: string
  servicio_id: string
  profesional_id: string
  fecha_hora: string
  motivo_consulta?: string
}
