// Controlador de Lotes de Fármacos (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type { LoteFarmaco, LoteFarmacoFormData, LoteFarmacoUpdateData } from '../models/LoteFarmaco'

export class LotesFarmacosController {
  /**
   * Obtener todos los lotes
   */
  static async getAll(soloActivos = false): Promise<LoteFarmaco[]> {
    try {
      let query = supabase
        .from('lotes_farmacos')
        .select(`
          *,
          farmaco:farmacos(nombre_comercial, nombre_generico)
        `)
        .is('deleted_at', null)
        .order('fecha_vencimiento', { ascending: true })

      if (soloActivos) {
        query = query.eq('activo', true).gt('cantidad_actual', 0)
      }

      const { data, error } = await query
      if (error) throw error

      return (data || []).map((lote: any) => ({
        ...lote,
        farmaco_nombre: lote.farmaco?.nombre_comercial,
        farmaco_generico: lote.farmaco?.nombre_generico,
        dias_para_vencer: this.calcularDiasParaVencer(lote.fecha_vencimiento),
        estado_vencimiento: this.calcularEstadoVencimiento(lote.fecha_vencimiento),
      }))
    } catch (error) {
      console.error('Error en LotesFarmacosController.getAll:', error)
      throw error
    }
  }

  /**
   * Obtener lote por ID
   */
  static async getById(id: string): Promise<LoteFarmaco | null> {
    try {
      const { data, error } = await supabase
        .from('lotes_farmacos')
        .select(`
          *,
          farmaco:farmacos(nombre_comercial, nombre_generico)
        `)
        .eq('id', id)
        .is('deleted_at', null)
        .single()

      if (error) throw error

      return {
        ...data,
        farmaco_nombre: data.farmaco?.nombre_comercial,
        farmaco_generico: data.farmaco?.nombre_generico,
        dias_para_vencer: this.calcularDiasParaVencer(data.fecha_vencimiento),
        estado_vencimiento: this.calcularEstadoVencimiento(data.fecha_vencimiento),
      }
    } catch (error) {
      console.error('Error en LotesFarmacosController.getById:', error)
      throw error
    }
  }

  /**
   * Obtener lotes por fármaco
   */
  static async getByFarmaco(farmacoId: string): Promise<LoteFarmaco[]> {
    try {
      const { data, error } = await supabase
        .from('lotes_farmacos')
        .select('*')
        .eq('farmaco_id', farmacoId)
        .eq('activo', true)
        .gt('cantidad_actual', 0)
        .is('deleted_at', null)
        .order('fecha_vencimiento', { ascending: true })

      if (error) throw error

      return (data || []).map((lote: any) => ({
        ...lote,
        dias_para_vencer: this.calcularDiasParaVencer(lote.fecha_vencimiento),
        estado_vencimiento: this.calcularEstadoVencimiento(lote.fecha_vencimiento),
      }))
    } catch (error) {
      console.error('Error en LotesFarmacosController.getByFarmaco:', error)
      throw error
    }
  }

  /**
   * Obtener lotes por vencer o vencidos
   */
  static async getLotesPorVencer(diasAdelante = 90): Promise<LoteFarmaco[]> {
    try {
      const { data, error } = await supabase.rpc('obtener_lotes_vencimiento', {
        dias_adelante: diasAdelante,
      })

      if (error) throw error

      return (data || []).map((lote: any) => ({
        id: lote.lote_id,
        farmaco_nombre: lote.farmaco_nombre,
        numero_lote: lote.numero_lote,
        fecha_vencimiento: lote.fecha_vencimiento,
        cantidad_actual: lote.cantidad_actual,
        dias_para_vencer: lote.dias_para_vencer,
        estado_vencimiento: lote.estado_vencimiento,
      }))
    } catch (error) {
      console.error('Error en LotesFarmacosController.getLotesPorVencer:', error)
      throw error
    }
  }

  /**
   * Crear nuevo lote
   */
  static async create(loteData: LoteFarmacoFormData): Promise<string> {
    try {
      const { data, error } = await supabase
        .from('lotes_farmacos')
        .insert({
          ...loteData,
          activo: true,
        })
        .select('id')
        .single()

      if (error) throw error
      return data.id
    } catch (error) {
      console.error('Error en LotesFarmacosController.create:', error)
      throw error
    }
  }

  /**
   * Actualizar lote
   */
  static async update(id: string, updateData: LoteFarmacoUpdateData): Promise<void> {
    try {
      const { error } = await supabase.from('lotes_farmacos').update(updateData).eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en LotesFarmacosController.update:', error)
      throw error
    }
  }

  /**
   * Eliminar lote (soft delete)
   */
  static async delete(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('lotes_farmacos')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en LotesFarmacosController.delete:', error)
      throw error
    }
  }

  /**
   * Calcular días para vencer
   */
  private static calcularDiasParaVencer(fechaVencimiento: string): number {
    const hoy = new Date()
    const vencimiento = new Date(fechaVencimiento)
    const diferencia = vencimiento.getTime() - hoy.getTime()
    return Math.ceil(diferencia / (1000 * 60 * 60 * 24))
  }

  /**
   * Calcular estado de vencimiento
   */
  private static calcularEstadoVencimiento(
    fechaVencimiento: string
  ): 'VENCIDO' | 'CRÍTICO' | 'ALERTA' | 'VIGENTE' {
    const dias = this.calcularDiasParaVencer(fechaVencimiento)

    if (dias < 0) return 'VENCIDO'
    if (dias <= 30) return 'CRÍTICO'
    if (dias <= 90) return 'ALERTA'
    return 'VIGENTE'
  }

  /**
   * Obtener estadísticas
   */
  static async getStats(): Promise<{
    total: number
    activos: number
    vencidos: number
    por_vencer: number
  }> {
    try {
      const { data, error } = await supabase
        .from('lotes_farmacos')
        .select('fecha_vencimiento, activo, cantidad_actual')
        .is('deleted_at', null)

      if (error) throw error

      const ahora = new Date()
      const en30Dias = new Date()
      en30Dias.setDate(en30Dias.getDate() + 30)

      const vencidos = data.filter(
        (l: any) => new Date(l.fecha_vencimiento) < ahora && l.cantidad_actual > 0
      ).length

      const porVencer = data.filter(
        (l: any) =>
          new Date(l.fecha_vencimiento) >= ahora &&
          new Date(l.fecha_vencimiento) <= en30Dias &&
          l.cantidad_actual > 0
      ).length

      return {
        total: data.length,
        activos: data.filter((l: any) => l.activo && l.cantidad_actual > 0).length,
        vencidos,
        por_vencer: porVencer,
      }
    } catch (error) {
      console.error('Error en LotesFarmacosController.getStats:', error)
      throw error
    }
  }
}
