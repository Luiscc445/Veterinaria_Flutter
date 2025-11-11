// Modelo de Movimiento de Inventario (Arquitectura MVC)
// Representa trazabilidad completa de entradas/salidas

export type TipoMovimientoInventario =
  | 'entrada'
  | 'salida'
  | 'consumo'
  | 'ajuste'
  | 'vencimiento'
  | 'devolucion'

export interface InventarioMovimiento {
  id: string
  lote_farmaco_id: string
  tipo_movimiento: TipoMovimientoInventario
  cantidad: number
  cantidad_anterior: number
  cantidad_posterior: number
  motivo?: string
  documento_referencia?: string
  realizado_por?: string
  created_at: string

  // Datos relacionados
  farmaco_nombre?: string
  lote_numero?: string
  usuario_nombre?: string
}

export interface InventarioMovimientoFormData {
  lote_farmaco_id: string
  tipo_movimiento: TipoMovimientoInventario
  cantidad: number
  motivo?: string
  documento_referencia?: string
}
