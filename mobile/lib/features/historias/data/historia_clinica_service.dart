import '../../../core/config/supabase_config.dart';

/// Modelo simple para Historia Clínica
class HistoriaClinicaModel {
  final String id;
  final String mascotaId;
  final String numeroHistoria;
  final DateTime fechaApertura;
  final String? observacionesGenerales;
  final String? mascotaNombre;
  final String? mascotaEspecie;

  HistoriaClinicaModel({
    required this.id,
    required this.mascotaId,
    required this.numeroHistoria,
    required this.fechaApertura,
    this.observacionesGenerales,
    this.mascotaNombre,
    this.mascotaEspecie,
  });

  factory HistoriaClinicaModel.fromJson(Map<String, dynamic> json) {
    return HistoriaClinicaModel(
      id: json['id'] as String,
      mascotaId: json['mascota_id'] as String,
      numeroHistoria: json['numero_historia'] as String,
      fechaApertura: DateTime.parse(json['fecha_apertura'] as String),
      observacionesGenerales: json['observaciones_generales'] as String?,
      mascotaNombre: json['mascota_nombre'] as String?,
      mascotaEspecie: json['mascota_especie'] as String?,
    );
  }
}

/// Servicio para historias clínicas (Arquitectura MVC)
/// Usa funciones SQL seguras para evitar errores de permisos
class HistoriaClinicaService {
  /// Obtener historia clínica de una mascota usando RPC
  Future<HistoriaClinicaModel?> obtenerHistoriaPorMascota(
    String mascotaId,
  ) async {
    try {
      final response = await supabase.rpc('get_historia_clinica_by_mascota', params: {
        'p_mascota_id': mascotaId,
      });

      if (response == null || (response as List).isEmpty) {
        return null;
      }

      return HistoriaClinicaModel.fromJson((response as List).first);
    } catch (e) {
      throw Exception('Error al obtener historia clínica: $e');
    }
  }

  /// Verificar si una mascota tiene historia clínica
  Future<bool> tieneHistoriaClinica(String mascotaId) async {
    try {
      final historia = await obtenerHistoriaPorMascota(mascotaId);
      return historia != null;
    } catch (e) {
      return false;
    }
  }
}
