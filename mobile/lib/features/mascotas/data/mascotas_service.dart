import '../../../core/config/supabase_config.dart';
import '../../../shared/models/mascota_model.dart';

/// Servicio para gestionar mascotas
class MascotasService {
  /// Obtener todas las mascotas del tutor actual
  Future<List<MascotaModel>> obtenerMisMascotas() async {
    try {
      // Primero obtener el tutor_id
      final userId = currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      final tutorResponse = await supabase
          .from('tutores')
          .select('id')
          .eq('user_id', userId)
          .single();

      final tutorId = tutorResponse['id'];

      // Obtener mascotas del tutor
      final response = await supabase
          .from('mascotas')
          .select()
          .eq('tutor_id', tutorId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

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
  Future<MascotaModel> crearMascota(Map<String, dynamic> data) async {
    try {
      // Obtener tutor_id del usuario actual
      final userId = currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      final tutorResponse = await supabase
          .from('tutores')
          .select('id')
          .eq('user_id', userId)
          .single();

      final tutorId = tutorResponse['id'];

      // Agregar tutor_id a los datos
      data['tutor_id'] = tutorId;
      data['estado'] = 'pendiente';
      data['activo'] = true;

      final response = await supabase
          .from('mascotas')
          .insert(data)
          .select()
          .single();

      return MascotaModel.fromJson(response);
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
