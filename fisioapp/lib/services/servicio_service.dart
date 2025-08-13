import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fisioapp/config/supabase_config.dart';
import 'package:fisioapp/models/servicio.dart';

class ServicioService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Obtener todos los servicios de una empresa
  Future<List<Servicio>> getServiciosByEmpresa(String empresaId) async {
    try {
      final response = await _supabase
          .from('servicios')
          .select()
          .eq('empresa_id', empresaId)
          .order('nombre');

      return response.map((json) => Servicio.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener servicios: ${e.toString()}');
    }
  }

  // Obtener un servicio por su ID
  Future<Servicio> getServicioById(String id) async {
    try {
      final response = await _supabase
          .from('servicios')
          .select()
          .eq('id', id)
          .single();

      return Servicio.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener servicio: ${e.toString()}');
    }
  }

  // Crear un nuevo servicio
  Future<Servicio> createServicio(Servicio servicio) async {
    try {
      final response = await _supabase
          .from('servicios')
          .insert(servicio.toJson())
          .select()
          .single();

      return Servicio.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al crear servicio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear servicio: ${e.toString()}');
    }
  }

  // Actualizar un servicio existente
  Future<Servicio> updateServicio(Servicio servicio) async {
    try {
      final response = await _supabase
          .from('servicios')
          .update(servicio.toJson())
          .eq('id', servicio.id)
          .select()
          .single();

      return Servicio.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar servicio: ${e.message}');
    } catch (e) {
      throw Exception(
        'Error inesperado al actualizar servicio: ${e.toString()}',
      );
    }
  }

  // Eliminar un servicio
  Future<void> deleteServicio(String id) async {
    try {
      await _supabase.from('servicios').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar servicio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar servicio: ${e.toString()}');
    }
  }

  // Obtener servicios por nombre (para búsqueda)
  Future<List<Servicio>> searchServiciosByNombre(
    String empresaId,
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('servicios')
          .select()
          .eq('empresa_id', empresaId)
          .ilike('nombre', '%$query%')
          .order('nombre');

      return response.map((json) => Servicio.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar servicios: ${e.toString()}');
    }
  }

  // Obtener servicios más populares (basado en citas)
  Future<List<Map<String, dynamic>>> getServiciosPopulares(
    String empresaId,
  ) async {
    try {
      // Realizar una consulta que una las tablas citas y servicios
      final response = await _supabase
          .from('citas')
          .select('servicio_id, count')
          .eq('empresa_id', empresaId)
          .eq('estado', 'completada')
          .select('''
            servicio_id,
            count,
            servicios!inner(
              id,
              nombre,
              precio
            )
          ''')
          .order('count', ascending: false)
          .limit(5);

      // Procesar los resultados para obtener un formato más útil
      List<Map<String, dynamic>> resultados = [];

      for (var item in response) {
        final servicio = item['servicios'];
        resultados.add({
          'id': servicio['id'],
          'nombre': servicio['nombre'],
          'precio': servicio['precio'],
          'citas': item['count'],
        });
      }

      return resultados;
    } catch (e) {
      throw Exception('Error al obtener servicios populares: ${e.toString()}');
    }
  }

  // Obtener estadísticas de servicios
  Future<Map<String, dynamic>> getEstadisticasServicios(
    String empresaId,
  ) async {
    try {
      // Obtener el total de servicios
      final totalServiciosResponse = await _supabase
          .from('servicios')
          .select('id')
          .eq('empresa_id', empresaId);

      final totalServicios = totalServiciosResponse.length;

      // Obtener el precio promedio
      final precioPromedioResponse = await _supabase
          .from('servicios')
          .select('precio')
          .eq('empresa_id', empresaId);

      double precioPromedio = 0;
      if (precioPromedioResponse.isNotEmpty) {
        final suma = precioPromedioResponse.fold<double>(
          0,
          (sum, item) => sum + (item['precio'] as num).toDouble(),
        );
        precioPromedio = suma / precioPromedioResponse.length;
      }

      // Obtener el servicio más caro
      final servicioMasCaroResponse = await _supabase
          .from('servicios')
          .select('nombre, precio')
          .eq('empresa_id', empresaId)
          .order('precio', ascending: false)
          .limit(1)
          .single();

      // Obtener el servicio más económico
      final servicioMasEconomicoResponse = await _supabase
          .from('servicios')
          .select('nombre, precio')
          .eq('empresa_id', empresaId)
          .order('precio', ascending: true)
          .limit(1)
          .single();

      return {
        'total_servicios': totalServicios,
        'precio_promedio': precioPromedio,
        'servicio_mas_caro': servicioMasCaroResponse,
        'servicio_mas_economico': servicioMasEconomicoResponse,
      };
    } catch (e) {
      throw Exception(
        'Error al obtener estadísticas de servicios: ${e.toString()}',
      );
    }
  }
}
