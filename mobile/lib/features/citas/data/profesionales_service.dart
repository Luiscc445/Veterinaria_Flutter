import '../../../core/config/supabase_config.dart';
import '../../../shared/models/profesional_model.dart';

/// Servicio para obtener profesionales (Arquitectura MVC)
/// Usa funciones SQL seguras para evitar errores de permisos
class ProfesionalesService {
  /// Obtener todos los profesionales activos usando RPC
  Future<List<ProfesionalModel>> obtenerProfesionales() async {
    try {
      // Usar función SQL segura
      final response = await supabase.rpc('get_all_profesionales');

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
      final profesionales = await obtenerProfesionales();
      final profesional = profesionales.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Profesional no encontrado'),
      );
      return profesional;
    } catch (e) {
      throw Exception('Error al obtener profesional: $e');
    }
  }

  /// Obtener profesionales con una especialidad específica
  Future<List<ProfesionalModel>> obtenerProfesionalesPorEspecialidad(
    String especialidad,
  ) async {
    try {
      final profesionales = await obtenerProfesionales();
      return profesionales
          .where((p) => p.especialidades?.contains(especialidad) ?? false)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener profesionales por especialidad: $e');
    }
  }

  /// Obtener horarios de un profesional
  Future<Map<String, dynamic>> obtenerHorarios(String profesionalId) async {
    try {
      final profesional = await obtenerProfesionalPorId(profesionalId);

      // Si tiene horario configurado, devolverlo
      if (profesional.horarioAtencion != null &&
          profesional.horarioAtencion!.isNotEmpty) {
        return profesional.horarioAtencion!;
      }

      // Horarios por defecto
      return {
        'lunes': {'inicio': '09:00', 'fin': '18:00'},
        'martes': {'inicio': '09:00', 'fin': '18:00'},
        'miercoles': {'inicio': '09:00', 'fin': '18:00'},
        'jueves': {'inicio': '09:00', 'fin': '18:00'},
        'viernes': {'inicio': '09:00', 'fin': '18:00'},
      };
    } catch (e) {
      throw Exception('Error al obtener horarios: $e');
    }
  }
}
