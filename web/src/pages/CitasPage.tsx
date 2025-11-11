import { useEffect, useState } from 'react'
import { supabase } from '../services/supabase'
import { Cita } from '../types'
import { format } from 'date-fns'

export default function CitasPage() {
  const [citas, setCitas] = useState<Cita[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadCitas()
  }, [])

  const loadCitas = async () => {
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
        .limit(50)

      if (error) throw error
      setCitas(data || [])
    } catch (error) {
      console.error('Error loading citas:', error)
    } finally {
      setLoading(false)
    }
  }

  const confirmarCita = async (id: string) => {
    try {
      const { error } = await supabase
        .from('citas')
        .update({ estado: 'confirmada', fecha_confirmacion: new Date().toISOString() })
        .eq('id', id)

      if (error) throw error
      loadCitas()
    } catch (error) {
      console.error('Error confirmando cita:', error)
    }
  }

  const getEstadoColor = (estado: string) => {
    const colors: Record<string, string> = {
      reservada: 'bg-blue-100 text-blue-800',
      confirmada: 'bg-green-100 text-green-800',
      en_sala: 'bg-purple-100 text-purple-800',
      atendida: 'bg-gray-100 text-gray-800',
      cancelada: 'bg-red-100 text-red-800',
    }
    return colors[estado] || 'bg-gray-100 text-gray-800'
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Gestión de Citas</h1>

      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fecha/Hora</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Mascota</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Servicio</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Motivo</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {citas.map((cita: any) => (
              <tr key={cita.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {format(new Date(cita.fecha_hora), 'dd/MM/yyyy HH:mm')}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm font-medium text-gray-900">{cita.mascota?.nombre}</div>
                  <div className="text-sm text-gray-500">{cita.mascota?.especie}</div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {cita.servicio?.nombre}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 py-1 text-xs rounded-full ${getEstadoColor(cita.estado)}`}>
                    {cita.estado}
                  </span>
                </td>
                <td className="px-6 py-4 text-sm text-gray-500 max-w-xs truncate">
                  {cita.motivo_consulta || '-'}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm">
                  {cita.estado === 'reservada' && (
                    <button
                      onClick={() => confirmarCita(cita.id)}
                      className="text-green-600 hover:text-green-900"
                    >
                      ✓ Confirmar
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {citas.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500">No hay citas registradas</p>
          </div>
        )}
      </div>
    </div>
  )
}
