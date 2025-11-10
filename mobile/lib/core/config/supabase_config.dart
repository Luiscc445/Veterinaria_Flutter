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

/// Extensión para facilitar el uso de Supabase
extension SupabaseHelpers on SupabaseClient {
  /// Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  /// Cerrar sesión
  Future<void> signOutUser() async {
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
