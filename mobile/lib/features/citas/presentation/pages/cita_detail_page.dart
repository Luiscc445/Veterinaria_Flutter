import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/citas_provider.dart';

/// Página de detalle de una cita
class CitaDetailPage extends ConsumerWidget {
  final String citaId;

  const CitaDetailPage({super.key, required this.citaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citaAsync = ref.watch(citaPorIdProvider(citaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cita'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(citaPorIdProvider(citaId));
            },
          ),
        ],
      ),
      body: citaAsync.when(
        data: (cita) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado de la cita
                _buildEstadoCard(context, cita.estado, cita.estadoTexto),

                const SizedBox(height: 16),

                // Información principal
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fecha y Hora',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cita.fechaFormateada,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Divider(height: 24),

                        // Mascota
                        _buildInfoRow(
                          context,
                          Icons.pets,
                          'Mascota',
                          cita.nombreMascota,
                        ),
                        const SizedBox(height: 12),

                        // Servicio
                        _buildInfoRow(
                          context,
                          Icons.medical_services,
                          'Servicio',
                          cita.nombreServicio,
                        ),
                        const SizedBox(height: 12),

                        // Profesional
                        _buildInfoRow(
                          context,
                          Icons.person,
                          'Veterinario',
                          cita.nombreProfesional,
                        ),

                        // Consultorio (si existe)
                        if (cita.consultorio != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            Icons.door_front_door,
                            'Consultorio',
                            cita.consultorio!['nombre'] ?? 'No asignado',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Motivo de consulta
                if (cita.motivoConsulta.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notes,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Motivo de Consulta',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cita.motivoConsulta,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Observaciones
                if (cita.observaciones != null && cita.observaciones!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Observaciones',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cita.observaciones!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Motivo de cancelación (si está cancelada)
                if (cita.estado == 'cancelada' &&
                    cita.motivoCancelacion != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cancel, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                'Motivo de Cancelación',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.red[900]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cita.motivoCancelacion!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Botón cancelar (si se puede cancelar)
                if (cita.sePuedeCancelar)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showCancelarDialog(context, ref, citaId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar Cita'),
                    ),
                  ),
              ],
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
                'Error al cargar cita',
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
                  ref.invalidate(citaPorIdProvider(citaId));
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoCard(BuildContext context, String estado, String texto) {
    Color color;
    IconData icon;

    switch (estado) {
      case 'reservada':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'confirmada':
        color = Colors.blue;
        icon = Icons.check_circle_outline;
        break;
      case 'en_sala':
        color = Colors.purple;
        icon = Icons.door_front_door;
        break;
      case 'atendida':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'cancelada':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de la cita',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  texto,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCancelarDialog(BuildContext context, WidgetRef ref, String citaId) {
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de que deseas cancelar esta cita?'),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo de cancelación (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final formNotifier = ref.read(citaFormProvider.notifier);
              final success = await formNotifier.cancelarCita(
                citaId,
                motivoController.text.trim().isNotEmpty
                    ? motivoController.text.trim()
                    : null,
              );

              if (context.mounted) {
                if (success) {
                  ref.invalidate(citaPorIdProvider(citaId));
                  ref.invalidate(citasListProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cita cancelada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error al cancelar cita: ${ref.read(citaFormProvider).error}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}
