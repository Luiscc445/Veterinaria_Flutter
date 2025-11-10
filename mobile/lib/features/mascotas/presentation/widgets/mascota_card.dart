import 'package:flutter/material.dart';
import '../../../../shared/models/mascota_model.dart';

/// Card de mascota para la lista
class MascotaCard extends StatelessWidget {
  final MascotaModel mascota;
  final VoidCallback? onTap;

  const MascotaCard({
    super.key,
    required this.mascota,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Foto o avatar
              CircleAvatar(
                radius: 32,
                backgroundImage: mascota.fotoUrl != null
                    ? NetworkImage(mascota.fotoUrl!)
                    : null,
                child: mascota.fotoUrl == null
                    ? Icon(
                        Icons.pets,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mascota.nombre,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${mascota.especie}${mascota.raza != null ? ' • ${mascota.raza}' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (mascota.fechaNacimiento != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        mascota.edadAproximada,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              // Badge de estado
              _buildEstadoBadge(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoBadge(BuildContext context) {
    Color color;
    IconData icon;

    switch (mascota.estado) {
      case 'aprobado':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rechazado':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'pendiente':
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          mascota.estadoBadge,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
