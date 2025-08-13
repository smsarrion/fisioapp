import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fisioapp/config/supabase_config.dart';
import 'package:fisioapp/models/usuario.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(
    String email,
    String password,
    String nombre,
    String apellido,
    String empresaId,
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await _supabase.from('usuarios').insert({
        'id': response.user!.id,
        'empresa_id': empresaId,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'rol': 'recepcionista',
      });
    }

    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<Usuario?> getCurrentUser() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('usuarios')
        .select()
        .eq('id', user.id)
        .single();

    return response != null ? Usuario.fromJson(response) : null;
  }
}
