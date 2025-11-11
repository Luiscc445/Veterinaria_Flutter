// Modelo de Historia Clínica (Arquitectura MVC)
// Representa Historia Clínica Electrónica (HCE) por mascota

export interface HistoriaClinica {
  id: string
  mascota_id: string
  numero_historia: string
  fecha_apertura: string
  observaciones_generales?: string
  created_at: string
  updated_at: string
  deleted_at?: string

  // Datos relacionados
  mascota_nombre?: string
  mascota_especie?: string
  tutor_nombre?: string
}

export interface HistoriaClinicaFormData {
  mascota_id: string
  observaciones_generales?: string
}

export interface HistoriaClinicaUpdateData {
  observaciones_generales?: string
}
