import 'mascota_model.dart';

/// Modelo de Cita
class CitaModel {
  final String id;
  final String mascotaId;
  final String tutorId;
  final String servicioId;
  final String profesionalId;
  final String? consultorioId;
  final DateTime fechaHora;
  final DateTime? fechaHoraFin;
  final String estado; // reservada, confirmada, en_sala, atendida, cancelada, reprogramada
  final String motivoConsulta;
  final String? observaciones;
  final String? motivoCancelacion;
  final bool checkInRealizado;
  final DateTime? horaCheckIn;
  final DateTime? horaInicioAtencion;
  final DateTime? horaFinAtencion;
  final String? confirmadaPor;
  final DateTime? fechaConfirmacion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relaciones (pueden venir del backend)
  final MascotaModel? mascota;
  final Map<String, dynamic>? servicio;
  final Map<String, dynamic>? profesional;
  final Map<String, dynamic>? consultorio;

  CitaModel({
    required this.id,
    required this.mascotaId,
    required this.tutorId,
    required this.servicioId,
    required this.profesionalId,
    this.consultorioId,
    required this.fechaHora,
    this.fechaHoraFin,
    required this.estado,
    required this.motivoConsulta,
    this.observaciones,
    this.motivoCancelacion,
    this.checkInRealizado = false,
    this.horaCheckIn,
    this.horaInicioAtencion,
    this.horaFinAtencion,
    this.confirmadaPor,
    this.fechaConfirmacion,
    this.createdAt,
    this.updatedAt,
    this.mascota,
    this.servicio,
    this.profesional,
    this.consultorio,
  });

