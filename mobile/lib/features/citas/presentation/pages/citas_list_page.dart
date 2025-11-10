import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/citas_provider.dart';
import '../widgets/cita_card.dart';

/// Página de lista de citas con tabs (Próximas/Pasadas)
class CitasListPage extends ConsumerWidget {
  const CitasListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Citas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(citasListProvider);
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Próximas', icon: Icon(Icons.event_available)),
              Tab(text: 'Pasadas', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ProximasTab(),
            _PasadasTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push('/citas/nueva');
          },
          icon: const Icon(Icons.add),
          label: const Text('Agendar Cita'),
        ),
      ),
    );
  }
}

/// Tab de citas próximas
class _ProximasTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citasAsync = ref.watch(citasProximasProvider);

    return citasAsync.when(
      data: (citas) {
        if (citas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No tienes citas próximas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Agenda una cita para tu mascota',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/citas/nueva');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agendar Cita'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(citasListProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: citas.length,
            itemBuilder: (context, index) {
              final cita = citas[index];
              return CitaCard(
                cita: cita,
                onTap: () {
                  context.push('/citas/${cita.id}');
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar citas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(citasListProvider);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab de citas pasadas
class _PasadasTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citasAsync = ref.watch(citasPasadasProvider);

    return citasAsync.when(
      data: (citas) {
        if (citas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay citas pasadas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(citasListProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: citas.length,
            itemBuilder: (context, index) {
              final cita = citas[index];
              return CitaCard(
                cita: cita,
                onTap: () {
                  context.push('/citas/${cita.id}');
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar citas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(citasListProvider);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
