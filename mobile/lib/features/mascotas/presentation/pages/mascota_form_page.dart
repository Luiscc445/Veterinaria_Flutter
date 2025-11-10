import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/mascota_model.dart';
import '../providers/mascotas_provider.dart';

/// Página de formulario para crear o editar mascota
class MascotaFormPage extends ConsumerStatefulWidget {
  final String? mascotaId; // null = crear, !null = editar

  const MascotaFormPage({super.key, this.mascotaId});

  @override
  ConsumerState<MascotaFormPage> createState() => _MascotaFormPageState();
}

class _MascotaFormPageState extends ConsumerState<MascotaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _colorController = TextEditingController();
  final _microchipController = TextEditingController();
  final _seniasController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _condicionesController = TextEditingController();

  String? _especieSeleccionada;
  String? _sexoSeleccionado;
  DateTime? _fechaNacimiento;
  bool _esterilizado = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.mascotaId != null) {
      _cargarMascota();
    }
  }

  Future<void> _cargarMascota() async {
    // TODO: Cargar datos de la mascota a editar
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _pesoController.dispose();
    _colorController.dispose();
    _microchipController.dispose();
    _seniasController.dispose();
    _alergiasController.dispose();
    _condicionesController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'AR'),
    );

    if (fecha != null) {
      setState(() {
        _fechaNacimiento = fecha;
      });
    }
  }

  Future<void> _guardarMascota() async {
    if (!_formKey.currentState!.validate()) return;

    if (_especieSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una especie'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'nombre': _nombreController.text.trim(),
      'especie': _especieSeleccionada,
      'raza': _razaController.text.trim().isEmpty ? null : _razaController.text.trim(),
      'sexo': _sexoSeleccionado,
      'fecha_nacimiento': _fechaNacimiento?.toIso8601String(),
      'peso_kg': _pesoController.text.isEmpty ? null : double.tryParse(_pesoController.text),
      'color': _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
      'microchip': _microchipController.text.trim().isEmpty ? null : _microchipController.text.trim(),
      'senias_particulares': _seniasController.text.trim().isEmpty ? null : _seniasController.text.trim(),
      'alergias': _alergiasController.text.trim().isEmpty ? null : _alergiasController.text.trim(),
      'condiciones_preexistentes': _condicionesController.text.trim().isEmpty ? null : _condicionesController.text.trim(),
      'esterilizado': _esterilizado,
    };

    final formNotifier = ref.read(mascotaFormProvider.notifier);
    final success = widget.mascotaId == null
        ? await formNotifier.crearMascota(data)
        : await formNotifier.actualizarMascota(widget.mascotaId!, data);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Invalidar la lista de mascotas para refrescarla
      ref.invalidate(mascotasListProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.mascotaId == null
                ? 'Mascota registrada exitosamente. Pendiente de aprobación.'
                : 'Mascota actualizada exitosamente',
          ),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${ref.read(mascotaFormProvider).error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(mascotaFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mascotaId == null ? 'Registrar Mascota' : 'Editar Mascota'),
      ),
      body: formState.isLoading || _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Información básica
                    Text(
                      'Información Básica',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre *',
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Especie
                    DropdownButtonFormField<String>(
                      value: _especieSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Especie *',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: AppConstants.especiesMascotas.map((especie) {
                        return DropdownMenuItem(
                          value: especie,
                          child: Text(especie),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _especieSeleccionada = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'La especie es requerida';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Raza
                    TextFormField(
                      controller: _razaController,
                      decoration: const InputDecoration(
                        labelText: 'Raza',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sexo
                    DropdownButtonFormField<String>(
                      value: _sexoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Sexo',
                        prefixIcon: Icon(Icons.male),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'macho', child: Text('Macho')),
                        DropdownMenuItem(value: 'hembra', child: Text('Hembra')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sexoSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fecha de nacimiento
                    InkWell(
                      onTap: _seleccionarFecha,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de Nacimiento',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _fechaNacimiento == null
                              ? 'Seleccionar fecha'
                              : DateFormat('dd/MM/yyyy').format(_fechaNacimiento!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Peso
                    TextFormField(
                      controller: _pesoController,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Color
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Color',
                        prefixIcon: Icon(Icons.palette),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Información adicional
                    Text(
                      'Información Adicional',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Microchip
                    TextFormField(
                      controller: _microchipController,
                      decoration: const InputDecoration(
                        labelText: 'Número de Microchip',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Señas particulares
                    TextFormField(
                      controller: _seniasController,
                      decoration: const InputDecoration(
                        labelText: 'Señas Particulares',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Esterilizado
                    SwitchListTile(
                      title: const Text('Esterilizado'),
                      subtitle: const Text('¿La mascota está esterilizada?'),
                      value: _esterilizado,
                      onChanged: (value) {
                        setState(() {
                          _esterilizado = value;
                        });
                      },
                      secondary: const Icon(Icons.health_and_safety),
                    ),
                    const SizedBox(height: 24),

                    // Información médica
                    Text(
                      'Información Médica',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Alergias
                    TextFormField(
                      controller: _alergiasController,
                      decoration: const InputDecoration(
                        labelText: 'Alergias',
                        prefixIcon: Icon(Icons.warning_amber),
                        hintText: 'Ej: Polen, ciertos alimentos, medicamentos',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Condiciones preexistentes
                    TextFormField(
                      controller: _condicionesController,
                      decoration: const InputDecoration(
                        labelText: 'Condiciones Preexistentes',
                        prefixIcon: Icon(Icons.medical_services),
                        hintText: 'Ej: Diabetes, problemas cardíacos',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Botón guardar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _guardarMascota,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          widget.mascotaId == null
                              ? 'Registrar Mascota'
                              : 'Guardar Cambios',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nota informativa
                    if (widget.mascotaId == null)
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tu mascota quedará pendiente de aprobación por el personal de la clínica.',
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
