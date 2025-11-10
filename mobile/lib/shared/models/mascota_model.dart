/// Modelo de Mascota
class MascotaModel {
  final String id;
  final String tutorId;
  final String nombre;
  final String especie;
  final String? raza;
  final String? sexo;
  final DateTime? fechaNacimiento;
  final double? pesoKg;
  final String? color;
  final String? seniasParticulares;
  final String? microchip;
  final String? fotoUrl;
  final String estado; // pendiente, aprobado, rechazado
  final String? motivoRechazo;
  final String? alergias;
  final String? condicionesPreexistentes;
  final bool? esterilizado;
  final bool activo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MascotaModel({
    required this.id,
    required this.tutorId,
    required this.nombre,
    required this.especie,
    this.raza,
    this.sexo,
    this.fechaNacimiento,
    this.pesoKg,
    this.color,
    this.seniasParticulares,
    this.microchip,
    this.fotoUrl,
    required this.estado,
    this.motivoRechazo,
    this.alergias,
    this.condicionesPreexistentes,
    this.esterilizado,
    required this.activo,
    required this.createdAt,
    this.updatedAt,
  });

  factory MascotaModel.fromJson(Map<String, dynamic> json) {
    return MascotaModel(
      id: json['id'],
      tutorId: json['tutor_id'],
      nombre: json['nombre'],
      especie: json['especie'],
      raza: json['raza'],
      sexo: json['sexo'],
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'])
          : null,
      pesoKg: json['peso_kg'] != null
          ? double.tryParse(json['peso_kg'].toString())
          : null,
      color: json['color'],
      seniasParticulares: json['senias_particulares'],
      microchip: json['microchip'],
      fotoUrl: json['foto_url'],
      estado: json['estado'] ?? 'pendiente',
      motivoRechazo: json['motivo_rechazo'],
      alergias: json['alergias'],
      condicionesPreexistentes: json['condiciones_preexistentes'],
      esterilizado: json['esterilizado'] ?? false,
      activo: json['activo'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tutor_id': tutorId,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'sexo': sexo,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'peso_kg': pesoKg,
      'color': color,
      'senias_particulares': seniasParticulares,
      'microchip': microchip,
      'foto_url': fotoUrl,
      'alergias': alergias,
      'condiciones_preexistentes': condicionesPreexistentes,
      'esterilizado': esterilizado,
    };
  }

  MascotaModel copyWith({
    String? nombre,
    String? especie,
    String? raza,
    String? sexo,
    DateTime? fechaNacimiento,
    double? pesoKg,
    String? color,
    String? seniasParticulares,
    String? microchip,
    String? fotoUrl,
    String? estado,
    String? alergias,
    String? condicionesPreexistentes,
    bool? esterilizado,
    bool? activo,
  }) {
    return MascotaModel(
      id: id,
      tutorId: tutorId,
      nombre: nombre ?? this.nombre,
      especie: especie ?? this.especie,
      raza: raza ?? this.raza,
      sexo: sexo ?? this.sexo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      pesoKg: pesoKg ?? this.pesoKg,
      color: color ?? this.color,
      seniasParticulares: seniasParticulares ?? this.seniasParticulares,
      microchip: microchip ?? this.microchip,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      estado: estado ?? this.estado,
      motivoRechazo: motivoRechazo,
      alergias: alergias ?? this.alergias,
      condicionesPreexistentes: condicionesPreexistentes ?? this.condicionesPreexistentes,
      esterilizado: esterilizado ?? this.esterilizado,
      activo: activo ?? this.activo,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  String get edadAproximada {
    if (fechaNacimiento == null) return 'Desconocida';

    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaNacimiento!);
    final anos = diferencia.inDays ~/ 365;
    final meses = (diferencia.inDays % 365) ~/ 30;

    if (anos > 0) {
      return '$anos año${anos > 1 ? 's' : ''}${meses > 0 ? ' y $meses mes${meses > 1 ? 'es' : ''}' : ''}';
    } else if (meses > 0) {
      return '$meses mes${meses > 1 ? 'es' : ''}';
    } else {
      final dias = diferencia.inDays;
      return '$dias día${dias > 1 ? 's' : ''}';
    }
  }

  String get estadoBadge {
    switch (estado) {
      case 'aprobado':
        return 'Aprobado';
      case 'rechazado':
        return 'Rechazado';
      case 'pendiente':
      default:
        return 'Pendiente';
    }
  }
}
