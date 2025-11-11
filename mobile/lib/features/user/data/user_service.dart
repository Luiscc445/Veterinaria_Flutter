import '../../../core/config/supabase_config.dart';

/// Servicio para gestionar usuarios (Arquitectura MVC)
/// Usa funciones SQL seguras para evitar errores de permisos
class UserService {
  /// Obtener datos del usuario actual
  Future<Map<String, dynamic>> obtenerDatosUsuarioActual() async {
    try {
      // Usar función SQL segura
      final response = await supabase.rpc('get_current_user_data');

      if (response == null || (response as List).isEmpty) {
        throw Exception('Usuario no encontrado');
      }

      return (response as List).first as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error al obtener datos de usuario: $e');
    }
  }

  /// Obtener tutor_id del usuario actual
  Future<String?> obtenerTutorIdActual() async {
    try {
      final userData = await obtenerDatosUsuarioActual();
      return userData['tutor_id'] as String?;
    } catch (e) {
      throw Exception('Error al obtener tutor_id: $e');
    }
  }

  /// Obtener profesional_id del usuario actual
  Future<String?> obtenerProfesionalIdActual() async {
    try {
      final userData = await obtenerDatosUsuarioActual();
      return userData['profesional_id'] as String?;
    } catch (e) {
      throw Exception('Error al obtener profesional_id: $e');
    }
  }

  /// Verificar si el usuario es tutor
  Future<bool> esTutor() async {
    try {
      final userData = await obtenerDatosUsuarioActual();
      return userData['rol'] == 'tutor';
    } catch (e) {
      return false;
    }
  }

  /// Verificar si el usuario es médico
  Future<bool> esMedico() async {
    try {
      final userData = await obtenerDatosUsuarioActual();
      return userData['rol'] == 'medico';
    } catch (e) {
      return false;
    }
  }

  /// Verificar si el usuario es admin
  Future<bool> esAdmin() async {
    try {
      final userData = await obtenerDatosUsuarioActual();
      return userData['rol'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Actualizar perfil de usuario
  Future<void> actualizarPerfil({
    String? nombreCompleto,
    String? telefono,
    String? avatarUrl,
  }) async {
    try {
      final userData = await obtenerDatosUsuarioActual();
      final userId = userData['user_id'] as String;

      final updates = <String, dynamic>{};
      if (nombreCompleto != null) updates['nombre_completo'] = nombreCompleto;
      if (telefono != null) updates['telefono'] = telefono;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isEmpty) return;

      await supabase.from('users').update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }
}
