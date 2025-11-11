// Modelo de Consumo de Fármaco (Arquitectura MVC)
// Representa prescripciones y consumos por episodio

export interface ConsumoFarmaco {
  id: string
  episodio_id: string
  mascota_id: string
  farmaco_id: string
  lote_farmaco_id?: string
  cantidad: number
  unidad: string
  dosis_indicada: string
  frecuencia: string
  duracion_dias?: number
  via_administracion: string
  indicaciones_especiales?: string
  prescrito_por: string
  fecha_prescripcion: string
  descontado_inventario: boolean
  fecha_descuento?: string
  created_at: string
  updated_at: string

  // Datos relacionados
  farmaco_nombre?: string
  mascota_nombre?: string
  profesional_nombre?: string
}

export interface ConsumoFarmacoFormData {
  episodio_id: string
  mascota_id: string
  farmaco_id: string
  lote_farmaco_id?: string
  cantidad: number
  unidad: string
  dosis_indicada: string
  frecuencia: string
  duracion_dias?: number
  via_administracion: string
  indicaciones_especiales?: string
  prescrito_por: string
}

export interface ConsumoFarmacoUpdateData {
  cantidad?: number
  dosis_indicada?: string
  frecuencia?: string
  duracion_dias?: number
  indicaciones_especiales?: string
}
