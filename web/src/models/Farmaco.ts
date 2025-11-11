// Modelo de Fármaco (Arquitectura MVC)
// Representa catálogo maestro de medicamentos veterinarios

export interface Farmaco {
  id: string
  nombre_comercial: string
  nombre_generico: string
  laboratorio?: string
  principio_activo: string
  concentracion?: string
  forma_farmaceutica?: string
  presentacion?: string
  unidad_medida?: string
  via_administracion?: string[]
  indicaciones?: string
  contraindicaciones?: string
  efectos_secundarios?: string
  dosis_recomendada?: string
  requiere_receta: boolean
  stock_minimo: number
  activo: boolean
  created_at: string
  updated_at: string
  deleted_at?: string

  // Calculado
  stock_total?: number
  estado_stock?: 'SIN STOCK' | 'BAJO' | 'NORMAL'
}

export interface FarmacoFormData {
  nombre_comercial: string
  nombre_generico: string
  laboratorio?: string
  principio_activo: string
  concentracion?: string
  forma_farmaceutica?: string
  presentacion?: string
  unidad_medida?: string
  via_administracion?: string[]
  indicaciones?: string
  contraindicaciones?: string
  efectos_secundarios?: string
  dosis_recomendada?: string
  requiere_receta?: boolean
  stock_minimo?: number
}

export interface FarmacoUpdateData {
  nombre_comercial?: string
  nombre_generico?: string
  laboratorio?: string
  principio_activo?: string
  concentracion?: string
  forma_farmaceutica?: string
  presentacion?: string
  unidad_medida?: string
  via_administracion?: string[]
  indicaciones?: string
  contraindicaciones?: string
  efectos_secundarios?: string
  dosis_recomendada?: string
  requiere_receta?: boolean
  stock_minimo?: number
  activo?: boolean
}
