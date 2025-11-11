import '../../../core/config/supabase_config.dart';

/// Modelo simple para Consultorio
class ConsultorioModel {
  final String id;
  final String nombre;
  final String numero;
  final String? piso;
  final List<String>? equipamiento;
  final int capacidad;

  ConsultorioModel({
    required this.id,
    required this.nombre,
    required this.numero,
    this.piso,
    this.equipamiento,
    required this.capacidad,
  });

  factory ConsultorioModel.fromJson(Map<String, dynamic> json) {
    return ConsultorioModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      numero: json['numero'] as String,
      piso: json['piso'] as String?,
      equipamiento: json['equipamiento'] != null
          ? List<String>.from(json['equipamiento'] as List)
          : null,
      capacidad: json['capacidad'] as int? ?? 1,
    );
  }
}

/// Servicio para consultorios (Arquitectura MVC)
/// Usa funciones SQL seguras para evitar errores de permisos
class ConsultoriosService {
  /// Obtener todos los consultorios activos usando RPC
  Future<List<ConsultorioModel>> obtenerConsultorios() async {
    try {
      // Usar función SQL segura
      final response = await supabase.rpc('get_all_consultorios');

      return (response as List)
          .map((json) => ConsultorioModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener consultorios: $e');
    }
  }

  /// Obtener un consultorio por ID
  Future<ConsultorioModel> obtenerConsultorioPorId(String id) async {
    try {
      final consultorios = await obtenerConsultorios();
      final consultorio = consultorios.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Consultorio no encontrado'),
      );
      return consultorio;
    } catch (e) {
      throw Exception('Error al obtener consultorio: $e');
    }
  }
}
