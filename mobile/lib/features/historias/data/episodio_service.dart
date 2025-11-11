import '../../../core/config/supabase_config.dart';

/// Modelo simple para Episodio
class EpisodioModel {
  final String id;
  final String historiaClinicaId;
  final String? citaId;
  final String profesionalId;
  final DateTime fechaEpisodio;
  final String tipoEpisodio;
  final String motivoConsulta;
  final String? anamnesis;
  final String? examenFisico;
  final double? temperaturaCelsius;
  final int? frecuenciaCardiaca;
  final int? frecuenciaRespiratoria;
  final double? pesoKg;
  final String? diagnostico;
  final String? planTratamiento;
  final String? indicacionesTutor;
  final DateTime? proximaVisita;
  final String? observaciones;
  final String? profesionalNombre;

  EpisodioModel({
    required this.id,
    required this.historiaClinicaId,
    this.citaId,
    required this.profesionalId,
    required this.fechaEpisodio,
    required this.tipoEpisodio,
    required this.motivoConsulta,
    this.anamnesis,
    this.examenFisico,
    this.temperaturaCelsius,
    this.frecuenciaCardiaca,
    this.frecuenciaRespiratoria,
    this.pesoKg,
    this.diagnostico,
    this.planTratamiento,
    this.indicacionesTutor,
    this.proximaVisita,
    this.observaciones,
    this.profesionalNombre,
  });

  factory EpisodioModel.fromJson(Map<String, dynamic> json) {
    return EpisodioModel(
      id: json['id'] as String,
      historiaClinicaId: json['historia_clinica_id'] as String,
      citaId: json['cita_id'] as String?,
      profesionalId: json['profesional_id'] as String,
      fechaEpisodio: DateTime.parse(json['fecha_episodio'] as String),
      tipoEpisodio: json['tipo_episodio'] as String,
      motivoConsulta: json['motivo_consulta'] as String,
      anamnesis: json['anamnesis'] as String?,
      examenFisico: json['examen_fisico'] as String?,
      temperaturaCelsius: json['temperatura_celsius'] != null
          ? (json['temperatura_celsius'] as num).toDouble()
          : null,
      frecuenciaCardiaca: json['frecuencia_cardiaca'] as int?,
      frecuenciaRespiratoria: json['frecuencia_respiratoria'] as int?,
      pesoKg: json['peso_kg'] != null ? (json['peso_kg'] as num).toDouble() : null,
      diagnostico: json['diagnostico'] as String?,
      planTratamiento: json['plan_tratamiento'] as String?,
      indicacionesTutor: json['indicaciones_tutor'] as String?,
      proximaVisita: json['proxima_visita'] != null
          ? DateTime.parse(json['proxima_visita'] as String)
          : null,
      observaciones: json['observaciones'] as String?,
      profesionalNombre: json['profesional_nombre'] as String?,
    );
  }
}

/// Servicio para episodios (Arquitectura MVC)
/// Usa funciones SQL seguras para evitar errores de permisos
class EpisodioService {
  /// Obtener episodios de una historia clínica usando RPC
  Future<List<EpisodioModel>> obtenerEpisodiosPorHistoria(
    String historiaId,
  ) async {
    try {
      final response = await supabase.rpc('get_episodios_by_historia', params: {
        'p_historia_id': historiaId,
      });

      return (response as List)
          .map((json) => EpisodioModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener episodios: $e');
    }
  }

  /// Obtener último episodio de una mascota
  Future<EpisodioModel?> obtenerUltimoEpisodio(String mascotaId) async {
    try {
      // Primero obtener la historia clínica
      final historiaResponse = await supabase.rpc(
        'get_historia_clinica_by_mascota',
        params: {'p_mascota_id': mascotaId},
      );

      if (historiaResponse == null || (historiaResponse as List).isEmpty) {
        return null;
      }

      final historiaId = (historiaResponse as List).first['id'] as String;

      // Obtener episodios
      final episodios = await obtenerEpisodiosPorHistoria(historiaId);

      if (episodios.isEmpty) return null;

      // El primero ya viene ordenado por fecha DESC
      return episodios.first;
    } catch (e) {
      return null;
    }
  }
}
