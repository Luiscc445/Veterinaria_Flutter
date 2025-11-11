import { useEffect, useState } from 'react'
import { MascotasController, CitasController } from '../../controllers'

interface Stats {
  totalMascotas: number
  totalCitas: number
  citasHoy: number
  mascotasPendientes: number
}

export default function DashboardPage() {
  const [stats, setStats] = useState<Stats>({
    totalMascotas: 0,
    totalCitas: 0,
    citasHoy: 0,
    mascotasPendientes: 0,
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    try {
      // ✅ Usando controladores MVC en lugar de queries directas
      const [mascotasStats, citasStats] = await Promise.all([
        MascotasController.getStats(),
        CitasController.getStats(),
      ])

      setStats({
        totalMascotas: mascotasStats.total,
        totalCitas: citasStats.total,
        citasHoy: citasStats.hoy,
        mascotasPendientes: mascotasStats.pendientes,
      })
    } catch (error) {
      console.error('Error loading stats:', error)
    } finally {
      setLoading(false)
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
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Mascotas</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{stats.totalMascotas}</p>
            </div>
            <div className="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">🐾</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Citas</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{stats.totalCitas}</p>
            </div>
            <div className="w-12 h-12 bg-secondary-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">📅</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Citas Hoy</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{stats.citasHoy}</p>
            </div>
            <div className="w-12 h-12 bg-accent-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">📋</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Mascotas Pendientes</p>
              <p className="text-3xl font-bold text-gray-900 mt-2">{stats.mascotasPendientes}</p>
            </div>
            <div className="w-12 h-12 bg-yellow-100 rounded-full flex items-center justify-center">
              <span className="text-2xl">⏳</span>
            </div>
          </div>
        </div>
      </div>

      <div className="mt-8 bg-white rounded-lg shadow-md p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Bienvenido a RamboPet</h2>
        <p className="text-gray-600">
          Sistema de gestión integral para clínicas veterinarias. Selecciona una opción del menú para comenzar.
        </p>
      </div>
    </div>
  )
}
