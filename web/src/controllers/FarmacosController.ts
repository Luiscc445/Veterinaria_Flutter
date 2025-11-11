// Controlador de Fármacos (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type { Farmaco, FarmacoFormData, FarmacoUpdateData } from '../models/Farmaco'

export class FarmacosController {
  /**
   * Obtener todos los fármacos con stock calculado
   */
  static async getAll(soloActivos = false): Promise<Farmaco[]> {
    try {
      // Usar vista que calcula stock automáticamente
      let query = supabase
        .from('vista_stock_farmacos')
        .select('*')
        .order('nombre_comercial', { ascending: true })

      const { data, error } = await query
      if (error) throw error

      let farmacos = data || []

      if (soloActivos) {
        // Obtener solo activos desde la tabla farmacos
        const { data: activosData, error: activosError } = await supabase
          .from('farmacos')
          .select('id')
          .eq('activo', true)
          .is('deleted_at', null)

        if (activosError) throw activosError

        const activosIds = new Set(activosData.map((f: any) => f.id))
        farmacos = farmacos.filter((f: any) => activosIds.has(f.id))
      }

      return farmacos
    } catch (error) {
      console.error('Error en FarmacosController.getAll:', error)
      throw error
    }
  }

  /**
   * Obtener fármaco por ID
   */
  static async getById(id: string): Promise<Farmaco | null> {
    try {
      const { data, error } = await supabase
        .from('farmacos')
        .select('*')
        .eq('id', id)
        .is('deleted_at', null)
        .single()

      if (error) throw error

      // Calcular stock
      const stockTotal = await this.calcularStock(id)

      return {
        ...data,
        stock_total: stockTotal,
        estado_stock:
          stockTotal === 0 ? 'SIN STOCK' : stockTotal < data.stock_minimo ? 'BAJO' : 'NORMAL',
      }
    } catch (error) {
      console.error('Error en FarmacosController.getById:', error)
      throw error
    }
  }

  /**
   * Calcular stock total de un fármaco
   */
  static async calcularStock(farmacoId: string): Promise<number> {
    try {
      const { data, error } = await supabase.rpc('calcular_stock_total_farmaco', {
        farmaco_uuid: farmacoId,
      })

      if (error) throw error
      return data || 0
    } catch (error) {
      console.error('Error en FarmacosController.calcularStock:', error)
      return 0
    }
  }

  /**
   * Crear nuevo fármaco
   */
  static async create(farmacoData: FarmacoFormData): Promise<string> {
    try {
      const { data, error } = await supabase
        .from('farmacos')
        .insert({
          ...farmacoData,
          activo: true,
        })
        .select('id')
        .single()

      if (error) throw error
      return data.id
    } catch (error) {
      console.error('Error en FarmacosController.create:', error)
      throw error
    }
  }

  /**
   * Actualizar fármaco
   */
  static async update(id: string, updateData: FarmacoUpdateData): Promise<void> {
    try {
      const { error } = await supabase.from('farmacos').update(updateData).eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en FarmacosController.update:', error)
      throw error
    }
  }

  /**
   * Eliminar fármaco (soft delete)
   */
  static async delete(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('farmacos')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en FarmacosController.delete:', error)
      throw error
    }
  }

  /**
   * Obtener fármacos con stock bajo
   */
  static async getStockBajo(): Promise<Farmaco[]> {
    try {
      const { data, error } = await supabase
        .from('vista_stock_farmacos')
        .select('*')
        .in('estado_stock', ['SIN STOCK', 'BAJO'])
        .order('stock_total', { ascending: true })

      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Error en FarmacosController.getStockBajo:', error)
      throw error
    }
  }

  /**
   * Obtener estadísticas
   */
  static async getStats(): Promise<{
    total: number
    activos: number
    sin_stock: number
    stock_bajo: number
  }> {
    try {
      const { data: farmacosData, error: farmacosError } = await supabase
        .from('farmacos')
        .select('id, activo')
        .is('deleted_at', null)

      if (farmacosError) throw farmacosError

      const { data: stockData, error: stockError } = await supabase
        .from('vista_stock_farmacos')
        .select('estado_stock')

      if (stockError) throw stockError

      return {
        total: farmacosData.length,
        activos: farmacosData.filter((f: any) => f.activo).length,
        sin_stock: stockData.filter((f: any) => f.estado_stock === 'SIN STOCK').length,
        stock_bajo: stockData.filter((f: any) => f.estado_stock === 'BAJO').length,
      }
    } catch (error) {
      console.error('Error en FarmacosController.getStats:', error)
      throw error
    }
  }
}
