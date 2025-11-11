import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { useEffect, useState } from 'react'
import { supabase } from './services/supabase'
import { User } from '@supabase/supabase-js'
import LoginPage from './views/pages/auth/LoginPage'
import DashboardPage from './views/pages/DashboardPage'
import MascotasPage from './views/pages/MascotasPage'
import TutoresPage from './views/pages/TutoresPage'
import CitasPage from './views/pages/CitasPage'
import HistoriasClinicasPage from './views/pages/HistoriasClinicasPage'
import ProfesionalesPage from './views/pages/ProfesionalesPage'
import InventarioPage from './views/pages/InventarioPage'
import UsuariosRegistradosPage from './views/pages/UsuariosRegistradosPage'
import LaboratorioPage from './views/pages/LaboratorioPage'
import EcografiaPage from './views/pages/EcografiaPage'
import Layout from './views/components/layout/Layout'

function App() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Verificar sesión actual
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null)
      setLoading(false)
    })

    // Escuchar cambios de autenticación
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
    })

    return () => subscription.unsubscribe()
  }, [])

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Cargando...</p>
        </div>
      </div>
    )
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={user ? <Navigate to="/dashboard" /> : <LoginPage />} />

        {user ? (
          <Route element={<Layout />}>
            <Route path="/dashboard" element={<DashboardPage />} />
            <Route path="/mascotas" element={<MascotasPage />} />
            <Route path="/tutores" element={<TutoresPage />} />
            <Route path="/citas" element={<CitasPage />} />
            <Route path="/historias" element={<HistoriasClinicasPage />} />
            <Route path="/profesionales" element={<ProfesionalesPage />} />
            <Route path="/inventario" element={<InventarioPage />} />
            <Route path="/usuarios-registrados" element={<UsuariosRegistradosPage />} />
            <Route path="/laboratorio" element={<LaboratorioPage />} />
            <Route path="/ecografia" element={<EcografiaPage />} />
            <Route path="/" element={<Navigate to="/dashboard" />} />
          </Route>
        ) : (
          <Route path="*" element={<Navigate to="/login" />} />
        )}
      </Routes>
    </BrowserRouter>
  )
}

export default App
