import { useEffect, useState } from 'react'
import { supabase } from '../services/supabase'
import { Farmaco, LoteFarmaco } from '../types'

export default function InventarioPage() {
  const [farmacos, setFarmacos] = useState<Farmaco[]>([])
  const [lotes, setLotes] = useState<LoteFarmaco[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadInventario()
  }, [])

  const loadInventario = async () => {
    try {
      const [farmacosRes, lotesRes] = await Promise.all([
        supabase.from('farmacos').select('*').is('deleted_at', null).limit(50),
        supabase.from('lotes_farmacos').select('*').is('deleted_at', null).limit(50),
      ])

      if (farmacosRes.error) throw farmacosRes.error
      if (lotesRes.error) throw lotesRes.error

      setFarmacos(farmacosRes.data || [])
      setLotes(lotesRes.data || [])
    } catch (error) {
      console.error('Error loading inventario:', error)
    } finally {
      setLoading(false)
    }
  }

  const getStockTotal = (farmacoId: string) => {
    return lotes
      .filter((l) => l.farmaco_id === farmacoId && l.activo)
      .reduce((sum, l) => sum + l.cantidad_actual, 0)
  }

  const getEstadoStock = (farmaco: Farmaco) => {
    const stockTotal = getStockTotal(farmaco.id)
    if (stockTotal === 0) return { label: 'Sin stock', color: 'bg-red-100 text-red-800' }
    if (stockTotal < farmaco.stock_minimo) return { label: 'Stock bajo', color: 'bg-yellow-100 text-yellow-800' }
    return { label: 'Normal', color: 'bg-green-100 text-green-800' }
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
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Gestión de Inventario</h1>

      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Medicamento</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Genérico</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Laboratorio</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stock Total</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stock Mínimo</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {farmacos.map((farmaco) => {
              const stockTotal = getStockTotal(farmaco.id)
              const estadoStock = getEstadoStock(farmaco)

              return (
                <tr key={farmaco.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{farmaco.nombre_comercial}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {farmaco.nombre_generico}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {farmaco.laboratorio || '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-medium">
                    {stockTotal}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{farmaco.stock_minimo}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 text-xs rounded-full ${estadoStock.color}`}>
                      {estadoStock.label}
                    </span>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>

        {farmacos.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500">No hay medicamentos registrados</p>
          </div>
        )}
      </div>
    </div>
  )
}
