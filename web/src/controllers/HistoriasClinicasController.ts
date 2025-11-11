// Controlador de Historias Clínicas (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type {
  HistoriaClinica,
  HistoriaClinicaFormData,
  HistoriaClinicaUpdateData,
} from '../models/HistoriaClinica'

export class HistoriasClinicasController {
  /**
   * Obtener todas las historias clínicas
   */
  static async getAll(): Promise<HistoriaClinica[]> {
    try {
      const { data, error } = await supabase
        .from('historias_clinicas')
        .select(`
          *,
          mascota:mascotas(nombre, especie, tutor_id),
          tutor:mascotas(tutor:tutores(user:users(nombre_completo)))
        `)
        .is('deleted_at', null)
        .order('fecha_apertura', { ascending: false })

      if (error) throw error

      return (data || []).map((hc: any) => ({
        ...hc,
        mascota_nombre: hc.mascota?.nombre,
        mascota_especie: hc.mascota?.especie,
      }))
    } catch (error) {
      console.error('Error en HistoriasClinicasController.getAll:', error)
      throw error
    }
  }

  /**
   * Obtener historia clínica por ID
   */
  static async getById(id: string): Promise<HistoriaClinica | null> {
    try {
      const { data, error } = await supabase
        .from('historias_clinicas')
        .select(`
          *,
          mascota:mascotas(nombre, especie)
        `)
        .eq('id', id)
        .is('deleted_at', null)
        .single()

      if (error) throw error

      return {
        ...data,
        mascota_nombre: data.mascota?.nombre,
        mascota_especie: data.mascota?.especie,
      }
    } catch (error) {
      console.error('Error en HistoriasClinicasController.getById:', error)
      throw error
    }
  }

  /**
   * Obtener historia clínica por mascota
   */
  static async getByMascota(mascotaId: string): Promise<HistoriaClinica | null> {
    try {
      const { data, error } = await supabase
        .from('historias_clinicas')
        .select(`
          *,
          mascota:mascotas(nombre, especie)
        `)
        .eq('mascota_id', mascotaId)
        .is('deleted_at', null)
        .single()

      if (error) {
        // Si no existe, no es un error grave
        if (error.code === 'PGRST116') return null
        throw error
      }

      return {
        ...data,
        mascota_nombre: data.mascota?.nombre,
        mascota_especie: data.mascota?.especie,
      }
    } catch (error) {
      console.error('Error en HistoriasClinicasController.getByMascota:', error)
      throw error
    }
  }

  /**
   * Crear nueva historia clínica
   * El número de historia se genera automáticamente por trigger
   */
  static async create(historiaData: HistoriaClinicaFormData): Promise<string> {
    try {
      const { data, error } = await supabase
        .from('historias_clinicas')
        .insert(historiaData)
        .select('id')
        .single()

      if (error) throw error
      return data.id
    } catch (error) {
      console.error('Error en HistoriasClinicasController.create:', error)
      throw error
    }
  }

  /**
   * Actualizar historia clínica
   */
  static async update(id: string, updateData: HistoriaClinicaUpdateData): Promise<void> {
    try {
      const { error } = await supabase
        .from('historias_clinicas')
        .update(updateData)
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en HistoriasClinicasController.update:', error)
      throw error
    }
  }

  /**
   * Eliminar historia clínica (soft delete)
   */
  static async delete(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('historias_clinicas')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en HistoriasClinicasController.delete:', error)
      throw error
    }
  }

  /**
   * Obtener estadísticas
   */
  static async getStats(): Promise<{
    total: number
    este_mes: number
    este_anio: number
  }> {
    try {
      const { data, error } = await supabase
        .from('historias_clinicas')
        .select('fecha_apertura')
        .is('deleted_at', null)

      if (error) throw error

      const ahora = new Date()
      const inicioMes = new Date(ahora.getFullYear(), ahora.getMonth(), 1)
      const inicioAnio = new Date(ahora.getFullYear(), 0, 1)

      const esteMes = data.filter((h: any) => new Date(h.fecha_apertura) >= inicioMes).length
      const esteAnio = data.filter((h: any) => new Date(h.fecha_apertura) >= inicioAnio).length

      return {
        total: data.length,
        este_mes: esteMes,
        este_anio: esteAnio,
      }
    } catch (error) {
      console.error('Error en HistoriasClinicasController.getStats:', error)
      throw error
    }
  }
}
