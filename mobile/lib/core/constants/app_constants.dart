/// Constantes de la aplicación
class AppConstants {
  // Colores principales de RamboPet
  static const int primaryColorValue = 0xFF2196F3; // Azul
  static const int secondaryColorValue = 0xFFFF9800; // Naranja
  static const int accentColorValue = 0xFF4CAF50; // Verde

  // Rutas de navegación
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String mascotasRoute = '/mascotas';
  static const String citasRoute = '/citas';
  static const String historialRoute = '/historial';
  static const String perfilRoute = '/perfil';
  static const String ajustesRoute = '/ajustes';

  // Roles de usuario
  static const String rolAdmin = 'admin';
  static const String rolMedico = 'medico';
  static const String rolRecepcion = 'recepcion';
  static const String rolTutor = 'tutor';

  // Estados de mascota
  static const String estadoPendiente = 'pendiente';
  static const String estadoAprobado = 'aprobado';
  static const String estadoRechazado = 'rechazado';

  // Estados de cita
  static const String citaReservada = 'reservada';
  static const String citaConfirmada = 'confirmada';
  static const String citaEnSala = 'en_sala';
  static const String citaAtendida = 'atendida';
  static const String citaReprogramada = 'reprogramada';
  static const String citaCancelada = 'cancelada';

  // Especies de mascotas
  static const List<String> especiesMascotas = [
    'Perro',
    'Gato',
    'Ave',
    'Conejo',
    'Roedor',
    'Reptil',
    'Otro',
  ];

  // Sexos
  static const String sexoMacho = 'macho';
  static const String sexoHembra = 'hembra';

  // Límites
  static const int maxImageSizeMB = 10;
  static const int maxFileSizeMB = 20;

  // Mensajes de error comunes
  static const String errorGenerico = 'Ocurrió un error inesperado';
  static const String errorConexion = 'Error de conexión. Verifica tu internet';
  static const String errorAutenticacion = 'Error de autenticación';
  static const String errorPermisos = 'No tienes permisos para esta acción';

  // Mensajes de éxito
  static const String exitoGuardado = 'Guardado exitosamente';
  static const String exitoActualizado = 'Actualizado exitosamente';
  static const String exitoEliminado = 'Eliminado exitosamente';

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // Duración de animaciones
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}

/// Textos de la aplicación (i18n básico)
class AppStrings {
  // General
  static const String appName = 'RamboPet';
  static const String aceptar = 'Aceptar';
  static const String cancelar = 'Cancelar';
  static const String guardar = 'Guardar';
  static const String eliminar = 'Eliminar';
  static const String editar = 'Editar';
  static const String buscar = 'Buscar';
  static const String filtrar = 'Filtrar';
  static const String cargar = 'Cargando...';

  // Autenticación
  static const String iniciarSesion = 'Iniciar Sesión';
  static const String registrarse = 'Registrarse';
  static const String cerrarSesion = 'Cerrar Sesión';
  static const String email = 'Correo electrónico';
  static const String contrasena = 'Contraseña';
  static const String olvidoContrasena = '¿Olvidaste tu contraseña?';
  static const String nombreCompleto = 'Nombre completo';
  static const String telefono = 'Teléfono';

  // Mascotas
  static const String misMascotas = 'Mis Mascotas';
  static const String registrarMascota = 'Registrar Mascota';
  static const String nombreMascota = 'Nombre';
  static const String especie = 'Especie';
  static const String raza = 'Raza';
  static const String sexo = 'Sexo';
  static const String fechaNacimiento = 'Fecha de nacimiento';
  static const String peso = 'Peso (kg)';
  static const String color = 'Color';
  static const String microchip = 'Microchip';

  // Citas
  static const String misCitas = 'Mis Citas';
  static const String agendarCita = 'Agendar Cita';
  static const String proximasCitas = 'Próximas Citas';
  static const String historialCitas = 'Historial de Citas';
  static const String seleccionarServicio = 'Seleccionar Servicio';
  static const String seleccionarMedico = 'Seleccionar Médico';
  static const String seleccionarFecha = 'Seleccionar Fecha y Hora';

  // Historial
  static const String historialMedico = 'Historial Médico';
  static const String consultas = 'Consultas';
  static const String vacunas = 'Vacunas';
  static const String cirugias = 'Cirugías';

  // Perfil
  static const String miPerfil = 'Mi Perfil';
  static const String editarPerfil = 'Editar Perfil';
  static const String cambiarContrasena = 'Cambiar Contraseña';
  static const String ajustes = 'Ajustes';
  static const String notificaciones = 'Notificaciones';
  static const String idioma = 'Idioma';
  static const String tema = 'Tema';
  static const String acercaDe = 'Acerca de';
}
