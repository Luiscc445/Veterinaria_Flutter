// Controlador de Profesionales (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type { Profesional, ProfesionalFormData, ProfesionalUpdateData } from '../models/Profesional'

export class ProfesionalesController {
  /**
   * Obtener todos los profesionales con información de usuario
   */
  static async getAll(soloActivos = false): Promise<Profesional[]> {
    try {
      let query = supabase
        .from('profesionales')
        .select(`
          *,
          user:users(nombre_completo, email, telefono, avatar_url)
        `)
        .is('deleted_at', null)
        .order('created_at', { ascending: false })

      if (soloActivos) {
        query = query.eq('activo', true)
      }

      const { data, error } = await query
      if (error) throw error

      return (data || []).map((prof: any) => ({
        ...prof,
        user_nombre: prof.user?.nombre_completo,
        user_email: prof.user?.email,
        user_telefono: prof.user?.telefono,
        user_avatar: prof.user?.avatar_url,
      }))
    } catch (error) {
      console.error('Error en ProfesionalesController.getAll:', error)
      throw error
    }
  }

  /**
   * Obtener profesional por ID
   */
  static async getById(id: string): Promise<Profesional | null> {
    try {
      const { data, error } = await supabase
        .from('profesionales')
        .select(`
          *,
          user:users(nombre_completo, email, telefono, avatar_url)
        `)
        .eq('id', id)
        .is('deleted_at', null)
        .single()

      if (error) throw error

      return {
        ...data,
        user_nombre: data.user?.nombre_completo,
        user_email: data.user?.email,
        user_telefono: data.user?.telefono,
        user_avatar: data.user?.avatar_url,
      }
    } catch (error) {
      console.error('Error en ProfesionalesController.getById:', error)
      throw error
    }
  }

  /**
   * Crear nuevo profesional
   */
  static async create(profesionalData: ProfesionalFormData): Promise<string> {
    try {
      const { data, error } = await supabase
        .from('profesionales')
        .insert({
          ...profesionalData,
          activo: true,
        })
        .select('id')
        .single()

      if (error) throw error
      return data.id
    } catch (error) {
      console.error('Error en ProfesionalesController.create:', error)
      throw error
    }
  }

  /**
   * Actualizar profesional
   */
  static async update(id: string, updateData: ProfesionalUpdateData): Promise<void> {
    try {
      const { error } = await supabase
        .from('profesionales')
        .update(updateData)
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en ProfesionalesController.update:', error)
      throw error
    }
  }

  /**
   * Eliminar profesional (soft delete)
   */
  static async delete(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('profesionales')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en ProfesionalesController.delete:', error)
      throw error
    }
  }

  /**
   * Activar/desactivar profesional
   */
  static async toggleActivo(id: string, activo: boolean): Promise<void> {
    try {
      const { error } = await supabase
        .from('profesionales')
        .update({ activo })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en ProfesionalesController.toggleActivo:', error)
      throw error
    }
  }

  /**
   * Obtener disponibilidad del profesional
   */
  static async getDisponibilidad(
    profesionalId: string,
    fecha: string
  ): Promise<{ disponible: boolean; citas: number }> {
    try {
      const fechaInicio = new Date(fecha)
      fechaInicio.setHours(0, 0, 0, 0)

      const fechaFin = new Date(fecha)
      fechaFin.setHours(23, 59, 59, 999)

      const { data, error } = await supabase
        .from('citas')
        .select('id')
        .eq('profesional_id', profesionalId)
        .gte('fecha_hora', fechaInicio.toISOString())
        .lte('fecha_hora', fechaFin.toISOString())
        .in('estado', ['reservada', 'confirmada', 'en_sala'])
        .is('deleted_at', null)

      if (error) throw error

      return {
        disponible: (data?.length || 0) < 10, // Máximo 10 citas por día
        citas: data?.length || 0,
      }
    } catch (error) {
      console.error('Error en ProfesionalesController.getDisponibilidad:', error)
      throw error
    }
  }

  /**
   * Obtener estadísticas de profesionales
   */
  static async getStats(): Promise<{
    total: number
    activos: number
    promedio_experiencia: number
  }> {
    try {
      const { data, error } = await supabase
        .from('profesionales')
        .select('activo, anios_experiencia')
        .is('deleted_at', null)

      if (error) throw error

      const totalExperiencia = data.reduce(
        (sum: number, p: any) => sum + (p.anios_experiencia || 0),
        0
      )

      return {
        total: data.length,
        activos: data.filter((p: any) => p.activo).length,
        promedio_experiencia: data.length > 0 ? totalExperiencia / data.length : 0,
      }
    } catch (error) {
      console.error('Error en ProfesionalesController.getStats:', error)
      throw error
    }
  }
}
