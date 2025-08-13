import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fisioapp/config/supabase_config.dart';
import 'package:fisioapp/models/cita.dart';

class CitaService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<List<Cita>> getCitasByEmpresa(String empresaId) async {
    final response = await _supabase
        .from('citas')
        .select()
        .eq('empresa_id', empresaId)
        .order('fecha_hora_inicio');

    return response.map((json) => Cita.fromJson(json)).toList();
  }

  Future<List<Cita>> getCitasByEmpresaAndDateRange(
    String empresaId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase
        .from('citas')
        .select()
        .eq('empresa_id', empresaId)
        .gte('fecha_hora_inicio', startDate.toIso8601String())
        .lte('fecha_hora_inicio', endDate.toIso8601String())
        .order('fecha_hora_inicio');

    return response.map((json) => Cita.fromJson(json)).toList();
  }

  Future<Cita> createCita(Cita cita) async {
    final response = await _supabase
        .from('citas')
        .insert(cita.toJson())
        .select()
        .single();

    return Cita.fromJson(response);
  }

  Future<Cita> updateCita(Cita cita) async {
    final response = await _supabase
        .from('citas')
        .update(cita.toJson())
        .eq('id', cita.id)
        .select()
        .single();

    return Cita.fromJson(response);
  }

  Future<void> deleteCita(String id) async {
    await _supabase.from('citas').delete().eq('id', id);
  }
}
