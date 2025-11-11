import { useEffect, useState } from 'react'
import { supabase } from '../../services/supabase'
import { Card, Button } from '../components/ui'

interface Estadisticas {
  tutores: {
    total: number
    activos: number
    inactivos: number
    conMascotas: number
  }
  personal: {
    total: number
    veterinarios: number
    laboratoristas: number
    ecografistas: number
    recepcion: number
    activos: number
  }
  inventario: {
    totalFarmacos: number
    sinStock: number
    bajoStock: number
    stockNormal: number
  }
  mascotas: {
    total: number
    caninos: number
    felinos: number
    exoticos: number
  }
}

export default function EstadisticasPage() {
  const [stats, setStats] = useState<Estadisticas>({
    tutores: { total: 0, activos: 0, inactivos: 0, conMascotas: 0 },
    personal: { total: 0, veterinarios: 0, laboratoristas: 0, ecografistas: 0, recepcion: 0, activos: 0 },
    inventario: { totalFarmacos: 0, sinStock: 0, bajoStock: 0, stockNormal: 0 },
    mascotas: { total: 0, caninos: 0, felinos: 0, exoticos: 0 },
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadEstadisticas()
  }, [])

  const loadEstadisticas = async () => {
    try {
      setLoading(true)

      // Cargar tutores
      const { data: tutoresData } = await supabase
        .from('tutores')
        .select(`
          *,
          usuario:user_id (activo),
          mascotas (id)
        `)

      // Cargar personal
      const { data: personalData } = await supabase
        .from('users')
        .select('*')
        .in('rol', ['medico', 'laboratorista', 'ecografista', 'recepcion', 'admin'])

      // Cargar inventario
      const { data: inventarioData } = await supabase
        .from('farmacos')
        .select('*, lotes_farmacos(cantidad_disponible)')

      // Cargar mascotas
      const { data: mascotasData } = await supabase
        .from('mascotas')
        .select('especie')

      // Procesar tutores
      const tutoresStats = {
        total: tutoresData?.length || 0,
        activos: tutoresData?.filter((t: any) => t.usuario?.activo).length || 0,
        inactivos: tutoresData?.filter((t: any) => !t.usuario?.activo).length || 0,
        conMascotas: tutoresData?.filter((t: any) => t.mascotas && t.mascotas.length > 0).length || 0,
      }

      // Procesar personal
      const personalStats = {
        total: personalData?.length || 0,
        veterinarios: personalData?.filter((p: any) => p.rol === 'medico').length || 0,
        laboratoristas: personalData?.filter((p: any) => p.rol === 'laboratorista').length || 0,
        ecografistas: personalData?.filter((p: any) => p.rol === 'ecografista').length || 0,
        recepcion: personalData?.filter((p: any) => p.rol === 'recepcion').length || 0,
        activos: personalData?.filter((p: any) => p.activo).length || 0,
      }

      // Procesar inventario
      const inventarioStats = {
        totalFarmacos: inventarioData?.length || 0,
        sinStock: inventarioData?.filter((f: any) => {
          const stockTotal = f.lotes_farmacos?.reduce((sum: number, lote: any) => sum + (lote.cantidad_disponible || 0), 0) || 0
          return stockTotal === 0
        }).length || 0,
        bajoStock: inventarioData?.filter((f: any) => {
          const stockTotal = f.lotes_farmacos?.reduce((sum: number, lote: any) => sum + (lote.cantidad_disponible || 0), 0) || 0
          return stockTotal > 0 && stockTotal < f.stock_minimo
        }).length || 0,
        stockNormal: inventarioData?.filter((f: any) => {
          const stockTotal = f.lotes_farmacos?.reduce((sum: number, lote: any) => sum + (lote.cantidad_disponible || 0), 0) || 0
          return stockTotal >= f.stock_minimo
        }).length || 0,
      }

      // Procesar mascotas
      const mascotasStats = {
        total: mascotasData?.length || 0,
        caninos: mascotasData?.filter((m: any) => m.especie?.toLowerCase() === 'canino').length || 0,
        felinos: mascotasData?.filter((m: any) => m.especie?.toLowerCase() === 'felino').length || 0,
        exoticos: mascotasData?.filter((m: any) =>
          m.especie &&
          !['canino', 'felino'].includes(m.especie.toLowerCase())
        ).length || 0,
      }

      setStats({
        tutores: tutoresStats,
        personal: personalStats,
        inventario: inventarioStats,
        mascotas: mascotasStats,
      })
    } catch (error) {
      console.error('Error loading estadisticas:', error)
    } finally {
      setLoading(false)
    }
  }

  const handlePrint = () => {
    window.print()
  }

  const handleExportPDF = () => {
    // Usar window.print() que permite guardar como PDF
    window.print()
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center print:mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Estadísticas Generales</h1>
          <p className="text-gray-600 mt-2">Dashboard de métricas del sistema RamboPet</p>
        </div>
        <div className="flex space-x-3 print:hidden">
          <Button onClick={loadEstadisticas} variant="outline">
            Actualizar
          </Button>
          <Button onClick={handleExportPDF}>
            📄 Exportar PDF
          </Button>
        </div>
      </div>

      {/* Tutores */}
      <div>
        <h2 className="text-2xl font-semibold text-gray-900 mb-4">📊 Tutores</h2>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">👥</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Total Tutores</p>
                <p className="text-2xl font-bold text-gray-900">{stats.tutores.total}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">✅</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Activos</p>
                <p className="text-2xl font-bold text-green-600">{stats.tutores.activos}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">❌</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Inactivos</p>
                <p className="text-2xl font-bold text-red-600">{stats.tutores.inactivos}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">🐾</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Con Mascotas</p>
                <p className="text-2xl font-bold text-purple-600">{stats.tutores.conMascotas}</p>
              </div>
            </div>
          </Card>
        </div>

        {/* Gráfico de barras de tutores */}
        <Card className="mt-4">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Distribución de Tutores</h3>
          <div className="space-y-3">
            <div>
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm font-medium text-green-700">Activos</span>
                <span className="text-sm text-gray-600">{stats.tutores.activos} tutores</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3">
                <div
                  className="bg-green-600 h-3 rounded-full transition-all"
                  style={{ width: stats.tutores.total > 0 ? `${(stats.tutores.activos / stats.tutores.total) * 100}%` : '0%' }}
                />
              </div>
            </div>
            <div>
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm font-medium text-red-700">Inactivos</span>
                <span className="text-sm text-gray-600">{stats.tutores.inactivos} tutores</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3">
                <div
                  className="bg-red-600 h-3 rounded-full transition-all"
                  style={{ width: stats.tutores.total > 0 ? `${(stats.tutores.inactivos / stats.tutores.total) * 100}%` : '0%' }}
                />
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* Personal */}
      <div>
        <h2 className="text-2xl font-semibold text-gray-900 mb-4">👨‍⚕️ Personal</h2>
        <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">👥</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Total</p>
                <p className="text-2xl font-bold text-gray-900">{stats.personal.total}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">👨‍⚕️</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Veterinarios</p>
                <p className="text-2xl font-bold text-green-600">{stats.personal.veterinarios}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">🔬</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Laboratoristas</p>
                <p className="text-2xl font-bold text-yellow-600">{stats.personal.laboratoristas}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">📡</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Ecografistas</p>
                <p className="text-2xl font-bold text-purple-600">{stats.personal.ecografistas}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">📞</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Recepción</p>
                <p className="text-2xl font-bold text-orange-600">{stats.personal.recepcion}</p>
              </div>
            </div>
          </Card>
        </div>

        {/* Gráfico de personal */}
        <Card className="mt-4">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Distribución de Personal por Rol</h3>
          <div className="space-y-3">
            {stats.personal.veterinarios > 0 && (
              <div>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm font-medium text-green-700">Veterinarios</span>
                  <span className="text-sm text-gray-600">{stats.personal.veterinarios} personas</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div
                    className="bg-green-600 h-3 rounded-full transition-all"
                    style={{ width: stats.personal.total > 0 ? `${(stats.personal.veterinarios / stats.personal.total) * 100}%` : '0%' }}
                  />
                </div>
              </div>
            )}
            {stats.personal.laboratoristas > 0 && (
              <div>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm font-medium text-yellow-700">Laboratoristas</span>
                  <span className="text-sm text-gray-600">{stats.personal.laboratoristas} personas</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div
                    className="bg-yellow-600 h-3 rounded-full transition-all"
                    style={{ width: stats.personal.total > 0 ? `${(stats.personal.laboratoristas / stats.personal.total) * 100}%` : '0%' }}
                  />
                </div>
              </div>
            )}
            {stats.personal.ecografistas > 0 && (
              <div>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm font-medium text-purple-700">Ecografistas</span>
                  <span className="text-sm text-gray-600">{stats.personal.ecografistas} personas</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div
                    className="bg-purple-600 h-3 rounded-full transition-all"
                    style={{ width: stats.personal.total > 0 ? `${(stats.personal.ecografistas / stats.personal.total) * 100}%` : '0%' }}
                  />
                </div>
              </div>
            )}
          </div>
        </Card>
      </div>

      {/* Inventario */}
      <div>
        <h2 className="text-2xl font-semibold text-gray-900 mb-4">💊 Inventario</h2>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">💊</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Total Fármacos</p>
                <p className="text-2xl font-bold text-gray-900">{stats.inventario.totalFarmacos}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">⚠️</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Sin Stock</p>
                <p className="text-2xl font-bold text-red-600">{stats.inventario.sinStock}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">📉</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Bajo Stock</p>
                <p className="text-2xl font-bold text-yellow-600">{stats.inventario.bajoStock}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">✅</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Stock Normal</p>
                <p className="text-2xl font-bold text-green-600">{stats.inventario.stockNormal}</p>
              </div>
            </div>
          </Card>
        </div>

        {/* Gráfico de inventario */}
        <Card className="mt-4">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Estado del Inventario</h3>
          <div className="space-y-3">
            <div>
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm font-medium text-green-700">Stock Normal</span>
                <span className="text-sm text-gray-600">{stats.inventario.stockNormal} fármacos</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3">
                <div
                  className="bg-green-600 h-3 rounded-full transition-all"
                  style={{ width: stats.inventario.totalFarmacos > 0 ? `${(stats.inventario.stockNormal / stats.inventario.totalFarmacos) * 100}%` : '0%' }}
                />
              </div>
            </div>
            <div>
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm font-medium text-yellow-700">Bajo Stock</span>
                <span className="text-sm text-gray-600">{stats.inventario.bajoStock} fármacos</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3">
                <div
                  className="bg-yellow-600 h-3 rounded-full transition-all"
                  style={{ width: stats.inventario.totalFarmacos > 0 ? `${(stats.inventario.bajoStock / stats.inventario.totalFarmacos) * 100}%` : '0%' }}
                />
              </div>
            </div>
            <div>
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm font-medium text-red-700">Sin Stock</span>
                <span className="text-sm text-gray-600">{stats.inventario.sinStock} fármacos</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3">
                <div
                  className="bg-red-600 h-3 rounded-full transition-all"
                  style={{ width: stats.inventario.totalFarmacos > 0 ? `${(stats.inventario.sinStock / stats.inventario.totalFarmacos) * 100}%` : '0%' }}
                />
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* Mascotas */}
      <div>
        <h2 className="text-2xl font-semibold text-gray-900 mb-4">🐾 Mascotas</h2>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">🐾</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Total Mascotas</p>
                <p className="text-2xl font-bold text-gray-900">{stats.mascotas.total}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">🐕</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Caninos</p>
                <p className="text-2xl font-bold text-green-600">{stats.mascotas.caninos}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">🐈</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Felinos</p>
                <p className="text-2xl font-bold text-purple-600">{stats.mascotas.felinos}</p>
              </div>
            </div>
          </Card>

          <Card hover>
            <div className="flex items-center space-x-4">
              <div className="flex-shrink-0 w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                <span className="text-2xl">🦜</span>
              </div>
              <div>
                <p className="text-sm text-gray-600">Exóticos</p>
                <p className="text-2xl font-bold text-orange-600">{stats.mascotas.exoticos}</p>
              </div>
            </div>
          </Card>
        </div>

        {/* Gráfico de mascotas */}
        <Card className="mt-4">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Distribución por Especie</h3>
          <div className="space-y-3">
            {stats.mascotas.caninos > 0 && (
              <div>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm font-medium text-green-700">Caninos</span>
                  <span className="text-sm text-gray-600">{stats.mascotas.caninos} mascotas</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div
                    className="bg-green-600 h-3 rounded-full transition-all"
                    style={{ width: stats.mascotas.total > 0 ? `${(stats.mascotas.caninos / stats.mascotas.total) * 100}%` : '0%' }}
                  />
                </div>
              </div>
            )}
            {stats.mascotas.felinos > 0 && (
              <div>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm font-medium text-purple-700">Felinos</span>
                  <span className="text-sm text-gray-600">{stats.mascotas.felinos} mascotas</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div
                    className="bg-purple-600 h-3 rounded-full transition-all"
                    style={{ width: stats.mascotas.total > 0 ? `${(stats.mascotas.felinos / stats.mascotas.total) * 100}%` : '0%' }}
                  />
                </div>
              </div>
            )}
            {stats.mascotas.exoticos > 0 && (
              <div>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-sm font-medium text-orange-700">Exóticos</span>
                  <span className="text-sm text-gray-600">{stats.mascotas.exoticos} mascotas</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3">
                  <div
                    className="bg-orange-600 h-3 rounded-full transition-all"
                    style={{ width: stats.mascotas.total > 0 ? `${(stats.mascotas.exoticos / stats.mascotas.total) * 100}%` : '0%' }}
                  />
                </div>
              </div>
            )}
          </div>
        </Card>
      </div>

      {/* Footer para impresión */}
      <div className="hidden print:block mt-8 pt-4 border-t text-center text-sm text-gray-600">
        <p>RamboPet - Sistema Veterinario</p>
        <p>Reporte generado el {new Date().toLocaleDateString('es-ES', {
          year: 'numeric',
          month: 'long',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        })}</p>
      </div>
    </div>
  )
}
