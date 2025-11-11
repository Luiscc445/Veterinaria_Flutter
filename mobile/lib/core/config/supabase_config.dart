import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente de Supabase global
final supabase = Supabase.instance.client;

/// Helper para obtener el usuario actual
User? get currentUser => supabase.auth.currentUser;

/// Helper para verificar si hay sesión activa
bool get isAuthenticated => currentUser != null;

/// Helper para obtener el token de acceso
String? get accessToken => supabase.auth.currentSession?.accessToken;

/// Helper para obtener el ID del usuario
String? get currentUserId => currentUser?.id;

/// Cache para el tutor_id del usuario actual
String? _cachedTutorId;
String? _cachedUserId;

/// Helper para obtener el user_id del tutor actual (con caché)
Future<String> getCurrentUserId() async {
  if (!isAuthenticated) {
    throw Exception('Usuario no autenticado');
  }

  // Si el usuario cambió, limpiar caché
  if (_cachedUserId != currentUserId) {
    _cachedUserId = currentUserId;
    _cachedTutorId = null;
  }

  final response = await supabase
      .from('users')
      .select('id')
      .eq('auth_user_id', currentUserId!)
      .single();

  return response['id'] as String;
}

/// Helper para obtener el tutor_id del usuario actual (con caché)
Future<String> getCurrentTutorId() async {
  if (!isAuthenticated) {
    throw Exception('Usuario no autenticado');
  }

  // Usar caché si está disponible y el usuario no cambió
  if (_cachedTutorId != null && _cachedUserId == currentUserId) {
    return _cachedTutorId!;
  }

  // Si el usuario cambió, limpiar caché
  if (_cachedUserId != currentUserId) {
    _cachedUserId = currentUserId;
    _cachedTutorId = null;
  }

  // Obtener el user_id primero
  final userResponse = await supabase
      .from('users')
      .select('id')
      .eq('auth_user_id', currentUserId!)
      .single();

  final userId = userResponse['id'] as String;

  // Obtener el tutor_id
  final tutorResponse = await supabase
      .from('tutores')
      .select('id')
      .eq('user_id', userId)
      .single();

  _cachedTutorId = tutorResponse['id'] as String;
  return _cachedTutorId!;
}

/// Limpiar caché de tutor (útil al cerrar sesión)
void clearTutorCache() {
  _cachedTutorId = null;
  _cachedUserId = null;
}

/// Extensión para facilitar el uso de Supabase
extension SupabaseHelpers on SupabaseClient {
  /// Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  /// Cerrar sesión
  Future<void> signOutUser() async {
    clearTutorCache();
    await auth.signOut();
  }

  /// Obtener usuario actual con datos de la tabla users
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (!isAuthenticated) return null;

    final response = await from('users')
        .select()
        .eq('auth_user_id', currentUserId!)
        .maybeSingle();

    return response;
  }
}
