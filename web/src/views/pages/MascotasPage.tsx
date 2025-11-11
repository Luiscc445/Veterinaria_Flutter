import { useEffect, useState } from 'react'
import { MascotasController } from '../../controllers'
import type { Mascota } from '../../models'

export default function MascotasPage() {
  const [mascotas, setMascotas] = useState<Mascota[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<'all' | 'pendiente' | 'aprobado'>('all')

  useEffect(() => {
    loadMascotas()
  }, [filter])

  const loadMascotas = async () => {
    try {
      // ✅ Usando controlador MVC
      const data = await MascotasController.getAll(filter)
      setMascotas(data)
    } catch (error) {
      console.error('Error loading mascotas:', error)
    } finally {
      setLoading(false)
    }
  }

  const aprobarMascota = async (id: string) => {
    try {
      // ✅ Usando controlador MVC
      await MascotasController.aprobar(id)
      loadMascotas()
    } catch (error) {
      console.error('Error aprobando mascota:', error)
    }
  }

  const rechazarMascota = async (id: string) => {
    try {
      // ✅ Usando controlador MVC
      await MascotasController.rechazar(id, 'Rechazado por administración')
      loadMascotas()
    } catch (error) {
      console.error('Error rechazando mascota:', error)
    }
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
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Gestión de Mascotas</h1>
      </div>

      <div className="mb-6 flex gap-2">
        <button
          onClick={() => setFilter('all')}
          className={`px-4 py-2 rounded-lg ${
            filter === 'all' ? 'bg-primary-600 text-white' : 'bg-gray-200 text-gray-700'
          }`}
        >
          Todas
        </button>
        <button
          onClick={() => setFilter('pendiente')}
          className={`px-4 py-2 rounded-lg ${
            filter === 'pendiente' ? 'bg-yellow-600 text-white' : 'bg-gray-200 text-gray-700'
          }`}
        >
          Pendientes
        </button>
        <button
          onClick={() => setFilter('aprobado')}
          className={`px-4 py-2 rounded-lg ${
            filter === 'aprobado' ? 'bg-green-600 text-white' : 'bg-gray-200 text-gray-700'
          }`}
        >
          Aprobadas
        </button>
      </div>

      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nombre</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Especie</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Raza</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Sexo</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {mascotas.map((mascota) => (
              <tr key={mascota.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm font-medium text-gray-900">{mascota.nombre}</div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{mascota.especie}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{mascota.raza || '-'}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{mascota.sexo || '-'}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span
                    className={`px-2 py-1 text-xs rounded-full ${
                      mascota.estado === 'aprobado'
                        ? 'bg-green-100 text-green-800'
                        : mascota.estado === 'pendiente'
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-red-100 text-red-800'
                    }`}
                  >
                    {mascota.estado}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm">
                  {mascota.estado === 'pendiente' && (
                    <div className="flex gap-2">
                      <button
                        onClick={() => aprobarMascota(mascota.id)}
                        className="text-green-600 hover:text-green-900"
                      >
                        ✓ Aprobar
                      </button>
                      <button
                        onClick={() => rechazarMascota(mascota.id)}
                        className="text-red-600 hover:text-red-900"
                      >
                        ✗ Rechazar
                      </button>
                    </div>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {mascotas.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500">No hay mascotas {filter !== 'all' ? filter + 's' : ''}</p>
          </div>
        )}
      </div>
    </div>
  )
}
