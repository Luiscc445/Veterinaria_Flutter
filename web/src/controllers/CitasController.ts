// Controlador de Citas (Arquitectura MVC)
import { supabase } from '../services/supabase'
import type { Cita } from '../models/Cita'

export class CitasController {
  /**
   * Obtener todas las citas con datos relacionados
   * IMPORTANTE: Para admin/recepción/médicos
   */
  static async getAll(): Promise<Cita[]> {
    try {
      const { data, error } = await supabase
        .from('citas')
        .select(`
          *,
          mascota:mascotas(nombre, especie),
          servicio:servicios(nombre)
        `)
        .is('deleted_at', null)
        .order('fecha_hora', { ascending: false })
        .limit(100)

      if (error) throw error

      // Mapear datos
      return (data || []).map((cita: any) => ({
        id: cita.id,
        mascota_id: cita.mascota_id,
        tutor_id: cita.tutor_id,
        servicio_id: cita.servicio_id,
        profesional_id: cita.profesional_id,
        consultorio_id: cita.consultorio_id,
        fecha_hora: cita.fecha_hora,
        fecha_hora_fin: cita.fecha_hora_fin,
        estado: cita.estado,
        motivo_consulta: cita.motivo_consulta,
        observaciones: cita.observaciones,
        created_at: cita.created_at,
        mascota_nombre: cita.mascota?.nombre,
        mascota_especie: cita.mascota?.especie,
        servicio_nombre: cita.servicio?.nombre,
      }))
    } catch (error) {
      console.error('Error en CitasController.getAll:', error)
      throw error
    }
  }

  /**
   * Confirmar una cita reservada
   */
  static async confirmar(id: string): Promise<void> {
    try {
      const { data: currentUser } = await supabase.auth.getUser()
      if (!currentUser?.user?.id) throw new Error('Usuario no autenticado')

      const { error } = await supabase
        .from('citas')
        .update({
          estado: 'confirmada',
          fecha_confirmacion: new Date().toISOString()
        })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en CitasController.confirmar:', error)
      throw error
    }
  }

  /**
   * Cancelar una cita
   */
  static async cancelar(id: string, motivo?: string): Promise<void> {
    try {
      const { error } = await supabase
        .from('citas')
        .update({
          estado: 'cancelada',
          motivo_cancelacion: motivo
        })
        .eq('id', id)

      if (error) throw error
    } catch (error) {
      console.error('Error en CitasController.cancelar:', error)
      throw error
    }
  }

  /**
   * Obtener estadísticas de citas
   */
  static async getStats(): Promise<{
    total: number
    hoy: number
    reservadas: number
    confirmadas: number
  }> {
    try {
      const today = new Date().toISOString().split('T')[0]

      const [total, hoy, reservadas, confirmadas] = await Promise.all([
        supabase.from('citas').select('id', { count: 'exact' }).is('deleted_at', null),
        supabase
          .from('citas')
          .select('id', { count: 'exact' })
          .gte('fecha_hora', `${today}T00:00:00`)
          .lte('fecha_hora', `${today}T23:59:59`)
          .is('deleted_at', null),
        supabase
          .from('citas')
          .select('id', { count: 'exact' })
          .eq('estado', 'reservada')
          .is('deleted_at', null),
        supabase
          .from('citas')
          .select('id', { count: 'exact' })
          .eq('estado', 'confirmada')
          .is('deleted_at', null),
      ])

      return {
        total: total.count || 0,
        hoy: hoy.count || 0,
        reservadas: reservadas.count || 0,
        confirmadas: confirmadas.count || 0,
      }
    } catch (error) {
      console.error('Error en CitasController.getStats:', error)
      throw error
    }
  }
}
