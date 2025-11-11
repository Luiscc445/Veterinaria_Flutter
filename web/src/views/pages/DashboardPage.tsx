import { useEffect, useState } from 'react'
import { MascotasController, CitasController } from '../../controllers'
import { StatCard, Card } from '../components/ui'

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
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-2">Bienvenido al sistema de gestión veterinaria RamboPet</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Mascotas"
          value={stats.totalMascotas}
          icon="🐾"
          color="primary"
        />
        <StatCard
          title="Total Citas"
          value={stats.totalCitas}
          icon="📅"
          color="info"
        />
        <StatCard
          title="Citas Hoy"
          value={stats.citasHoy}
          icon="📋"
          color="success"
        />
        <StatCard
          title="Mascotas Pendientes"
          value={stats.mascotasPendientes}
          icon="⏳"
          color="warning"
        />
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <h2 className="text-xl font-bold text-gray-900 mb-4">Acciones Rápidas</h2>
          <div className="space-y-3">
            <a
              href="/mascotas"
              className="flex items-center p-4 rounded-lg border border-gray-200 hover:border-primary-500 hover:bg-primary-50 transition-all"
            >
              <span className="text-3xl mr-4">🐾</span>
              <div>
                <p className="font-medium text-gray-900">Gestionar Mascotas</p>
                <p className="text-sm text-gray-600">Ver y aprobar registros de mascotas</p>
              </div>
            </a>
            <a
              href="/citas"
              className="flex items-center p-4 rounded-lg border border-gray-200 hover:border-primary-500 hover:bg-primary-50 transition-all"
            >
              <span className="text-3xl mr-4">📅</span>
              <div>
                <p className="font-medium text-gray-900">Gestionar Citas</p>
                <p className="text-sm text-gray-600">Administrar citas veterinarias</p>
              </div>
            </a>
            <a
              href="/inventario"
              className="flex items-center p-4 rounded-lg border border-gray-200 hover:border-primary-500 hover:bg-primary-50 transition-all"
            >
              <span className="text-3xl mr-4">💊</span>
              <div>
                <p className="font-medium text-gray-900">Control de Inventario</p>
                <p className="text-sm text-gray-600">Gestionar medicamentos y suministros</p>
              </div>
            </a>
          </div>
        </Card>

        <Card>
          <h2 className="text-xl font-bold text-gray-900 mb-4">Estado del Sistema</h2>
          <div className="space-y-4">
            <div className="flex justify-between items-center p-3 bg-green-50 rounded-lg">
              <div className="flex items-center">
                <span className="text-2xl mr-3">✅</span>
                <span className="text-sm font-medium text-gray-900">Base de Datos</span>
              </div>
              <span className="text-sm text-green-700 font-medium">Conectado</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-green-50 rounded-lg">
              <div className="flex items-center">
                <span className="text-2xl mr-3">✅</span>
                <span className="text-sm font-medium text-gray-900">Sistema</span>
              </div>
              <span className="text-sm text-green-700 font-medium">Operativo</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-blue-50 rounded-lg">
              <div className="flex items-center">
                <span className="text-2xl mr-3">📊</span>
                <span className="text-sm font-medium text-gray-900">Última actualización</span>
              </div>
              <span className="text-sm text-blue-700 font-medium">Ahora</span>
            </div>
          </div>
        </Card>
      </div>

      {/* Info Card */}
      <Card>
        <div className="flex items-start">
          <div className="flex-shrink-0">
            <svg className="h-6 w-6 text-primary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div className="ml-3">
            <h3 className="text-sm font-medium text-gray-900">Acerca del Sistema</h3>
            <div className="mt-2 text-sm text-gray-600">
              <p>
                RamboPet es un sistema integral de gestión veterinaria que permite administrar mascotas,
                citas, historias clínicas, inventario de medicamentos y más. Utiliza el menú lateral para
                navegar entre las diferentes secciones.
              </p>
            </div>
          </div>
        </div>
      </Card>
    </div>
  )
}
