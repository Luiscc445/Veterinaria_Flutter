// Controlador de Inventario (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type {
  InventarioMovimiento,
  InventarioMovimientoFormData,
} from '../models/InventarioMovimiento'

export class InventarioController {
  /**
   * Obtener todos los movimientos de inventario
   */
  static async getMovimientos(limite = 100): Promise<InventarioMovimiento[]> {
    try {
      const { data, error } = await supabase
        .from('inventario_movimientos')
        .select(`
          *,
          lote:lotes_farmacos(numero_lote, farmaco:farmacos(nombre_comercial)),
          usuario:users(nombre_completo)
        `)
        .order('created_at', { ascending: false })
        .limit(limite)

      if (error) throw error

      return (data || []).map((mov: any) => ({
        ...mov,
        farmaco_nombre: mov.lote?.farmaco?.nombre_comercial,
        lote_numero: mov.lote?.numero_lote,
        usuario_nombre: mov.usuario?.nombre_completo,
      }))
    } catch (error) {
      console.error('Error en InventarioController.getMovimientos:', error)
      throw error
    }
  }

  /**
   * Obtener movimientos por lote
   */
  static async getMovimientosByLote(loteId: string): Promise<InventarioMovimiento[]> {
    try {
      const { data, error } = await supabase
        .from('inventario_movimientos')
        .select(`
          *,
          usuario:users(nombre_completo)
        `)
        .eq('lote_farmaco_id', loteId)
        .order('created_at', { ascending: false })

      if (error) throw error

      return (data || []).map((mov: any) => ({
        ...mov,
        usuario_nombre: mov.usuario?.nombre_completo,
      }))
    } catch (error) {
      console.error('Error en InventarioController.getMovimientosByLote:', error)
      throw error
    }
  }

  /**
   * Registrar movimiento de inventario
   */
  static async registrarMovimiento(movimientoData: InventarioMovimientoFormData): Promise<string> {
    try {
      // Obtener cantidad actual del lote
      const { data: loteData, error: loteError } = await supabase
        .from('lotes_farmacos')
        .select('cantidad_actual')
        .eq('id', movimientoData.lote_farmaco_id)
        .single()

      if (loteError) throw loteError

      const cantidadAnterior = loteData.cantidad_actual
      let cantidadPosterior = cantidadAnterior

      // Calcular nueva cantidad según tipo de movimiento
      switch (movimientoData.tipo_movimiento) {
        case 'entrada':
          cantidadPosterior = cantidadAnterior + movimientoData.cantidad
          break
        case 'salida':
        case 'consumo':
        case 'vencimiento':
          cantidadPosterior = cantidadAnterior - movimientoData.cantidad
          break
        case 'ajuste':
          cantidadPosterior = movimientoData.cantidad // Ajuste absoluto
          break
        case 'devolucion':
          cantidadPosterior = cantidadAnterior + movimientoData.cantidad
          break
      }

      // Verificar que no quede negativo
      if (cantidadPosterior < 0) {
        throw new Error('Stock insuficiente para realizar el movimiento')
      }

      // Obtener usuario actual
      const { data: userData } = await supabase.auth.getUser()
      const { data: currentUser } = await supabase
        .from('users')
        .select('id')
        .eq('auth_user_id', userData?.user?.id)
        .single()

      // Registrar movimiento
      const { data, error } = await supabase
        .from('inventario_movimientos')
        .insert({
          ...movimientoData,
          cantidad_anterior: cantidadAnterior,
          cantidad_posterior: cantidadPosterior,
          realizado_por: currentUser?.id,
        })
        .select('id')
        .single()

      if (error) throw error

      // Actualizar cantidad en lote
      const { error: updateError } = await supabase
        .from('lotes_farmacos')
        .update({ cantidad_actual: cantidadPosterior })
        .eq('id', movimientoData.lote_farmaco_id)

      if (updateError) throw updateError

      return data.id
    } catch (error) {
      console.error('Error en InventarioController.registrarMovimiento:', error)
      throw error
    }
  }

  /**
   * Obtener estadísticas de movimientos
   */
  static async getStats(fechaInicio?: string, fechaFin?: string): Promise<{
    total: number
    entradas: number
    salidas: number
    consumos: number
    por_tipo: Record<string, number>
  }> {
    try {
      let query = supabase.from('inventario_movimientos').select('tipo_movimiento, cantidad')

      if (fechaInicio) {
        query = query.gte('created_at', fechaInicio)
      }
      if (fechaFin) {
        query = query.lte('created_at', fechaFin)
      }

      const { data, error } = await query

      if (error) throw error

      const porTipo: Record<string, number> = {}
      let entradas = 0
      let salidas = 0
      let consumos = 0

      data.forEach((m: any) => {
        porTipo[m.tipo_movimiento] = (porTipo[m.tipo_movimiento] || 0) + 1

        if (m.tipo_movimiento === 'entrada') entradas += m.cantidad
        if (m.tipo_movimiento === 'salida') salidas += m.cantidad
        if (m.tipo_movimiento === 'consumo') consumos += m.cantidad
      })

      return {
        total: data.length,
        entradas,
        salidas,
        consumos,
        por_tipo: porTipo,
      }
    } catch (error) {
      console.error('Error en InventarioController.getStats:', error)
      throw error
    }
  }

  /**
   * Obtener resumen de stock actual
   */
  static async getResumenStock(): Promise<{
    total_farmacos: number
    total_lotes: number
    total_unidades: number
    valor_total: number
  }> {
    try {
      const { data: lotes, error } = await supabase
        .from('lotes_farmacos')
        .select('farmaco_id, cantidad_actual, precio_venta')
        .eq('activo', true)
        .gt('cantidad_actual', 0)
        .is('deleted_at', null)

      if (error) throw error

      const farmacosUnicos = new Set(lotes.map((l: any) => l.farmaco_id))
      const totalUnidades = lotes.reduce((sum: number, l: any) => sum + l.cantidad_actual, 0)
      const valorTotal = lotes.reduce(
        (sum: number, l: any) => sum + (l.cantidad_actual * (l.precio_venta || 0)),
        0
      )

      return {
        total_farmacos: farmacosUnicos.size,
        total_lotes: lotes.length,
        total_unidades: totalUnidades,
        valor_total: valorTotal,
      }
    } catch (error) {
      console.error('Error en InventarioController.getResumenStock:', error)
      throw error
    }
  }
}
