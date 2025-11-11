import '../../../core/config/supabase_config.dart';
import '../../../shared/models/cita_model.dart';

/// Servicio para gestionar citas
class CitasService {
  /// Obtener mis citas (tutor)
  Future<Map<String, List<CitaModel>>> obtenerMisCitas({String? estado}) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Obtener tutor_id
      final tutorResponse = await supabase
          .from('tutores')
          .select('id')
          .eq('user_id', userId)
          .single();

      final tutorId = tutorResponse['id'];

      // Construir query
      var query = supabase
          .from('citas')
          .select('''
            *,
            mascota:mascotas(id, nombre, especie, foto_url),
            servicio:servicios(id, nombre, tipo, duracion_minutos, precio_base),
            profesional:profesionales(
              id,
              user:users(nombre_completo),
              especialidades
            ),
            consultorio:consultorios(id, nombre, numero)
          ''')
          .eq('tutor_id', tutorId)
          .isFilter('deleted_at', null)
          .order('fecha_hora', ascending: false);

      if (estado != null) {
        query = query.eq('estado', estado);
      }

      final response = await query;

      // Convertir a modelos
      final citas = (response as List)
          .map((json) => CitaModel.fromJson(json))
          .toList();

      // Separar en próximas y pasadas
      final ahora = DateTime.now();
      final proximas = citas
          .where((c) =>
              c.fechaHora.isAfter(ahora) && c.estado != 'cancelada')
          .toList();
      final pasadas = citas
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
  Future<CitaModel> crearCita(Map<String, dynamic> data) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Obtener tutor_id
      final tutorResponse = await supabase
          .from('tutores')
          .select('id')
          .eq('user_id', userId)
          .single();

      final tutorId = tutorResponse['id'];

      // Agregar tutor_id
      data['tutor_id'] = tutorId;
      data['estado'] = 'reservada';

      final response = await supabase
          .from('citas')
          .insert(data)
          .select()
          .single();

      return CitaModel.fromJson(response);
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
