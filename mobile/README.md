# 🐾 RamboPet Mobile

Aplicación móvil Flutter para el Sistema de Gestión Veterinaria RamboPet.

## 📱 Características

- Autenticación con Supabase Auth
- Gestión de mascotas propias
- Reserva y gestión de citas veterinarias
- Visualización de historial médico
- Notificaciones push de citas
- Tema claro/oscuro
- Arquitectura limpia (Clean Architecture)
- Gestión de estado con Riverpod
- Navegación con Go Router

## 🛠️ Tecnologías

- Flutter 3.16+
- Dart 3.2+
- Supabase Flutter
- Riverpod
- Go Router
- Flutter Form Builder

## 📦 Instalación

### Pre-requisitos

- Flutter SDK 3.16 o superior
- Dart SDK 3.2 o superior
- Android Studio / Xcode (para simuladores)
- Dispositivo físico o emulador Android/iOS

### Pasos de instalación

```bash
# 1. Clonar el repositorio
cd mobile

# 2. Instalar dependencias
flutter pub get

# 3. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de Supabase

# 4. Crear carpetas de assets
mkdir -p assets/images assets/icons

# 5. Verificar instalación de Flutter
flutter doctor

# 6. Ejecutar la aplicación
flutter run
```

## ⚙️ Configuración

### Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto mobile:

```env
SUPABASE_URL=https://dcahbgpeupxcqsybffhq.supabase.co
SUPABASE_ANON_KEY=tu_clave_anonima
```

### Android

Asegúrate de tener configurado el `minSdkVersion` en `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21 // o superior
        targetSdkVersion 33
    }
}
```

### iOS

Asegúrate de tener configurada la versión mínima en `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

## 🚀 Uso

### Ejecutar en desarrollo

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web (opcional)
flutter run -d chrome

# Ver dispositivos disponibles
flutter devices
```

### Build de producción

```bash
# Android APK
flutter build apk --release

# Android App Bundle (recomendado para Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📁 Estructura del Proyecto

```
lib/
├── core/                    # Configuración y utilidades
│   ├── config/
│   │   ├── app_config.dart         # Configuración general
│   │   ├── router_config.dart      # Rutas con Go Router
│   │   └── supabase_config.dart    # Cliente Supabase
│   ├── constants/
│   │   └── app_constants.dart      # Constantes
│   ├── theme/
│   │   └── app_theme.dart          # Temas claro/oscuro
│   └── utils/                      # Utilidades
│
├── features/               # Módulos por funcionalidad
│   ├── auth/              # Autenticación
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── splash_page.dart
│   │           ├── login_page.dart
│   │           └── register_page.dart
│   │
│   ├── mascotas/          # Gestión de mascotas
│   ├── citas/             # Sistema de citas
│   ├── historial/         # Historial médico
│   └── inventario/        # Inventario (para personal)
│
├── shared/                 # Componentes compartidos
│   ├── widgets/           # Widgets reutilizables
│   └── models/            # Modelos compartidos
│
└── main.dart              # Punto de entrada
```

## 🎨 Diseño y UX

### Tema

La aplicación usa un tema personalizado de RamboPet con:
- Color primario: Azul (#2196F3)
- Color secundario: Naranja (#FF9800)
- Color acento: Verde (#4CAF50)

### Tipografía

- Títulos: Poppins
- Cuerpo: Roboto

## 🔐 Autenticación

La autenticación se maneja con Supabase Auth:

```dart
// Iniciar sesión
await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Registrarse
await supabase.auth.signUp(
  email: email,
  password: password,
);

// Cerrar sesión
await supabase.auth.signOut();

// Verificar sesión
final user = supabase.auth.currentUser;
```

## 📱 Funcionalidades por Rol

### Tutor
- ✅ Registrar y gestionar mascotas
- ✅ Reservar citas
- ✅ Ver historial médico
- ✅ Recibir notificaciones de citas
- ✅ Actualizar perfil

### Médico (Próximamente)
- 📋 Ver agenda del día
- 📝 Registrar consultas
- 💊 Prescribir medicamentos
- 📊 Acceder a historiales clínicos

### Recepción (Próximamente)
- 📅 Gestionar agenda
- ✅ Aprobar mascotas
- 📍 Realizar check-in
- 🏥 Asignar consultorios

## 🧪 Testing

```bash
# Ejecutar tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ver reporte de coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🐛 Debugging

### Logs

Puedes ver los logs en tiempo real:

```bash
flutter logs
```

### DevTools

Abrir Flutter DevTools para debugging avanzado:

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## 📊 Performance

### Build Size

Reducir el tamaño de la app:

```bash
# Android
flutter build apk --split-per-abi

# Analizar el tamaño del bundle
flutter build appbundle --analyze-size
```

## 🔔 Notificaciones

Las notificaciones locales están configuradas con `flutter_local_notifications`.

Para notificaciones push, se puede integrar Firebase Messaging (opcional).

## 🌍 Internacionalización

La app está configurada para español argentino (`es_AR`).

Para agregar más idiomas, usar el paquete `intl`:

```dart
import 'package:intl/intl.dart';

// Formatear fechas
final formatter = DateFormat('dd/MM/yyyy', 'es_AR');
formatter.format(DateTime.now());
```

## ⚠️ Errores Comunes

### Error: "Supabase not initialized"
- Verifica que el archivo `.env` exista y tenga las credenciales correctas
- Asegúrate de ejecutar `flutter pub get`

### Error: "Build failed for Android"
- Limpia el proyecto: `flutter clean`
- Verifica el `minSdkVersion` en `android/app/build.gradle`

### Error: "CocoaPods not installed" (iOS)
- Instala CocoaPods: `sudo gem install cocoapods`
- Ejecuta: `cd ios && pod install`

## 📚 Recursos

### Flutter
- [Documentación oficial](https://flutter.dev/docs)
- [Widget catalog](https://flutter.dev/docs/development/ui/widgets)

### Supabase
- [Supabase Flutter docs](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Auth docs](https://supabase.com/docs/guides/auth)

### Riverpod
- [Riverpod docs](https://riverpod.dev)
- [Ejemplos](https://github.com/rrousselGit/riverpod/tree/master/examples)

### Go Router
- [Go Router docs](https://pub.dev/packages/go_router)

## 🤝 Contribución

Este es un proyecto privado para RamboPet.

## 📄 Licencia

Propietario - RamboPet © 2025

## 👨‍💻 Desarrollador

Desarrollado con ❤️ para RamboPet Veterinaria

---

**Versión**: 1.0.0
**Flutter**: 3.16+
**Dart**: 3.2+
