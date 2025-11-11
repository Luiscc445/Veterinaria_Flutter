// Controlador de Consultorios (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type { Consultorio, ConsultorioFormData, ConsultorioUpdateData } from '../models/Consultorio'

export class ConsultoriosController {
  /**
   * Obtener todos los consultorios
   */
  static async getAll(soloActivos = false): Promise<Consultorio[]> {
    try {
      let query = supabase
        .from('consultorios')
        .select('*')
        .is('deleted_at', null)
        .order('numero', { ascending: true })

      if (soloActivos) {
        query = query.eq('activo', true)
      }

      const { data, error } = await query
      if (error) throw error
      return data || []
    } catch (error) {
      console.error('Error en ConsultoriosController.getAll:', error)
      throw error
    }
  }

  /**
   * Obtener consultorio por ID
   */
  static async getById(id: string): Promise<Consultorio | null> {
    try {
      const { data, error } = await supabase
        .from('consultorios')
        .select('*')
        .eq('id', id)
        .is('deleted_at', null)
        .single()

      if (error) throw error
      return data
    } catch (error) {
      console.error('Error en ConsultoriosController.getById:', error)
      throw error
    }
  }

  /**
   * Crear nuevo consultorio
   */
  static async create(consultorioData: ConsultorioFormData): Promise<string> {
    try {
      const { data, error } = await supabase
        .from('consultorios')
        .insert({
          ...consultorioData,
          activo: true,
        })
        .select('id')
        .single()

      if (error) throw error
      return data.id
    } catch (error) {
      console.error('Error en ConsultoriosController.create:', error)
      throw error
    }
  }

  /**
   * Actualizar consultorio
   */
  static async update(id: string, updateData: ConsultorioUpdateData): Promise<void> {
    try {
      const { error } = await supabase
        .from('consultorios')
        .update(updateData)
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en ConsultoriosController.update:', error)
      throw error
    }
  }

  /**
   * Eliminar consultorio (soft delete)
   */
  static async delete(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('consultorios')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en ConsultoriosController.delete:', error)
      throw error
    }
  }

  /**
   * Activar/desactivar consultorio
   */
  static async toggleActivo(id: string, activo: boolean): Promise<void> {
    try {
      const { error } = await supabase
        .from('consultorios')
        .update({ activo })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en ConsultoriosController.toggleActivo:', error)
      throw error
    }
  }

  /**
   * Verificar disponibilidad de consultorio
   */
  static async verificarDisponibilidad(
    consultorioId: string,
    fechaHora: string,
    duracionMinutos: number
  ): Promise<boolean> {
    try {
      const inicio = new Date(fechaHora)
      const fin = new Date(inicio.getTime() + duracionMinutos * 60000)

      const { data, error } = await supabase
        .from('citas')
        .select('id')
        .eq('consultorio_id', consultorioId)
        .gte('fecha_hora', inicio.toISOString())
        .lt('fecha_hora', fin.toISOString())
        .in('estado', ['reservada', 'confirmada', 'en_sala'])
        .is('deleted_at', null)

      if (error) throw error

      return (data?.length || 0) === 0
    } catch (error) {
      console.error('Error en ConsultoriosController.verificarDisponibilidad:', error)
      return false
    }
  }

  /**
   * Obtener estadísticas de consultorios
   */
  static async getStats(): Promise<{
    total: number
    activos: number
    capacidad_total: number
  }> {
    try {
      const { data, error } = await supabase
        .from('consultorios')
        .select('activo, capacidad')
        .is('deleted_at', null)

      if (error) throw error

      const capacidadTotal = data.reduce((sum: number, c: any) => sum + (c.capacidad || 1), 0)

      return {
        total: data.length,
        activos: data.filter((c: any) => c.activo).length,
        capacidad_total: capacidadTotal,
      }
    } catch (error) {
      console.error('Error en ConsultoriosController.getStats:', error)
      throw error
    }
  }
}
