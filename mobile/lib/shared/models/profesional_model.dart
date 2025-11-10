/// Modelo de Profesional (Veterinario/Médico)
class ProfesionalModel {
  final String id;
  final String userId;
  final List<String>? especialidades;
  final String? licenciaProfesional;
  final int? anosExperiencia;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relación con user
  final Map<String, dynamic>? user;

  ProfesionalModel({
    required this.id,
    required this.userId,
    this.especialidades,
    this.licenciaProfesional,
    this.anosExperiencia,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  /// Crear desde JSON
  factory ProfesionalModel.fromJson(Map<String, dynamic> json) {
    return ProfesionalModel(
      id: json['id'],
      userId: json['user_id'],
      especialidades: json['especialidades'] != null
          ? List<String>.from(json['especialidades'])
          : null,
      licenciaProfesional: json['licencia_profesional'],
      anosExperiencia: json['anos_experiencia'],
      activo: json['activo'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      user: json['user'],
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'especialidades': especialidades,
      'licencia_profesional': licenciaProfesional,
      'anos_experiencia': anosExperiencia,
      'activo': activo,
    };
  }

  /// Copiar con cambios
  ProfesionalModel copyWith({
    String? id,
    String? userId,
    List<String>? especialidades,
    String? licenciaProfesional,
    int? anosExperiencia,
    bool? activo,
    Map<String, dynamic>? user,
  }) {
    return ProfesionalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      especialidades: especialidades ?? this.especialidades,
      licenciaProfesional: licenciaProfesional ?? this.licenciaProfesional,
      anosExperiencia: anosExperiencia ?? this.anosExperiencia,
      activo: activo ?? this.activo,
      user: user ?? this.user,
    );
  }

  // Helpers

  /// Nombre completo del profesional
  String get nombreCompleto {
    if (user != null && user!['nombre_completo'] != null) {
      return user!['nombre_completo'];
    }
    return 'Veterinario';
  }

  /// Email
  String? get email => user?['email'];

  /// Teléfono
  String? get telefono => user?['telefono'];

  /// Especialidades como texto
  String get especialidadesTexto {
    if (especialidades == null || especialidades!.isEmpty) {
      return 'Medicina General';
    }
    return especialidades!.join(', ');
  }

  /// Primera especialidad
  String get especialidadPrincipal {
    if (especialidades == null || especialidades!.isEmpty) {
      return 'Medicina General';
    }
    return especialidades!.first;
  }

  /// Años de experiencia formateados
  String get experienciaTexto {
    if (anosExperiencia == null) {
      return 'Experiencia no especificada';
    }
    if (anosExperiencia == 1) {
      return '1 año de experiencia';
    }
    return '$anosExperiencia años de experiencia';
  }

  /// Título profesional (Dr./Dra. + nombre)
  String get tituloProfesional {
    return 'Dr. $nombreCompleto';
  }
}
