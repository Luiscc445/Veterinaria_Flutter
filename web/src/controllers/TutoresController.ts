// Controlador de Tutores (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type { Tutor, TutorFormData, TutorUpdateData } from '../models/Tutor'

export class TutoresController {
  /**
   * Obtener todos los tutores con información de usuario
   */
  static async getAll(): Promise<Tutor[]> {
    try {
      const { data, error } = await supabase
        .from('tutores')
        .select(`
          *,
          user:users(email, nombre_completo, telefono)
        `)
        .is('deleted_at', null)
        .order('created_at', { ascending: false })

      if (error) throw error

      return (data || []).map((tutor: any) => ({
        ...tutor,
        user_email: tutor.user?.email,
        user_nombre: tutor.user?.nombre_completo,
        user_telefono: tutor.user?.telefono,
      }))
    } catch (error) {
      console.error('Error en TutoresController.getAll:', error)
      throw error
    }
  }

  /**
   * Obtener tutor por ID
   */
  static async getById(id: string): Promise<Tutor | null> {
    try {
      const { data, error } = await supabase
        .from('tutores')
        .select(`
          *,
          user:users(email, nombre_completo, telefono)
        `)
        .eq('id', id)
        .is('deleted_at', null)
        .single()

      if (error) throw error

      return {
        ...data,
        user_email: data.user?.email,
        user_nombre: data.user?.nombre_completo,
        user_telefono: data.user?.telefono,
      }
    } catch (error) {
      console.error('Error en TutoresController.getById:', error)
      throw error
    }
  }

  /**
   * Crear nuevo tutor
   */
  static async create(tutorData: TutorFormData): Promise<string> {
    try {
      const { data, error } = await supabase
        .from('tutores')
        .insert(tutorData)
        .select('id')
        .single()

      if (error) throw error
      return data.id
    } catch (error) {
      console.error('Error en TutoresController.create:', error)
      throw error
    }
  }

  /**
   * Actualizar tutor
   */
  static async update(id: string, updateData: TutorUpdateData): Promise<void> {
    try {
      const { error } = await supabase
        .from('tutores')
        .update(updateData)
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en TutoresController.update:', error)
      throw error
    }
  }

  /**
   * Eliminar tutor (soft delete)
   */
  static async delete(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('tutores')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en TutoresController.delete:', error)
      throw error
    }
  }

  /**
   * Obtener estadísticas de tutores
   */
  static async getStats(): Promise<{
    total: number
    con_mascotas: number
    con_citas_activas: number
  }> {
    try {
      const { data: tutoresData, error: tutoresError } = await supabase
        .from('tutores')
        .select('id')
        .is('deleted_at', null)

      if (tutoresError) throw tutoresError

      const { data: mascotasData, error: mascotasError } = await supabase
        .from('mascotas')
        .select('tutor_id')
        .is('deleted_at', null)

      if (mascotasError) throw mascotasError

      const tutoresConMascotas = new Set(mascotasData.map((m: any) => m.tutor_id))

      const { data: citasData, error: citasError } = await supabase
        .from('citas')
        .select('tutor_id')
        .gte('fecha_hora', new Date().toISOString())
        .in('estado', ['reservada', 'confirmada'])
        .is('deleted_at', null)

      if (citasError) throw citasError

      const tutoresConCitas = new Set(citasData.map((c: any) => c.tutor_id))

      return {
        total: tutoresData.length,
        con_mascotas: tutoresConMascotas.size,
        con_citas_activas: tutoresConCitas.size,
      }
    } catch (error) {
      console.error('Error en TutoresController.getStats:', error)
      throw error
    }
  }
}
