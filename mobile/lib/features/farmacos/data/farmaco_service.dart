import '../../../core/config/supabase_config.dart';

/// Modelo simple para Fármaco
class FarmacoModel {
  final String id;
  final String nombreComercial;
  final String nombreGenerico;
  final String? laboratorio;
  final String principioActivo;
  final String? concentracion;
  final String? formaFarmaceutica;
  final String? unidadMedida;
  final List<String>? viaAdministracion;
  final String? indicaciones;
  final int stockTotal;
  final int stockMinimo;

  FarmacoModel({
    required this.id,
    required this.nombreComercial,
    required this.nombreGenerico,
    this.laboratorio,
    required this.principioActivo,
    this.concentracion,
    this.formaFarmaceutica,
    this.unidadMedida,
    this.viaAdministracion,
    this.indicaciones,
    required this.stockTotal,
    required this.stockMinimo,
  });

  factory FarmacoModel.fromJson(Map<String, dynamic> json) {
    return FarmacoModel(
      id: json['id'] as String,
      nombreComercial: json['nombre_comercial'] as String,
      nombreGenerico: json['nombre_generico'] as String,
      laboratorio: json['laboratorio'] as String?,
      principioActivo: json['principio_activo'] as String,
      concentracion: json['concentracion'] as String?,
      formaFarmaceutica: json['forma_farmaceutica'] as String?,
      unidadMedida: json['unidad_medida'] as String?,
      viaAdministracion: json['via_administracion'] != null
          ? List<String>.from(json['via_administracion'] as List)
          : null,
      indicaciones: json['indicaciones'] as String?,
      stockTotal: json['stock_total'] as int? ?? 0,
      stockMinimo: json['stock_minimo'] as int? ?? 0,
    );
  }

  String get estadoStock {
    if (stockTotal == 0) return 'SIN STOCK';
    if (stockTotal < stockMinimo) return 'BAJO';
    return 'NORMAL';
  }
}

/// Modelo simple para Lote de Fármaco
class LoteFarmacoModel {
  final String id;
  final String farmacoId;
  final String numeroLote;
  final DateTime fechaVencimiento;
  final int cantidadInicial;
  final int cantidadActual;
  final double? precioCompra;
  final double? precioVenta;
  final String? proveedor;
  final DateTime fechaIngreso;
  final String? ubicacionAlmacen;
  final int diasParaVencer;

  LoteFarmacoModel({
    required this.id,
    required this.farmacoId,
    required this.numeroLote,
    required this.fechaVencimiento,
    required this.cantidadInicial,
    required this.cantidadActual,
    this.precioCompra,
    this.precioVenta,
    this.proveedor,
    required this.fechaIngreso,
    this.ubicacionAlmacen,
    required this.diasParaVencer,
  });

  factory LoteFarmacoModel.fromJson(Map<String, dynamic> json) {
    return LoteFarmacoModel(
      id: json['id'] as String,
      farmacoId: json['farmaco_id'] as String,
      numeroLote: json['numero_lote'] as String,
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento'] as String),
      cantidadInicial: json['cantidad_inicial'] as int,
      cantidadActual: json['cantidad_actual'] as int,
      precioCompra: json['precio_compra'] != null
          ? (json['precio_compra'] as num).toDouble()
          : null,
      precioVenta: json['precio_venta'] != null
          ? (json['precio_venta'] as num).toDouble()
          : null,
      proveedor: json['proveedor'] as String?,
      fechaIngreso: DateTime.parse(json['fecha_ingreso'] as String),
      ubicacionAlmacen: json['ubicacion_almacen'] as String?,
      diasParaVencer: json['dias_para_vencer'] as int,
    );
  }

  String get estadoVencimiento {
    if (diasParaVencer < 0) return 'VENCIDO';
    if (diasParaVencer <= 30) return 'CRÍTICO';
    if (diasParaVencer <= 90) return 'ALERTA';
    return 'VIGENTE';
  }
}

/// Servicio para fármacos (Arquitectura MVC)
/// Usa funciones SQL seguras para evitar errores de permisos
class FarmacoService {
  /// Obtener todos los fármacos usando RPC
  Future<List<FarmacoModel>> obtenerFarmacos() async {
    try {
      final response = await supabase.rpc('get_all_farmacos');

      return (response as List)
          .map((json) => FarmacoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener fármacos: $e');
    }
  }

  /// Obtener un fármaco por ID
  Future<FarmacoModel> obtenerFarmacoPorId(String id) async {
    try {
      final farmacos = await obtenerFarmacos();
      final farmaco = farmacos.firstWhere(
        (f) => f.id == id,
        orElse: () => throw Exception('Fármaco no encontrado'),
      );
      return farmaco;
    } catch (e) {
      throw Exception('Error al obtener fármaco: $e');
    }
  }

  /// Obtener lotes de un fármaco usando RPC
  Future<List<LoteFarmacoModel>> obtenerLotesPorFarmaco(String farmacoId) async {
    try {
      final response = await supabase.rpc('get_lotes_by_farmaco', params: {
        'p_farmaco_id': farmacoId,
      });

      return (response as List)
          .map((json) => LoteFarmacoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener lotes: $e');
    }
  }

  /// Buscar fármacos por nombre
  Future<List<FarmacoModel>> buscarFarmacos(String query) async {
    try {
      final farmacos = await obtenerFarmacos();
      final queryLower = query.toLowerCase();

      return farmacos
          .where((f) =>
              f.nombreComercial.toLowerCase().contains(queryLower) ||
              f.nombreGenerico.toLowerCase().contains(queryLower))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar fármacos: $e');
    }
  }
}
