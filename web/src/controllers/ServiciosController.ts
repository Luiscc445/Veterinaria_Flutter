// Controlador de Servicios (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type { Servicio, ServicioFormData, ServicioUpdateData } from '../models/Servicio'

export class ServiciosController {
  /**
   * Obtener todos los servicios
   */
  static async getAll(soloActivos = false): Promise<Servicio[]> {
    try {
      let query = supabase
        .from('servicios')
        .select('*')
        .is('deleted_at', null)
        .order('nombre', { ascending: true })

      if (soloActivos) {
        query = query.eq('activo', true)
      }

      const { data, error } = await query
      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Error en ServiciosController.getAll:', error)
      throw error
    }
  }

  /**
   * Obtener servicio por ID
   */
  static async getById(id: string): Promise<Servicio | null> {
    try {
      const { data, error } = await supabase
        .from('servicios')
        .select('*')
        .eq('id', id)
        .is('deleted_at', null)
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Error en ServiciosController.getById:', error)
      throw error
    }
  }

  /**
   * Crear nuevo servicio
   */
  static async create(servicioData: ServicioFormData): Promise<string> {
    try {
      const { data, error } = await supabase
        .from('servicios')
        .insert({
          ...servicioData,
          activo: true,
        })
        .select('id')
        .single()

      if (error) throw error
      return data.id
    } catch (error) {
      console.error('Error en ServiciosController.create:', error)
      throw error
    }
  }

  /**
   * Actualizar servicio
   */
  static async update(id: string, updateData: ServicioUpdateData): Promise<void> {
    try {
      const { error } = await supabase
        .from('servicios')
        .update(updateData)
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en ServiciosController.update:', error)
      throw error
    }
  }

  /**
   * Eliminar servicio (soft delete)
   */
  static async delete(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('servicios')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en ServiciosController.delete:', error)
      throw error
    }
  }

  /**
   * Activar/desactivar servicio
   */
  static async toggleActivo(id: string, activo: boolean): Promise<void> {
    try {
      const { error } = await supabase
        .from('servicios')
        .update({ activo })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en ServiciosController.toggleActivo:', error)
      throw error
    }
  }

  /**
   * Obtener estadísticas de servicios
   */
  static async getStats(): Promise<{
    total: number
    activos: number
    por_tipo: Record<string, number>
  }> {
    try {
      const { data, error } = await supabase
        .from('servicios')
        .select('tipo, activo')
        .is('deleted_at', null)

      if (error) throw error

      const porTipo: Record<string, number> = {}
      data.forEach((s: any) => {
        porTipo[s.tipo] = (porTipo[s.tipo] || 0) + 1
      })

      return {
        total: data.length,
        activos: data.filter((s: any) => s.activo).length,
        por_tipo: porTipo,
      }
    } catch (error) {
      console.error('Error en ServiciosController.getStats:', error)
      throw error
    }
  }
}
