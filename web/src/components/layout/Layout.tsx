import { Outlet, Link, useLocation, useNavigate } from 'react-router-dom'
import { signOut, getCurrentUser } from '../../services/supabase'
import { useState, useEffect } from 'react'

export default function Layout() {
  const location = useLocation()
  const navigate = useNavigate()
  const [userName, setUserName] = useState('')

  useEffect(() => {
    getCurrentUser().then(user => {
      if (user?.user_metadata?.nombre_completo) {
        setUserName(user.user_metadata.nombre_completo)
      } else {
        setUserName(user?.email?.split('@')[0] || 'Usuario')
      }
    })
  }, [])

  const handleLogout = async () => {
    await signOut()
    navigate('/login')
  }

  const menuItems = [
    { path: '/dashboard', label: 'Dashboard', icon: '📊' },
    { path: '/mascotas', label: 'Mascotas', icon: '🐾' },
    { path: '/citas', label: 'Citas', icon: '📅' },
    { path: '/inventario', label: 'Inventario', icon: '💊' },
  ]

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sidebar */}
      <aside className="fixed inset-y-0 left-0 w-64 bg-white shadow-lg z-10">
        <div className="flex flex-col h-full">
          {/* Logo */}
          <div className="p-6 border-b">
            <h1 className="text-2xl font-bold text-primary-600">🐾 RamboPet</h1>
            <p className="text-sm text-gray-600 mt-1">Sistema Veterinario</p>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-4 space-y-2">
            {menuItems.map((item) => (
              <Link
                key={item.path}
                to={item.path}
                className={`flex items-center px-4 py-3 rounded-lg transition-colors ${
                  location.pathname === item.path
                    ? 'bg-primary-50 text-primary-700 font-medium'
                    : 'text-gray-700 hover:bg-gray-50'
                }`}
              >
                <span className="text-2xl mr-3">{item.icon}</span>
                {item.label}
              </Link>
            ))}
          </nav>

          {/* User section */}
          <div className="p-4 border-t">
            <div className="flex items-center mb-3">
              <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center text-primary-600 font-bold">
                {userName[0]?.toUpperCase() || 'U'}
              </div>
              <div className="ml-3 flex-1">
                <p className="text-sm font-medium text-gray-900">{userName}</p>
                <p className="text-xs text-gray-500">Administrador</p>
              </div>
            </div>
            <button
              onClick={handleLogout}
              className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 rounded-lg transition-colors"
            >
              🚪 Cerrar sesión
            </button>
          </div>
        </div>
      </aside>

      {/* Main content */}
      <div className="ml-64">
        <main className="p-8">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
