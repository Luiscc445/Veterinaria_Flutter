// Modelo de Lote de Fármaco (Arquitectura MVC)
// Representa control de stock, lotes y vencimientos

export interface LoteFarmaco {
  id: string
  farmaco_id: string
  numero_lote: string
  fecha_vencimiento: string
  cantidad_inicial: number
  cantidad_actual: number
  precio_compra?: number
  precio_venta?: number
  proveedor?: string
  fecha_ingreso: string
  ubicacion_almacen?: string
  activo: boolean
  created_at: string
  updated_at: string
  deleted_at?: string

  // Datos relacionados
  farmaco_nombre?: string
  farmaco_generico?: string

  // Calculados
  dias_para_vencer?: number
  estado_vencimiento?: 'VENCIDO' | 'CRÍTICO' | 'ALERTA' | 'VIGENTE'
}

export interface LoteFarmacoFormData {
  farmaco_id: string
  numero_lote: string
  fecha_vencimiento: string
  cantidad_inicial: number
  cantidad_actual: number
  precio_compra?: number
  precio_venta?: number
  proveedor?: string
  fecha_ingreso?: string
  ubicacion_almacen?: string
}

export interface LoteFarmacoUpdateData {
  numero_lote?: string
  fecha_vencimiento?: string
  cantidad_actual?: number
  precio_compra?: number
  precio_venta?: number
  proveedor?: string
  ubicacion_almacen?: string
  activo?: boolean
}
