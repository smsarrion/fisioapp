import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fisioapp/config/supabase_config.dart';
import 'package:fisioapp/models/empresa.dart';

class EmpresaService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  Future<List<Empresa>> getAllEmpresas() async {
    final response = await _supabase.from('empresas').select().order('nombre');

    return response.map((json) => Empresa.fromJson(json)).toList();
  }

  Future<Empresa?> getEmpresaById(String id) async {
    final response = await _supabase
        .from('empresas')
        .select()
        .eq('id', id)
        .single();

    return response != null ? Empresa.fromJson(response) : null;
  }

  Future<Empresa> createEmpresa(Empresa empresa) async {
    final response = await _supabase
        .from('empresas')
        .insert(empresa.toJson())
        .select()
        .single();

    return Empresa.fromJson(response);
  }

  Future<Empresa> updateEmpresa(Empresa empresa) async {
    final response = await _supabase
        .from('empresas')
        .update(empresa.toJson())
        .eq('id', empresa.id)
        .select()
        .single();

    return Empresa.fromJson(response);
  }

  Future<void> deleteEmpresa(String id) async {
    await _supabase.from('empresas').delete().eq('id', id);
  }
}
