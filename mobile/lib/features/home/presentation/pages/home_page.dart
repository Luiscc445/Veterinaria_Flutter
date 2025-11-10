import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../mascotas/presentation/pages/mascotas_list_page.dart';
import '../../../citas/presentation/pages/citas_list_page.dart';

/// Página principal con navegación bottom bar
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const MascotasListPage(),
    const CitasListPage(),
    const PerfilTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// Tab de Inicio
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.pets, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 8),
            const Text('RamboPet'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Text(
              '¡Bienvenido!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona la salud de tus mascotas',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Accesos rápidos
            Text(
              'Accesos Rápidos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _QuickAccessCard(
                  icon: Icons.pets,
                  title: 'Mis Mascotas',
                  subtitle: 'Ver todas',
                  color: Colors.blue,
                  onTap: () {
                    // Cambia al tab de mascotas
                  },
                ),
                _QuickAccessCard(
                  icon: Icons.calendar_today,
                  title: 'Agendar Cita',
                  subtitle: 'Nueva cita',
                  color: Colors.green,
                  onTap: () {
                    context.push('/citas/nueva');
                  },
                ),
                _QuickAccessCard(
                  icon: Icons.medical_services,
                  title: 'Historial',
                  subtitle: 'Ver consultas',
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Ir a historial
                  },
                ),
                _QuickAccessCard(
                  icon: Icons.add_circle,
                  title: 'Nueva Mascota',
                  subtitle: 'Registrar',
                  color: Colors.orange,
                  onTap: () {
                    context.push('/mascotas/nueva');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Próximas citas
            Text(
              'Próximas Citas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No hay citas próximas',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Agenda una cita para tu mascota',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de acceso rápido
class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab de Perfil
class PerfilTab extends StatelessWidget {
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.miPerfil)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar y datos
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? 'Usuario',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Opciones
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Editar Perfil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Editar perfil
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Cambiar Contraseña'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Cambiar contraseña
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Acerca de'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'RamboPet',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.pets, size: 48),
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Cerrar sesión
          ElevatedButton.icon(
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                context.go(AppConstants.loginRoute);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
