/// Modelo de Servicio
class ServicioModel {
  final String id;
  final String nombre;
  final String? descripcion;
  final String tipo; // consulta, cirugia, vacunacion, desparasitacion, emergencia, etc.
  final String? categoria;
  final int duracionMinutos;
  final double? precioBase;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServicioModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipo,
    this.categoria,
    required this.duracionMinutos,
    this.precioBase,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Crear desde JSON
  factory ServicioModel.fromJson(Map<String, dynamic> json) {
    return ServicioModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      tipo: json['tipo'],
      categoria: json['categoria'],
      duracionMinutos: json['duracion_minutos'] ?? 30,
      precioBase: json['precio_base'] != null
          ? double.tryParse(json['precio_base'].toString())
          : null,
      activo: json['activo'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo,
      'categoria': categoria,
      'duracion_minutos': duracionMinutos,
      'precio_base': precioBase,
      'activo': activo,
    };
  }

  /// Copiar con cambios
  ServicioModel copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? tipo,
    String? categoria,
    int? duracionMinutos,
    double? precioBase,
    bool? activo,
  }) {
    return ServicioModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      activo: activo ?? this.activo,
      precioBase: precioBase ?? this.precioBase,
    );
  }

  // Helpers

  /// Duración formateada (ej: "30 min", "1h 30min")
  String get duracionFormateada {
    if (duracionMinutos < 60) {
      return '$duracionMinutos min';
    }
    final horas = duracionMinutos ~/ 60;
    final minutos = duracionMinutos % 60;
    if (minutos == 0) {
      return '${horas}h';
    }
    return '${horas}h ${minutos}min';
  }

  /// Precio formateado (ej: "\$50.00" o "Consultar")
  String get precioFormateado {
    if (precioBase == null) {
      return 'Consultar';
    }
    return '\$${precioBase!.toStringAsFixed(2)}';
  }

  /// Tipo formateado
  String get tipoFormateado {
    switch (tipo.toLowerCase()) {
      case 'consulta':
        return 'Consulta';
      case 'cirugia':
        return 'Cirugía';
      case 'vacunacion':
        return 'Vacunación';
      case 'desparasitacion':
        return 'Desparasitación';
      case 'emergencia':
        return 'Emergencia';
      case 'chequeo':
        return 'Chequeo';
      case 'estetica':
        return 'Estética';
      default:
        return tipo;
    }
  }

  /// Icono según tipo
  String get iconoTipo {
    switch (tipo.toLowerCase()) {
      case 'consulta':
        return '🩺';
      case 'cirugia':
        return '⚕️';
      case 'vacunacion':
        return '💉';
      case 'desparasitacion':
        return '💊';
      case 'emergencia':
        return '🚨';
      case 'chequeo':
        return '📋';
      case 'estetica':
        return '✂️';
      default:
        return '🏥';
    }
  }
}
