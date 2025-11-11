// Modelo de Adjunto (Arquitectura MVC)
// Representa archivos, imágenes, documentos adjuntos

export interface Adjunto {
  id: string
  episodio_id?: string
  mascota_id?: string
  tipo_adjunto: string
  nombre_archivo: string
  url_archivo: string
  tamano_bytes?: number
  mime_type?: string
  descripcion?: string
  subido_por?: string
  created_at: string
  deleted_at?: string

  // Datos relacionados
  subido_por_nombre?: string
}

export interface AdjuntoFormData {
  episodio_id?: string
  mascota_id?: string
  tipo_adjunto: string
  nombre_archivo: string
  url_archivo: string
  tamano_bytes?: number
  mime_type?: string
  descripcion?: string
}
