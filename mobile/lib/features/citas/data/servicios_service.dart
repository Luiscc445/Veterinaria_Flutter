import '../../../core/config/supabase_config.dart';
import '../../../shared/models/servicio_model.dart';

/// Servicio para obtener catálogo de servicios (Arquitectura MVC)
/// Usa funciones SQL seguras para evitar errores de permisos
class ServiciosService {
  /// Obtener todos los servicios activos usando RPC
  Future<List<ServicioModel>> obtenerServicios() async {
    try {
      // Usar función SQL segura
      final response = await supabase.rpc('get_all_servicios');

      return (response as List)
          .map((json) => ServicioModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener servicios: $e');
    }
  }

  /// Obtener un servicio por ID
  Future<ServicioModel> obtenerServicioPorId(String id) async {
    try {
      final servicios = await obtenerServicios();
      final servicio = servicios.firstWhere(
        (s) => s.id == id,
        orElse: () => throw Exception('Servicio no encontrado'),
      );
      return servicio;
    } catch (e) {
      throw Exception('Error al obtener servicio: $e');
    }
  }

  /// Obtener servicios por tipo
  Future<List<ServicioModel>> obtenerServiciosPorTipo(String tipo) async {
    try {
      final servicios = await obtenerServicios();
      return servicios.where((s) => s.tipo == tipo).toList();
    } catch (e) {
      throw Exception('Error al obtener servicios por tipo: $e');
    }
  }

  /// Obtener servicios agrupados por tipo
  Future<Map<String, List<ServicioModel>>> obtenerServiciosAgrupados() async {
    try {
      final servicios = await obtenerServicios();

      // Agrupar por tipo
      final Map<String, List<ServicioModel>> agrupados = {};

      for (final servicio in servicios) {
        final tipo = servicio.tipoFormateado;
        if (!agrupados.containsKey(tipo)) {
          agrupados[tipo] = [];
        }
        agrupados[tipo]!.add(servicio);
      }

      return agrupados;
    } catch (e) {
      throw Exception('Error al obtener servicios agrupados: $e');
    }
  }
}
