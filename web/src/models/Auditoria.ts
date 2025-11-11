// Modelo de Auditoría (Arquitectura MVC)
// Representa registro de acciones importantes del sistema

export interface Auditoria {
  id: string
  tabla: string
  registro_id: string
  accion: string
  usuario_id?: string
  datos_anteriores?: Record<string, any>
  datos_nuevos?: Record<string, any>
  direccion_ip?: string
  user_agent?: string
  created_at: string

  // Datos relacionados
  usuario_nombre?: string
}
