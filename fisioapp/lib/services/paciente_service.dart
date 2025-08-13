import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fisioapp/config/supabase_config.dart';
import 'package:fisioapp/models/paciente.dart';

class PacienteService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Obtener todos los pacientes de una empresa
  Future<List<Paciente>> getPacientesByEmpresa(String empresaId) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select()
          .eq('empresa_id', empresaId)
          .order('apellido');

      return response.map((json) => Paciente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener pacientes: ${e.toString()}');
    }
  }

  // Obtener un paciente por su ID
  Future<Paciente> getPacienteById(String id) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select()
          .eq('id', id)
          .single();

      return Paciente.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener paciente: ${e.toString()}');
    }
  }

  // Crear un nuevo paciente
  Future<Paciente> createPaciente(Paciente paciente) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .insert(paciente.toJson())
          .select()
          .single();

      return Paciente.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al crear paciente: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear paciente: ${e.toString()}');
    }
  }

  // Actualizar un paciente existente
  Future<Paciente> updatePaciente(Paciente paciente) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .update(paciente.toJson())
          .eq('id', paciente.id)
          .select()
          .single();

      return Paciente.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar paciente: ${e.message}');
    } catch (e) {
      throw Exception(
        'Error inesperado al actualizar paciente: ${e.toString()}',
      );
    }
  }

  // Eliminar un paciente
  Future<void> deletePaciente(String id) async {
    try {
      await _supabase.from('pacientes').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar paciente: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al eliminar paciente: ${e.toString()}');
    }
  }

  // Buscar pacientes por nombre, apellido o DNI
  Future<List<Paciente>> searchPacientes(String empresaId, String query) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select()
          .eq('empresa_id', empresaId)
          .or(
            'nombre.ilike.%$query%,apellido.ilike.%$query%,dni.ilike.%$query%',
          )
          .order('apellido');

      return response.map((json) => Paciente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar pacientes: ${e.toString()}');
    }
  }

  // Obtener pacientes que tienen citas programadas
  Future<List<Paciente>> getPacientesConCitas(String empresaId) async {
    try {
      final response = await _supabase
          .from('pacientes')
          .select('''
            *,
            citas!left(id)
          ''')
          .eq('empresa_id', empresaId)
          .not('citas.id', 'is', null)
          .order('apellido');

      // Eliminar duplicados (un paciente puede tener múltiples citas)
      final pacientesMap = <String, Paciente>{};
      for (var item in response) {
        final paciente = Paciente.fromJson(item);
        pacientesMap[paciente.id] = paciente;
      }

      return pacientesMap.values.toList();
    } catch (e) {
      throw Exception('Error al obtener pacientes con citas: ${e.toString()}');
    }
  }

  // Obtener pacientes sin citas recientes (por ejemplo, en los últimos 3 meses)
  Future<List<Paciente>> getPacientesSinCitasRecientes(
    String empresaId, {
    int meses = 3,
  }) async {
    try {
      final fechaLimite = DateTime.now().subtract(Duration(days: 30 * meses));

      final response = await _supabase
          .from('pacientes')
          .select('''
            *,
            citas!left(fecha_hora_inicio)
          ''')
          .eq('empresa_id', empresaId)
          .or(
            'citas.fecha_hora_inicio.is.null,citas.fecha_hora_inicio.lt.${fechaLimite.toIso8601String()}',
          )
          .order('apellido');

      // Eliminar duplicados
      final pacientesMap = <String, Paciente>{};
      for (var item in response) {
        final paciente = Paciente.fromJson(item);
        pacientesMap[paciente.id] = paciente;
      }

      return pacientesMap.values.toList();
    } catch (e) {
      throw Exception(
        'Error al obtener pacientes sin citas recientes: ${e.toString()}',
      );
    }
  }

  // Obtener pacientes por rango de edad
  Future<List<Paciente>> getPacientesPorRangoEdad(
    String empresaId,
    int edadMin,
    int edadMax,
  ) async {
    try {
      final fechaNacimientoMin = DateTime.now().subtract(
        Duration(days: 365 * (edadMax + 1)),
      );
      final fechaNacimientoMax = DateTime.now().subtract(
        Duration(days: 365 * edadMin),
      );

      final response = await _supabase
          .from('pacientes')
          .select()
          .eq('empresa_id', empresaId)
          .gte('fecha_nacimiento', fechaNacimientoMin.toIso8601String())
          .lte('fecha_nacimiento', fechaNacimientoMax.toIso8601String())
          .order('apellido');

      return response.map((json) => Paciente.fromJson(json)).toList();
    } catch (e) {
      throw Exception(
        'Error al obtener pacientes por rango de edad: ${e.toString()}',
      );
    }
  }

  // Obtener estadísticas de pacientes
  Future<Map<String, dynamic>> getEstadisticasPacientes(
    String empresaId,
  ) async {
    try {
      // Obtener el total de pacientes
      final totalPacientesResponse = await _supabase
          .from('pacientes')
          .select('id')
          .eq('empresa_id', empresaId);

      final totalPacientes = totalPacientesResponse.length;

      // Obtener distribución por edad
      final pacientesResponse = await _supabase
          .from('pacientes')
          .select('fecha_nacimiento')
          .eq('empresa_id', empresaId)
          .not('fecha_nacimiento', 'is', null);

      final gruposEdad = {
        '0-18': 0,
        '19-30': 0,
        '31-45': 0,
        '46-60': 0,
        '61+': 0,
      };

      final ahora = DateTime.now();
      for (var item in pacientesResponse) {
        if (item['fecha_nacimiento'] != null) {
          final fechaNacimiento = DateTime.parse(item['fecha_nacimiento']);
          final edad =
              ahora.year -
              fechaNacimiento.year -
              (ahora.month > fechaNacimiento.month ||
                      (ahora.month == fechaNacimiento.month &&
                          ahora.day >= fechaNacimiento.day)
                  ? 0
                  : 1);

          if (edad <= 18) {
            gruposEdad['0-18'] = (gruposEdad['0-18'] ?? 0) + 1;
          } else if (edad <= 30) {
            gruposEdad['19-30'] = (gruposEdad['19-30'] ?? 0) + 1;
          } else if (edad <= 45) {
            gruposEdad['31-45'] = (gruposEdad['31-45'] ?? 0) + 1;
          } else if (edad <= 60) {
            gruposEdad['46-60'] = (gruposEdad['46-60'] ?? 0) + 1;
          } else {
            gruposEdad['61+'] = (gruposEdad['61+'] ?? 0) + 1;
          }
        }
      }

      // Obtener pacientes nuevos (último mes)
      final fechaLimite = DateTime.now().subtract(const Duration(days: 30));
      final nuevosPacientesResponse = await _supabase
          .from('pacientes')
          .select('id')
          .eq('empresa_id', empresaId)
          .gte('created_at', fechaLimite.toIso8601String());

      final nuevosPacientes = nuevosPacientesResponse.length;

      return {
        'total_pacientes': totalPacientes,
        'nuevos_pacientes': nuevosPacientes,
        'distribucion_edad': gruposEdad,
      };
    } catch (e) {
      throw Exception(
        'Error al obtener estadísticas de pacientes: ${e.toString()}',
      );
    }
  }

  // Obtener historial de citas de un paciente
  Future<List<Map<String, dynamic>>> getHistorialCitasPaciente(
    String pacienteId,
  ) async {
    try {
      final response = await _supabase
          .from('citas')
          .select('''
            *,
            servicios!inner(nombre, precio),
            profesionales!inner(nombre, apellido)
          ''')
          .eq('paciente_id', pacienteId)
          .order('fecha_hora_inicio', ascending: false);

      return response
          .map(
            (item) => {
              'id': item['id'],
              'fecha_hora_inicio': DateTime.parse(item['fecha_hora_inicio']),
              'fecha_hora_fin': DateTime.parse(item['fecha_hora_fin']),
              'estado': item['estado'],
              'notas': item['notas'],
              'servicio': item['servicios']['nombre'],
              'precio': item['servicios']['precio'],
              'profesional':
                  '${item['profesionales']['nombre']} ${item['profesionales']['apellido']}',
            },
          )
          .toList();
    } catch (e) {
      throw Exception('Error al obtener historial de citas: ${e.toString()}');
    }
  }

  // Obtener pacientes con más citas
  Future<List<Map<String, dynamic>>> getPacientesMasFrecuentes(
    String empresaId, {
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('citas')
          .select('paciente_id, count')
          .eq('empresa_id', empresaId)
          .eq('estado', 'completada')
          .select('''
            paciente_id,
            count,
            pacientes!inner(
              id,
              nombre,
              apellido,
              fecha_nacimiento
            )
          ''')
          .order('count', ascending: false)
          .limit(limit);

      // Procesar los resultados
      List<Map<String, dynamic>> resultados = [];

      for (var item in response) {
        final paciente = item['pacientes'];
        resultados.add({
          'id': paciente['id'],
          'nombre': paciente['nombre'],
          'apellido': paciente['apellido'],
          'fecha_nacimiento': paciente['fecha_nacimiento'] != null
              ? DateTime.parse(paciente['fecha_nacimiento'])
              : null,
          'citas': item['count'],
        });
      }

      return resultados;
    } catch (e) {
      throw Exception(
        'Error al obtener pacientes más frecuentes: ${e.toString()}',
      );
    }
  }
}
