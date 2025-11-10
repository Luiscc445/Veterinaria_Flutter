/// Configuración general de la aplicación
class AppConfig {
  // Información de la app
  static const String appName = 'RamboPet';
  static const String appVersion = '1.0.0';

  // Modo debug
  static const bool isDebug = true;

  // API Base URL (si usas el backend)
  static const String apiBaseUrl = 'http://localhost:3000/api';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Paginación
  static const int defaultPageSize = 20;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);

  // Validaciones
  static const int minPasswordLength = 6;
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB

  // Formatos de fecha
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Notificaciones
  static const String notificationChannelId = 'rambopet_channel';
  static const String notificationChannelName = 'RamboPet Notificaciones';
  static const String notificationChannelDescription =
      'Notificaciones de citas y recordatorios';
}
