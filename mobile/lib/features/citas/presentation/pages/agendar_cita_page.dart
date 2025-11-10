import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/models/mascota_model.dart';
import '../../../../shared/models/servicio_model.dart';
import '../../../../shared/models/profesional_model.dart';
import '../../../mascotas/presentation/providers/mascotas_provider.dart';
import '../providers/citas_provider.dart';

/// Página para agendar nueva cita (multi-step)
class AgendarCitaPage extends ConsumerStatefulWidget {
  const AgendarCitaPage({super.key});

  @override
  ConsumerState<AgendarCitaPage> createState() => _AgendarCitaPageState();
}

class _AgendarCitaPageState extends ConsumerState<AgendarCitaPage> {
  int _currentStep = 0;

  // Form data
  MascotaModel? _mascotaSeleccionada;
  ServicioModel? _servicioSeleccionado;
  ProfesionalModel? _profesionalSeleccionado;
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada;
  String? _fechaHoraCompleta;

  final _motivoController = TextEditingController();
  final _observacionesController = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Cita'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 4;
          return Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(isLastStep ? 'Confirmar' : 'Siguiente'),
              ),
              const SizedBox(width: 8),
              if (_currentStep > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Atrás'),
                ),
            ],
          );
        },
        steps: [
          // Paso 1: Seleccionar mascota
          Step(
            title: const Text('Selecciona tu mascota'),
            content: _buildStepMascota(),
            isActive: _currentStep >= 0,
            state: _mascotaSeleccionada != null
                ? StepState.complete
                : StepState.indexed,
          ),

          // Paso 2: Seleccionar servicio
          Step(
            title: const Text('Selecciona el servicio'),
            content: _buildStepServicio(),
            isActive: _currentStep >= 1,
            state: _servicioSeleccionado != null
                ? StepState.complete
                : StepState.indexed,
          ),

          // Paso 3: Seleccionar profesional
          Step(
            title: const Text('Selecciona el veterinario'),
            content: _buildStepProfesional(),
            isActive: _currentStep >= 2,
            state: _profesionalSeleccionado != null
                ? StepState.complete
                : StepState.indexed,
          ),

          // Paso 4: Seleccionar fecha y hora
          Step(
            title: const Text('Selecciona fecha y hora'),
            content: _buildStepFechaHora(),
            isActive: _currentStep >= 3,
            state:
                _fechaHoraCompleta != null ? StepState.complete : StepState.indexed,
          ),

          // Paso 5: Motivo y confirmación
          Step(
            title: const Text('Detalles de la cita'),
            content: _buildStepConfirmacion(),
            isActive: _currentStep >= 4,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // STEP BUILDERS
  // ============================================================================

  Widget _buildStepMascota() {
    final mascotasAsync = ref.watch(mascotasListProvider);

    return mascotasAsync.when(
      data: (mascotas) {
        // Filtrar solo mascotas aprobadas
        final mascotasAprobadas =
            mascotas.where((m) => m.estado == 'aprobado').toList();

        if (mascotasAprobadas.isEmpty) {
          return const Text(
            'No tienes mascotas aprobadas. Por favor, espera a que tu mascota sea aprobada o registra una nueva.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: mascotasAprobadas.map((mascota) {
            final isSelected = _mascotaSeleccionada?.id == mascota.id;
            return Card(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
              child: RadioListTile<String>(
                value: mascota.id,
                groupValue: _mascotaSeleccionada?.id,
                onChanged: (value) {
                  setState(() {
                    _mascotaSeleccionada = mascota;
                  });
                },
                title: Text(mascota.nombre),
                subtitle: Text('${mascota.especie} • ${mascota.edadAproximada}'),
                secondary: CircleAvatar(
                  child: Icon(Icons.pets),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildStepServicio() {
    final serviciosAsync = ref.watch(serviciosListProvider);

    return serviciosAsync.when(
      data: (servicios) {
        if (servicios.isEmpty) {
          return const Text('No hay servicios disponibles.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: servicios.map((servicio) {
            final isSelected = _servicioSeleccionado?.id == servicio.id;
            return Card(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
              child: RadioListTile<String>(
                value: servicio.id,
                groupValue: _servicioSeleccionado?.id,
                onChanged: (value) {
                  setState(() {
                    _servicioSeleccionado = servicio;
                  });
                },
                title: Text(servicio.nombre),
                subtitle: Text(
                  '${servicio.tipoFormateado} • ${servicio.duracionFormateada}',
                ),
                secondary: Text(
                  servicio.iconoTipo,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildStepProfesional() {
    final profesionalesAsync = ref.watch(profesionalesListProvider);

    return profesionalesAsync.when(
      data: (profesionales) {
        if (profesionales.isEmpty) {
          return const Text('No hay profesionales disponibles.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: profesionales.map((profesional) {
            final isSelected = _profesionalSeleccionado?.id == profesional.id;
            return Card(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
              child: RadioListTile<String>(
                value: profesional.id,
                groupValue: _profesionalSeleccionado?.id,
                onChanged: (value) {
                  setState(() {
                    _profesionalSeleccionado = profesional;
                  });
                },
                title: Text(profesional.tituloProfesional),
                subtitle: Text(profesional.especialidadesTexto),
                secondary: CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildStepFechaHora() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de fecha
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              _fechaSeleccionada == null
                  ? 'Seleccionar fecha'
                  : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectFecha,
          ),
        ),

        // Horarios disponibles (si ya se seleccionó fecha)
        if (_fechaSeleccionada != null) ...[
          const SizedBox(height: 16),
          Text(
            'Horarios disponibles:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildHorariosDisponibles(),
        ],
      ],
    );
  }

  Widget _buildHorariosDisponibles() {
    if (_profesionalSeleccionado == null ||
        _servicioSeleccionado == null ||
        _fechaSeleccionada == null) {
      return const Text('Selecciona fecha, servicio y profesional primero.');
    }

    final fechaStr =
        '${_fechaSeleccionada!.year}-${_fechaSeleccionada!.month.toString().padStart(2, '0')}-${_fechaSeleccionada!.day.toString().padStart(2, '0')}';

    final disponibilidadAsync = ref.watch(
      disponibilidadProvider({
        'profesionalId': _profesionalSeleccionado!.id,
        'fecha': fechaStr,
        'servicioId': _servicioSeleccionado!.id,
      }),
    );

    return disponibilidadAsync.when(
      data: (horarios) {
        if (horarios.isEmpty) {
          return const Text('No hay horarios disponibles para esta fecha.');
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: horarios.map((horario) {
            final hora = horario['hora'];
            final isSelected = _horaSeleccionada == hora;
            return ChoiceChip(
              label: Text(hora),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _horaSeleccionada = hora;
                    _fechaHoraCompleta = horario['fecha_hora'];
                  });
                }
              },
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error al cargar horarios: $error'),
    );
  }

  Widget _buildStepConfirmacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen de la cita:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(),
                _buildResumenItem(
                  Icons.pets,
                  'Mascota',
                  _mascotaSeleccionada?.nombre ?? '',
                ),
                _buildResumenItem(
                  Icons.medical_services,
                  'Servicio',
                  _servicioSeleccionado?.nombre ?? '',
                ),
                _buildResumenItem(
                  Icons.person,
                  'Veterinario',
                  _profesionalSeleccionado?.nombreCompleto ?? '',
                ),
                _buildResumenItem(
                  Icons.calendar_today,
                  'Fecha y hora',
                  _fechaSeleccionada != null && _horaSeleccionada != null
                      ? '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year} - $_horaSeleccionada'
                      : '',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Motivo de consulta
        TextField(
          controller: _motivoController,
          decoration: const InputDecoration(
            labelText: 'Motivo de la consulta *',
            hintText: 'Ej: Vacunación, chequeo general, etc.',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),

        const SizedBox(height: 16),

        // Observaciones
        TextField(
          controller: _observacionesController,
          decoration: const InputDecoration(
            labelText: 'Observaciones (opcional)',
            hintText: 'Información adicional...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildResumenItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
      ),
    );
  }

  // ============================================================================
  // ACTIONS
  // ============================================================================

  Future<void> _selectFecha() async {
    final now = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      locale: const Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _horaSeleccionada = null;
        _fechaHoraCompleta = null;
      });
    }
  }

  Future<void> _onStepContinue() async {
    // Validar cada paso
    if (_currentStep == 0 && _mascotaSeleccionada == null) {
      _showError('Selecciona una mascota');
      return;
    }

    if (_currentStep == 1 && _servicioSeleccionado == null) {
      _showError('Selecciona un servicio');
      return;
    }

    if (_currentStep == 2 && _profesionalSeleccionado == null) {
      _showError('Selecciona un profesional');
      return;
    }

    if (_currentStep == 3 && _fechaHoraCompleta == null) {
      _showError('Selecciona fecha y hora');
      return;
    }

    if (_currentStep == 4) {
      // Último paso: validar y crear cita
      if (_motivoController.text.trim().isEmpty) {
        _showError('El motivo de la consulta es requerido');
        return;
      }

      await _crearCita();
      return;
    }

    // Avanzar al siguiente paso
    setState(() {
      _currentStep++;
    });
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _crearCita() async {
    final data = {
      'mascota_id': _mascotaSeleccionada!.id,
      'servicio_id': _servicioSeleccionado!.id,
      'profesional_id': _profesionalSeleccionado!.id,
      'fecha_hora': _fechaHoraCompleta!,
      'motivo_consulta': _motivoController.text.trim(),
      'observaciones': _observacionesController.text.trim().isNotEmpty
          ? _observacionesController.text.trim()
          : null,
    };

    final formNotifier = ref.read(citaFormProvider.notifier);
    final success = await formNotifier.crearCita(data);

    if (!mounted) return;

    if (success) {
      // Invalidar la lista para refrescar
      ref.invalidate(citasListProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cita agendada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } else {
      final error = ref.read(citaFormProvider).error;
      _showError('Error al crear cita: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
