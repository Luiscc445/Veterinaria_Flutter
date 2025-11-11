// Modelo de Tutor (Arquitectura MVC)
// Representa dueños/responsables de mascotas

export interface Tutor {
  id: string
  user_id: string
  dni?: string
  direccion?: string
  ciudad?: string
  provincia?: string
  codigo_postal?: string
  contacto_emergencia?: string
  telefono_emergencia?: string
  notas?: string
  created_at: string
  updated_at: string
  deleted_at?: string

  // Datos relacionados del usuario
  user_email?: string
  user_nombre?: string
  user_telefono?: string
}

export interface TutorFormData {
  user_id: string
  dni?: string
  direccion?: string
  ciudad?: string
  provincia?: string
  codigo_postal?: string
  contacto_emergencia?: string
  telefono_emergencia?: string
  notas?: string
}

export interface TutorUpdateData {
  dni?: string
  direccion?: string
  ciudad?: string
  provincia?: string
  codigo_postal?: string
  contacto_emergencia?: string
  telefono_emergencia?: string
  notas?: string
}