  /// Crear desde JSON
  factory CitaModel.fromJson(Map<String, dynamic> json) {
    return CitaModel(
      id: json['id'],
      mascotaId: json['mascota_id'],
      tutorId: json['tutor_id'],
      servicioId: json['servicio_id'],
      profesionalId: json['profesional_id'],
      consultorioId: json['consultorio_id'],
      fechaHora: DateTime.parse(json['fecha_hora']),
      fechaHoraFin: json['fecha_hora_fin'] != null
          ? DateTime.parse(json['fecha_hora_fin'])
          : null,
      estado: json['estado'],
      motivoConsulta: json['motivo_consulta'] ?? '',
      observaciones: json['observaciones'],
      motivoCancelacion: json['motivo_cancelacion'],
      checkInRealizado: json['check_in_realizado'] ?? false,
      horaCheckIn: json['hora_check_in'] != null
          ? DateTime.parse(json['hora_check_in'])
          : null,
      horaInicioAtencion: json['hora_inicio_atencion'] != null
          ? DateTime.parse(json['hora_inicio_atencion'])
          : null,
      horaFinAtencion: json['hora_fin_atencion'] != null
          ? DateTime.parse(json['hora_fin_atencion'])
          : null,
      confirmadaPor: json['confirmada_por'],
      fechaConfirmacion: json['fecha_confirmacion'] != null
          ? DateTime.parse(json['fecha_confirmacion'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      mascota: json['mascota'] != null
          ? MascotaModel.fromJson(json['mascota'])
          : null,
      servicio: json['servicio'],
      profesional: json['profesional'],
      consultorio: json['consultorio'],
    );
  }

  /// Convertir a JSON (para crear/actualizar)
  Map<String, dynamic> toJson() {
    return {
      'mascota_id': mascotaId,
      'tutor_id': tutorId,
      'servicio_id': servicioId,
      'profesional_id': profesionalId,
      'consultorio_id': consultorioId,
      'fecha_hora': fechaHora.toIso8601String(),
      'fecha_hora_fin': fechaHoraFin?.toIso8601String(),
      'estado': estado,
      'motivo_consulta': motivoConsulta,
      'observaciones': observaciones,
      'motivo_cancelacion': motivoCancelacion,
      'check_in_realizado': checkInRealizado,
      'hora_check_in': horaCheckIn?.toIso8601String(),
      'hora_inicio_atencion': horaInicioAtencion?.toIso8601String(),
      'hora_fin_atencion': horaFinAtencion?.toIso8601String(),
      'confirmada_por': confirmadaPor,
      'fecha_confirmacion': fechaConfirmacion?.toIso8601String(),
    };
  }

  /// Copiar con cambios
  CitaModel copyWith({
    String? id,
    String? mascotaId,
    String? tutorId,
    String? servicioId,
    String? profesionalId,
    String? consultorioId,
    DateTime? fechaHora,
    DateTime? fechaHoraFin,
    String? estado,
    String? motivoConsulta,
    String? observaciones,
    String? motivoCancelacion,
    bool? checkInRealizado,
    DateTime? horaCheckIn,
    DateTime? horaInicioAtencion,
    DateTime? horaFinAtencion,
    String? confirmadaPor,
    DateTime? fechaConfirmacion,
    MascotaModel? mascota,
    Map<String, dynamic>? servicio,
    Map<String, dynamic>? profesional,
    Map<String, dynamic>? consultorio,
  }) {
    return CitaModel(
      id: id ?? this.id,
      mascotaId: mascotaId ?? this.mascotaId,
      tutorId: tutorId ?? this.tutorId,
      servicioId: servicioId ?? this.servicioId,
      profesionalId: profesionalId ?? this.profesionalId,
      consultorioId: consultorioId ?? this.consultorioId,
      fechaHora: fechaHora ?? this.fechaHora,
      fechaHoraFin: fechaHoraFin ?? this.fechaHoraFin,
      estado: estado ?? this.estado,
      motivoConsulta: motivoConsulta ?? this.motivoConsulta,
      observaciones: observaciones ?? this.observaciones,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      checkInRealizado: checkInRealizado ?? this.checkInRealizado,
      horaCheckIn: horaCheckIn ?? this.horaCheckIn,
      horaInicioAtencion: horaInicioAtencion ?? this.horaInicioAtencion,
      horaFinAtencion: horaFinAtencion ?? this.horaFinAtencion,
      confirmadaPor: confirmadaPor ?? this.confirmadaPor,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
      mascota: mascota ?? this.mascota,
      servicio: servicio ?? this.servicio,
      profesional: profesional ?? this.profesional,
      consultorio: consultorio ?? this.consultorio,
    );
  }

  // Helpers

  /// Nombre de la mascota
  String get nombreMascota => mascota?.nombre ?? 'Mascota';

  /// Nombre del servicio
  String get nombreServicio =>
      servicio?['nombre'] ?? 'Servicio';

  /// Nombre del profesional
  String get nombreProfesional {
    if (profesional?['user'] != null) {
      return profesional!['user']['nombre_completo'] ?? 'Veterinario';
    }
    return 'Veterinario';
  }

  /// Color del estado
  String get estadoColor {
    switch (estado) {
      case 'reservada':
        return 'orange';
      case 'confirmada':
        return 'blue';
      case 'en_sala':
        return 'purple';
      case 'atendida':
        return 'green';
      case 'cancelada':
        return 'red';
      case 'reprogramada':
        return 'grey';
      default:
        return 'grey';
    }
  }

  /// Texto del estado en español
  String get estadoTexto {
    switch (estado) {
      case 'reservada':
        return 'Reservada';
      case 'confirmada':
        return 'Confirmada';
      case 'en_sala':
        return 'En Sala';
      case 'atendida':
        return 'Atendida';
      case 'cancelada':
        return 'Cancelada';
      case 'reprogramada':
        return 'Reprogramada';
      default:
        return estado;
    }
  }

  /// Fecha formateada (ej: "15 Nov 2025 - 10:30")
  String get fechaFormateada {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    final mes = meses[fechaHora.month - 1];
    final hora = '${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}';
    return '${fechaHora.day} $mes ${fechaHora.year} - $hora';
  }

  /// Solo fecha (ej: "15 Nov 2025")
  String get soloFecha {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    final mes = meses[fechaHora.month - 1];
    return '${fechaHora.day} $mes ${fechaHora.year}';
  }

  /// Solo hora (ej: "10:30")
  String get soloHora {
    return '${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}';
  }

  /// Es una cita futura
  bool get esFutura => fechaHora.isAfter(DateTime.now());

  /// Se puede cancelar
  bool get sePuedeCancelar =>
      ['reservada', 'confirmada'].contains(estado) && esFutura;
}
