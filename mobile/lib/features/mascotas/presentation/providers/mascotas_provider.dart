import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/mascota_model.dart';
import '../../data/mascotas_service.dart';

/// Provider del servicio de mascotas
final mascotasServiceProvider = Provider((ref) => MascotasService());

/// Provider para obtener la lista de mascotas
final mascotasListProvider = FutureProvider<List<MascotaModel>>((ref) async {
  final service = ref.watch(mascotasServiceProvider);
  return service.obtenerMisMascotas();
});

/// Provider para obtener una mascota específica por ID
final mascotaPorIdProvider = FutureProvider.family<MascotaModel, String>((ref, id) async {
  final service = ref.watch(mascotasServiceProvider);
  return service.obtenerMascotaPorId(id);
});

/// StateNotifier para gestionar el estado de creación/edición de mascotas
class MascotaFormNotifier extends StateNotifier<AsyncValue<MascotaModel?>> {
  final MascotasService _service;

  MascotaFormNotifier(this._service) : super(const AsyncValue.data(null));

  Future<bool> crearMascota(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    try {
      final mascota = await _service.crearMascota(data);
      state = AsyncValue.data(mascota);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> actualizarMascota(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    try {
      final mascota = await _service.actualizarMascota(id, data);
      state = AsyncValue.data(mascota);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> eliminarMascota(String id) async {
    state = const AsyncValue.loading();

    try {
      await _service.eliminarMascota(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<String?> subirFoto(String mascotaId, String filePath) async {
    try {
      return await _service.subirFoto(mascotaId, filePath);
    } catch (e) {
      return null;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider del notifier de formulario de mascota
final mascotaFormProvider =
    StateNotifierProvider<MascotaFormNotifier, AsyncValue<MascotaModel?>>((ref) {
  final service = ref.watch(mascotasServiceProvider);
  return MascotaFormNotifier(service);
});
