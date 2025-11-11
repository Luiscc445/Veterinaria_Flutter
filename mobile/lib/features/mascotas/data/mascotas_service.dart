import '../../../core/config/supabase_config.dart';
import '../../../shared/models/mascota_model.dart';

/// Servicio para gestionar mascotas (Arquitectura MVC - Modelo)
/// Este servicio usa funciones SQL seguras para evitar errores de permisos
class MascotasService {
  /// Obtener todas las mascotas del tutor actual
  /// Usa función SQL segura (get_my_mascotas) para evitar "permission denied"
  Future<List<MascotaModel>> obtenerMisMascotas() async {
    try {
      // Llamar función SQL segura que maneja RLS internamente
      final response = await supabase.rpc('get_my_mascotas');

      return (response as List)
          .map((json) => MascotaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener mascotas: $e');
    }
  }

  /// Obtener una mascota por ID
  Future<MascotaModel> obtenerMascotaPorId(String id) async {
    try {
      final response = await supabase
          .from('mascotas')
          .select()
          .eq('id', id)
          .isFilter('deleted_at', null)
          .single();

      return MascotaModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener mascota: $e');
    }
  }

  /// Crear nueva mascota
  /// Usa función SQL segura (create_mascota) para evitar problemas de permisos
  Future<String> crearMascota({
    required String nombre,
    required String especie,
    String? raza,
    String? sexo,
    DateTime? fechaNacimiento,
    double? pesoKg,
    String? color,
    String? microchip,
    String? fotoUrl,
    String? alergias,
    String? condicionesPreexistentes,
    bool esterilizado = false,
  }) async {
    try {
      // Llamar función SQL segura
      final mascotaId = await supabase.rpc('create_mascota', params: {
        'p_nombre': nombre,
        'p_especie': especie,
        'p_raza': raza,
        'p_sexo': sexo,
        'p_fecha_nacimiento': fechaNacimiento?.toIso8601String(),
        'p_peso_kg': pesoKg,
        'p_color': color,
        'p_microchip': microchip,
        'p_foto_url': fotoUrl,
        'p_alergias': alergias,
        'p_condiciones_preexistentes': condicionesPreexistentes,
        'p_esterilizado': esterilizado,
      });

      return mascotaId as String;
    } catch (e) {
      throw Exception('Error al crear mascota: $e');
    }
  }

  /// Actualizar mascota
  Future<MascotaModel> actualizarMascota(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await supabase
          .from('mascotas')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return MascotaModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar mascota: $e');
    }
  }

  /// Eliminar mascota (soft delete)
  Future<void> eliminarMascota(String id) async {
    try {
      await supabase
          .from('mascotas')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar mascota: $e');
    }
  }

  /// Subir foto de mascota a Supabase Storage
  Future<String> subirFoto(String mascotaId, String filePath) async {
    try {
      final fileName = '${mascotaId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage
          .from('mascotas')
          .upload(fileName, filePath);

      final url = supabase.storage
          .from('mascotas')
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      throw Exception('Error al subir foto: $e');
    }
  }
}
