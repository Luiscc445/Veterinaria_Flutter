import '../../../core/config/supabase_config.dart';
import '../../../shared/models/profesional_model.dart';

/// Servicio para obtener profesionales (veterinarios)
class ProfesionalesService {
  /// Obtener todos los profesionales activos
  Future<List<ProfesionalModel>> obtenerProfesionales() async {
    try {
      final response = await supabase
          .from('profesionales')
          .select('''
            *,
            user:users(nombre_completo, email, telefono)
          ''')
          .eq('activo', true)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ProfesionalModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener profesionales: $e');
    }
  }

  /// Obtener un profesional por ID
  Future<ProfesionalModel> obtenerProfesionalPorId(String id) async {
    try {
      final response = await supabase
          .from('profesionales')
          .select('''
            *,
            user:users(nombre_completo, email, telefono)
          ''')
          .eq('id', id)
          .single();

      return ProfesionalModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener profesional: $e');
    }
  }

  /// Obtener profesionales con una especialidad específica
  Future<List<ProfesionalModel>> obtenerProfesionalesPorEspecialidad(
    String especialidad,
  ) async {
    try {
      final response = await supabase
          .from('profesionales')
          .select('''
            *,
            user:users(nombre_completo, email, telefono)
          ''')
          .eq('activo', true)
          .contains('especialidades', [especialidad])
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ProfesionalModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener profesionales por especialidad: $e');
    }
  }

  /// Obtener horarios de un profesional (simplificado)
  /// En el futuro se puede extender para obtener horarios configurados
  Future<Map<String, dynamic>> obtenerHorarios(String profesionalId) async {
    try {
      // Por ahora retornamos horarios fijos
      // En el futuro se puede leer de una tabla de horarios
      return {
        'dias_laborales': ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'],
        'hora_inicio': '09:00',
        'hora_fin': '18:00',
        'duracion_slot': 30, // minutos
      };
    } catch (e) {
      throw Exception('Error al obtener horarios: $e');
    }
  }
}
