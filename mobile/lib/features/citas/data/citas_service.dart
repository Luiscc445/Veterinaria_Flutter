import '../../../core/config/supabase_config.dart';
import '../../../shared/models/cita_model.dart';

/// Servicio para gestionar citas (Arquitectura MVC - Modelo)
/// Este servicio usa funciones SQL seguras para evitar errores de permisos
class CitasService {
  /// Obtener mis citas (tutor)
  /// Usa función SQL segura (get_my_citas) para evitar "permission denied"
  Future<Map<String, List<CitaModel>>> obtenerMisCitas({String? estado}) async {
    try {
      // Llamar función SQL segura que maneja RLS internamente
      final response = await supabase.rpc('get_my_citas');

      // Convertir a modelos
      final citas = (response as List)
          .map((json) {
            // Adaptar el formato de la función SQL a CitaModel
            return CitaModel.fromJson({
              'id': json['id'],
              'mascota_id': json['mascota_id'],
              'tutor_id': json['tutor_id'],
              'servicio_id': json['servicio_id'],
              'profesional_id': json['profesional_id'],
              'consultorio_id': json['consultorio_id'],
              'fecha_hora': json['fecha_hora'],
              'fecha_hora_fin': json['fecha_hora_fin'],
              'estado': json['estado'],
              'motivo_consulta': json['motivo_consulta'],
              'observaciones': json['observaciones'],
              'created_at': json['created_at'],
              'mascota': {
                'nombre': json['mascota_nombre'],
                'especie': json['mascota_especie'],
              },
              'servicio': {
                'nombre': json['servicio_nombre'],
              },
              'profesional': {
                'user': {
                  'nombre_completo': json['profesional_nombre'],
                }
              }
            });
          })
          .toList();

      // Filtrar por estado si se especificó
      final citasFiltradas = estado != null
          ? citas.where((c) => c.estado == estado).toList()
          : citas;

      // Separar en próximas y pasadas
      final ahora = DateTime.now();
      final proximas = citasFiltradas
          .where((c) =>
              c.fechaHora.isAfter(ahora) && c.estado != 'cancelada')
          .toList();
      final pasadas = citasFiltradas
          .where((c) =>
              c.fechaHora.isBefore(ahora) ||
              c.estado == 'cancelada' ||
              c.estado == 'atendida')
          .toList();

      return {
        'proximas': proximas,
        'pasadas': pasadas,
      };
    } catch (e) {
      throw Exception('Error al obtener citas: $e');
    }
  }

  /// Obtener una cita por ID
  Future<CitaModel> obtenerCitaPorId(String id) async {
    try {
      final response = await supabase
          .from('citas')
          .select('''
            *,
            mascota:mascotas(*),
            servicio:servicios(*),
            profesional:profesionales(
              *,
              user:users(nombre_completo, email, telefono)
            ),
            consultorio:consultorios(*)
          ''')
          .eq('id', id)
          .isFilter('deleted_at', null)
          .single();

      return CitaModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener cita: $e');
    }
  }

  /// Crear nueva cita
  /// Usa función SQL segura (create_cita) para evitar problemas de permisos
  Future<String> crearCita({
    required String mascotaId,
    required String servicioId,
    required String profesionalId,
    required DateTime fechaHora,
    String? motivoConsulta,
  }) async {
    try {
      // Llamar función SQL segura
      final citaId = await supabase.rpc('create_cita', params: {
        'p_mascota_id': mascotaId,
        'p_servicio_id': servicioId,
        'p_profesional_id': profesionalId,
        'p_fecha_hora': fechaHora.toIso8601String(),
        'p_motivo_consulta': motivoConsulta,
      });

      return citaId as String;
    } catch (e) {
      throw Exception('Error al crear cita: $e');
    }
  }

  /// Actualizar cita
  Future<CitaModel> actualizarCita(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await supabase
          .from('citas')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return CitaModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar cita: $e');
    }
  }

  /// Cancelar cita
  Future<CitaModel> cancelarCita(String id, String? motivoCancelacion) async {
    try {
      final response = await supabase
          .from('citas')
          .update({
            'estado': 'cancelada',
            'motivo_cancelacion': motivoCancelacion,
          })
          .eq('id', id)
          .select()
          .single();

      return CitaModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al cancelar cita: $e');
    }
  }

  /// Obtener horarios disponibles
  Future<List<Map<String, dynamic>>> obtenerDisponibilidad({
    required String profesionalId,
    required String fecha,
    required String servicioId,
  }) async {
    try {
      // Obtener duración del servicio
      final servicioResponse = await supabase
          .from('servicios')
          .select('duracion_minutos')
          .eq('id', servicioId)
          .single();

      final duracionMinutos = servicioResponse['duracion_minutos'] ?? 30;

      // Obtener citas ocupadas del profesional en esa fecha
      final fechaInicio = '${fecha}T00:00:00';
      final fechaFin = '${fecha}T23:59:59';

      final citasOcupadas = await supabase
          .from('citas')
          .select('fecha_hora, fecha_hora_fin')
          .eq('profesional_id', profesionalId)
          .not('estado', 'in', '(cancelada,reprogramada)')
          .gte('fecha_hora', fechaInicio)
          .lte('fecha_hora', fechaFin)
          .isFilter('deleted_at', null);

      // Generar horarios disponibles (9:00 a 18:00 cada 30 min)
      final horarios = <Map<String, dynamic>>[];
      const horaInicio = 9;
      const horaFin = 18;

      for (int hora = horaInicio; hora < horaFin; hora++) {
        for (int minuto = 0; minuto < 60; minuto += 30) {
          final horaStr =
              '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
          final fechaHora = '${fecha}T$horaStr:00';

          // Verificar si está ocupado
          final estaOcupado = (citasOcupadas as List).any((cita) {
            final inicio = DateTime.parse(cita['fecha_hora']);
            final fin = DateTime.parse(cita['fecha_hora_fin']);
            final actual = DateTime.parse(fechaHora);
            return actual.isAfter(inicio.subtract(const Duration(seconds: 1))) &&
                actual.isBefore(fin);
          });

          if (!estaOcupado) {
            horarios.add({
              'hora': horaStr,
              'fecha_hora': fechaHora,
              'disponible': true,
            });
          }
        }
      }

      return horarios;
    } catch (e) {
      throw Exception('Error al obtener disponibilidad: $e');
    }
  }

  /// Verificar si una mascota está aprobada
  Future<bool> verificarMascotaAprobada(String mascotaId) async {
    try {
      final response = await supabase
          .from('mascotas')
          .select('estado')
          .eq('id', mascotaId)
          .single();

      return response['estado'] == 'aprobado';
    } catch (e) {
      return false;
    }
  }
}
