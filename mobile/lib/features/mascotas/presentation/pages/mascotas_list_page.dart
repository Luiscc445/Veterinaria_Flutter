import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/mascotas_provider.dart';
import '../widgets/mascota_card.dart';

/// Página principal de lista de mascotas
class MascotasListPage extends ConsumerWidget {
  const MascotasListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mascotasAsync = ref.watch(mascotasListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.misMascotas),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(mascotasListProvider);
            },
          ),
        ],
      ),
      body: mascotasAsync.when(
        data: (mascotas) {
          if (mascotas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes mascotas registradas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registra tu primera mascota para comenzar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/mascotas/nueva');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar Mascota'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(mascotasListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mascotas.length,
              itemBuilder: (context, index) {
                final mascota = mascotas[index];
                return MascotaCard(
                  mascota: mascota,
                  onTap: () {
                    context.push('/mascotas/${mascota.id}');
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
                'Error al cargar mascotas',
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
                  ref.invalidate(mascotasListProvider);
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: mascotasAsync.hasValue &&
              mascotasAsync.value!.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                context.push('/mascotas/nueva');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
