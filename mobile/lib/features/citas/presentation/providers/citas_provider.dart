import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../shared/models/cita_model.dart';
import '../../../../shared/models/servicio_model.dart';
import '../../../../shared/models/profesional_model.dart';
import '../../data/citas_service.dart';
import '../../data/servicios_service.dart';
import '../../data/profesionales_service.dart';

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

/// Provider del servicio de citas
final citasServiceProvider = Provider((ref) => CitasService());

/// Provider del servicio de servicios
final serviciosServiceProvider = Provider((ref) => ServiciosService());

/// Provider del servicio de profesionales
final profesionalesServiceProvider = Provider((ref) => ProfesionalesService());

// ============================================================================
// DATA PROVIDERS
// ============================================================================

/// Provider para obtener mis citas (retorna mapa con proximas/pasadas)
final citasListProvider =
    FutureProvider<Map<String, List<CitaModel>>>((ref) async {
  final service = ref.watch(citasServiceProvider);
  return service.obtenerMisCitas();
});

/// Provider para obtener una cita específica por ID
final citaPorIdProvider =
    FutureProvider.family<CitaModel, String>((ref, id) async {
  final service = ref.watch(citasServiceProvider);
  return service.obtenerCitaPorId(id);
});

/// Provider para obtener lista de servicios
final serviciosListProvider = FutureProvider<List<ServicioModel>>((ref) async {
  final service = ref.watch(serviciosServiceProvider);
  return service.obtenerServicios();
});

/// Provider para obtener lista de profesionales
final profesionalesListProvider =
    FutureProvider<List<ProfesionalModel>>((ref) async {
  final service = ref.watch(profesionalesServiceProvider);
  return service.obtenerProfesionales();
});

/// Provider para obtener disponibilidad de horarios
/// Params: {profesionalId, fecha, servicioId}
final disponibilidadProvider = FutureProvider.family<
    List<Map<String, dynamic>>,
    Map<String, String>>((ref, params) async {
  final service = ref.watch(citasServiceProvider);
  return service.obtenerDisponibilidad(
    profesionalId: params['profesionalId']!,
    fecha: params['fecha']!,
    servicioId: params['servicioId']!,
  );
});

// ============================================================================
// FORM STATE NOTIFIER
// ============================================================================

/// StateNotifier para gestionar el estado del formulario de citas
class CitaFormNotifier extends Notifier<AsyncValue<CitaModel?>> {
  late final CitasService _service;

  @override
  AsyncValue<CitaModel?> build() {
    _service = ref.watch(citasServiceProvider);
    return const AsyncValue.data(null);
  }

  /// Crear nueva cita
  Future<bool> crearCita(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    try {
      final cita = await _service.crearCita(data);
      state = AsyncValue.data(cita);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Actualizar cita
  Future<bool> actualizarCita(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    try {
      final cita = await _service.actualizarCita(id, data);
      state = AsyncValue.data(cita);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Cancelar cita
  Future<bool> cancelarCita(String id, String? motivo) async {
    state = const AsyncValue.loading();

    try {
      final cita = await _service.cancelarCita(id, motivo);
      state = AsyncValue.data(cita);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Verificar si una mascota está aprobada
  Future<bool> verificarMascotaAprobada(String mascotaId) async {
    try {
      return await _service.verificarMascotaAprobada(mascotaId);
    } catch (e) {
      return false;
    }
  }

  /// Reset del estado
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider del notifier de formulario de cita
final citaFormProvider = NotifierProvider<CitaFormNotifier, AsyncValue<CitaModel?>>(() {
  return CitaFormNotifier();
});

// ============================================================================
// HELPER PROVIDERS
// ============================================================================

/// Provider para filtrar solo citas próximas
final citasProximasProvider = Provider<AsyncValue<List<CitaModel>>>((ref) {
  final citasAsync = ref.watch(citasListProvider);
  return citasAsync.whenData((data) => data['proximas'] ?? []);
});

/// Provider para filtrar solo citas pasadas
final citasPasadasProvider = Provider<AsyncValue<List<CitaModel>>>((ref) {
  final citasAsync = ref.watch(citasListProvider);
  return citasAsync.whenData((data) => data['pasadas'] ?? []);
});

