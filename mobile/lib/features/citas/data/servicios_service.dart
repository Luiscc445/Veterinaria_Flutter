import '../../../core/config/supabase_config.dart';
import '../../../shared/models/servicio_model.dart';

/// Servicio para obtener catálogo de servicios
class ServiciosService {
  /// Obtener todos los servicios activos
  Future<List<ServicioModel>> obtenerServicios() async {
    try {
      final response = await supabase
          .from('servicios')
          .select()
          .eq('activo', true)
          .order('nombre', ascending: true);

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
      final response = await supabase
          .from('servicios')
          .select()
          .eq('id', id)
          .single();

      return ServicioModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener servicio: $e');
    }
  }

  /// Obtener servicios por tipo
  Future<List<ServicioModel>> obtenerServiciosPorTipo(String tipo) async {
    try {
      final response = await supabase
          .from('servicios')
          .select()
          .eq('activo', true)
          .eq('tipo', tipo)
          .order('nombre', ascending: true);

      return (response as List)
          .map((json) => ServicioModel.fromJson(json))
          .toList();
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
