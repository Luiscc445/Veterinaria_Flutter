// Controlador de Episodios (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type { Episodio, EpisodioFormData, EpisodioUpdateData } from '../models/Episodio'

export class EpisodiosController {
  /**
   * Obtener todos los episodios
   */
  static async getAll(limite = 100): Promise<Episodio[]> {
    try {
      const { data, error } = await supabase
        .from('episodios')
        .select(`
          *,
          profesional:profesionales(user:users(nombre_completo)),
          historia:historias_clinicas(numero_historia, mascota:mascotas(nombre))
        `)
        .is('deleted_at', null)
        .order('fecha_episodio', { ascending: false })
        .limit(limite)

      if (error) throw error

      return (data || []).map((ep: any) => ({
        ...ep,
        profesional_nombre: ep.profesional?.user?.nombre_completo,
        numero_historia: ep.historia?.numero_historia,
        mascota_nombre: ep.historia?.mascota?.nombre,
      }))
    } catch (error) {
      console.error('Error en EpisodiosController.getAll:', error)
      throw error
    }
  }

  /**
   * Obtener episodio por ID
   */
  static async getById(id: string): Promise<Episodio | null> {
    try {
      const { data, error } = await supabase
        .from('episodios')
        .select(`
          *,
          profesional:profesionales(user:users(nombre_completo)),
          historia:historias_clinicas(numero_historia, mascota:mascotas(nombre))
        `)
        .eq('id', id)
        .is('deleted_at', null)
        .single()

      if (error) throw error

      return {
        ...data,
        profesional_nombre: data.profesional?.user?.nombre_completo,
        numero_historia: data.historia?.numero_historia,
        mascota_nombre: data.historia?.mascota?.nombre,
      }
    } catch (error) {
      console.error('Error en EpisodiosController.getById:', error)
      throw error
    }
  }

  /**
   * Obtener episodios por historia clínica
   */
  static async getByHistoriaClinica(historiaId: string): Promise<Episodio[]> {
    try {
      const { data, error } = await supabase
        .from('episodios')
        .select(`
          *,
          profesional:profesionales(user:users(nombre_completo))
        `)
        .eq('historia_clinica_id', historiaId)
        .is('deleted_at', null)
        .order('fecha_episodio', { ascending: false })

      if (error) throw error

      return (data || []).map((ep: any) => ({
        ...ep,
        profesional_nombre: ep.profesional?.user?.nombre_completo,
      }))
    } catch (error) {
      console.error('Error en EpisodiosController.getByHistoriaClinica:', error)
      throw error
    }
  }

  /**
   * Crear nuevo episodio
   */
  static async create(episodioData: EpisodioFormData): Promise<string> {
    try {
      const { data, error } = await supabase
        .from('episodios')
        .insert(episodioData)
        .select('id')
        .single()

      if (error) throw error
      return data.id
    } catch (error) {
      console.error('Error en EpisodiosController.create:', error)
      throw error
    }
  }

  /**
   * Actualizar episodio
   */
  static async update(id: string, updateData: EpisodioUpdateData): Promise<void> {
    try {
      const { error } = await supabase
        .from('episodios')
        .update(updateData)
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en EpisodiosController.update:', error)
      throw error
    }
  }

  /**
   * Eliminar episodio (soft delete)
   */
  static async delete(id: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('episodios')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en EpisodiosController.delete:', error)
      throw error
    }
  }

  /**
   * Obtener estadísticas
   */
  static async getStats(): Promise<{
    total: number
    hoy: number
    esta_semana: number
    por_tipo: Record<string, number>
  }> {
    try {
      const { data, error } = await supabase
        .from('episodios')
        .select('fecha_episodio, tipo_episodio')
        .is('deleted_at', null)

      if (error) throw error

      const ahora = new Date()
      const inicioHoy = new Date(ahora.getFullYear(), ahora.getMonth(), ahora.getDate())
      const inicioSemana = new Date(ahora)
      inicioSemana.setDate(ahora.getDate() - ahora.getDay())

      const hoy = data.filter((e: any) => new Date(e.fecha_episodio) >= inicioHoy).length
      const estaSemana = data.filter((e: any) => new Date(e.fecha_episodio) >= inicioSemana).length

      const porTipo: Record<string, number> = {}
      data.forEach((e: any) => {
        porTipo[e.tipo_episodio] = (porTipo[e.tipo_episodio] || 0) + 1
      })

      return {
        total: data.length,
        hoy,
        esta_semana: estaSemana,
        por_tipo: porTipo,
      }
    } catch (error) {
      console.error('Error en EpisodiosController.getStats:', error)
      throw error
    }
  }
}
