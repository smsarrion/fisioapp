import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fisioapp/config/supabase_config.dart';
import 'package:fisioapp/models/profesional.dart';

class ProfesionalService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Obtener todos los profesionales de una empresa
  Future<List<Profesional>> getProfesionalesByEmpresa(String empresaId) async {
    try {
      final response = await _supabase
          .from('profesionales')
          .select()
          .eq('empresa_id', empresaId)
          .order('apellido');

      return response.map((json) => Profesional.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener profesionales: ${e.toString()}');
    }
  }

  // Obtener un profesional por su ID
  Future<Profesional> getProfesionalById(String id) async {
    try {
      final response = await _supabase
          .from('profesionales')
          .select()
          .eq('id', id)
          .single();

      return Profesional.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener profesional: ${e.toString()}');
    }
  }

  // Crear un nuevo profesional
  Future<Profesional> createProfesional(Profesional profesional) async {
    try {
      final response = await _supabase
          .from('profesionales')
          .insert(profesional.toJson())
          .select()
          .single();

      return Profesional.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al crear profesional: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear profesional: ${e.toString()}');
    }
  }

  // Actualizar un profesional existente
  Future<Profesional> updateProfesional(Profesional profesional) async {
    try {
      final response = await _supabase
          .from('profesionales')
          .update(profesional.toJson())
          .eq('id', profesional.id)
          .select()
          .single();

      return Profesional.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar profesional: ${e.message}');
    } catch (e) {
      throw Exception(
        'Error inesperado al actualizar profesional: ${e.toString()}',
      );
    }
  }

  // Eliminar un profesional
  Future<void> deleteProfesional(String id) async {
    try {
      await _supabase.from('profesionales').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar profesional: ${e.message}');
    } catch (e) {
      throw Exception(
        'Error inesperado al eliminar profesional: ${e.toString()}',
      );
    }
  }

  // Buscar profesionales por nombre o apellido
  Future<List<Profesional>> searchProfesionales(
    String empresaId,
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('profesionales')
          .select()
          .eq('empresa_id', empresaId)
          .or('nombre.ilike.%$query%,apellido.ilike.%$query%')
          .order('apellido');

      return response.map((json) => Profesional.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar profesionales: ${e.toString()}');
    }
  }

  // Obtener profesionales por especialidad
  Future<List<Profesional>> getProfesionalesByEspecialidad(
    String empresaId,
    String especialidad,
  ) async {
    try {
      final response = await _supabase
          .from('profesionales')
          .select()
          .eq('empresa_id', empresaId)
          .ilike('especialidad', '%$especialidad%')
          .order('apellido');

      return response.map((json) => Profesional.fromJson(json)).toList();
    } catch (e) {
      throw Exception(
        'Error al obtener profesionales por especialidad: ${e.toString()}',
      );
    }
  }

  // Obtener todas las especialidades disponibles
  Future<List<String>> getEspecialidades(String empresaId) async {
    try {
      final response = await _supabase
          .from('profesionales')
          .select('especialidad')
          .eq('empresa_id', empresaId)
          .not('especialidad', 'is', null);

      // Extraer especialidades únicas
      final especialidadesSet = <String>{};
      for (var item in response) {
        if (item['especialidad'] != null && item['especialidad'].isNotEmpty) {
          especialidadesSet.add(item['especialidad']);
        }
      }

      return especialidadesSet.toList()..sort();
    } catch (e) {
      throw Exception('Error al obtener especialidades: ${e.toString()}');
    }
  }

  // Obtener profesionales con más citas
  Future<List<Map<String, dynamic>>> getProfesionalesMasSolicitados(
    String empresaId, {
    int limit = 5,
  }) async {
    try {
      final response = await _supabase
          .from('citas')
          .select('profesional_id, count')
          .eq('empresa_id', empresaId)
          .eq('estado', 'completada')
          .select('''
            profesional_id,
            count,
            profesionales!inner(
              id,
              nombre,
              apellido,
              especialidad
            )
          ''')
          .order('count', ascending: false)
          .limit(limit);

      // Procesar los resultados
      List<Map<String, dynamic>> resultados = [];

      for (var item in response) {
        final profesional = item['profesionales'];
        resultados.add({
          'id': profesional['id'],
          'nombre': profesional['nombre'],
          'apellido': profesional['apellido'],
          'especialidad': profesional['especialidad'],
          'citas': item['count'],
        });
      }

      return resultados;
    } catch (e) {
      throw Exception(
        'Error al obtener profesionales más solicitados: ${e.toString()}',
      );
    }
  }

  // Obtener estadísticas de profesionales
  Future<Map<String, dynamic>> getEstadisticasProfesionales(
    String empresaId,
  ) async {
    try {
      // Obtener el total de profesionales
      final totalProfesionalesResponse = await _supabase
          .from('profesionales')
          .select('id')
          .eq('empresa_id', empresaId);

      final totalProfesionales = totalProfesionalesResponse.length;

      // Obtener el número de especialidades
      final especialidadesResponse = await _supabase
          .from('profesionales')
          .select('especialidad')
          .eq('empresa_id', empresaId)
          .not('especialidad', 'is', null);

      final especialidadesSet = <String>{};
      for (var item in especialidadesResponse) {
        if (item['especialidad'] != null && item['especialidad'].isNotEmpty) {
          especialidadesSet.add(item['especialidad']);
        }
      }
      final totalEspecialidades = especialidadesSet.length;

      // Obtener el profesional con más citas
      final profesionalMasCitasResponse = await _supabase
          .from('citas')
          .select('profesional_id, count')
          .eq('empresa_id', empresaId)
          .eq('estado', 'completada')
          .select('''
            profesional_id,
            count,
            profesionales!inner(
              id,
              nombre,
              apellido
            )
          ''')
          .order('count', ascending: false)
          .limit(1)
          .single();

      // Obtener la distribución de citas por profesional
      final citasPorProfesionalResponse = await _supabase
          .from('citas')
          .select('profesional_id, count')
          .eq('empresa_id', empresaId)
          .eq('estado', 'completada')
          .select('''
            profesional_id,
            count,
            profesionales!inner(
              id,
              nombre,
              apellido
            )
          ''');

      List<Map<String, dynamic>> citasPorProfesional = [];
      for (var item in citasPorProfesionalResponse) {
        final profesional = item['profesionales'];
        citasPorProfesional.add({
          'id': profesional['id'],
          'nombre': profesional['nombre'],
          'apellido': profesional['apellido'],
          'citas': item['count'],
        });
      }

      return {
        'total_profesionales': totalProfesionales,
        'total_especialidades': totalEspecialidades,
        'profesional_mas_citas': profesionalMasCitasResponse,
        'citas_por_profesional': citasPorProfesional,
      };
    } catch (e) {
      throw Exception(
        'Error al obtener estadísticas de profesionales: ${e.toString()}',
      );
    }
  }

  // Obtener disponibilidad de un profesional en un rango de fechas
  Future<List<Map<String, dynamic>>> getDisponibilidadProfesional(
    String profesionalId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Obtener citas ya programadas para el profesional en el rango de fechas
      final citasResponse = await _supabase
          .from('citas')
          .select('fecha_hora_inicio, fecha_hora_fin')
          .eq('profesional_id', profesionalId)
          .gte('fecha_hora_inicio', startDate.toIso8601String())
          .lte('fecha_hora_inicio', endDate.toIso8601String())
          .order('fecha_hora_inicio');

      // Obtener horario laboral del profesional (esto podría estar en otra tabla)
      // Por ahora, asumimos un horario laboral de lunes a viernes de 9:00 a 18:00
      final horarioLaboral = {
        1: {'inicio': 9, 'fin': 18}, // Lunes
        2: {'inicio': 9, 'fin': 18}, // Martes
        3: {'inicio': 9, 'fin': 18}, // Miércoles
        4: {'inicio': 9, 'fin': 18}, // Jueves
        5: {'inicio': 9, 'fin': 18}, // Viernes
        6: {'inicio': 9, 'fin': 14}, // Sábado
        7: {'inicio': 0, 'fin': 0}, // Domingo (no trabaja)
      };

      // Generar disponibilidad
      List<Map<String, dynamic>> disponibilidad = [];
      DateTime currentDate = startDate;

      while (currentDate.isBefore(endDate) ||
          currentDate.isAtSameMomentAs(endDate)) {
        final diaSemana = currentDate.weekday;
        final horario = horarioLaboral[diaSemana];

        if (horario!['inicio'] != horario['fin']) {
          // El profesional trabaja este día
          final inicioDia = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            horario['inicio']!,
          );

          final finDia = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            horario['fin']!,
          );

          // Filtrar citas que coinciden con este día
          final citasDelDia = citasResponse.where((cita) {
            final citaInicio = DateTime.parse(cita['fecha_hora_inicio']);
            return citaInicio.year == currentDate.year &&
                citaInicio.month == currentDate.month &&
                citaInicio.day == currentDate.day;
          }).toList();

          // Ordenar citas por hora de inicio
          citasDelDia.sort((a, b) {
            final aInicio = DateTime.parse(a['fecha_hora_inicio']);
            final bInicio = DateTime.parse(b['fecha_hora_inicio']);
            return aInicio.compareTo(bInicio);
          });

          // Generar bloques de disponibilidad
          DateTime horaActual = inicioDia;
          List<Map<String, dynamic>> bloquesDisponibles = [];

          for (var cita in citasDelDia) {
            final citaInicio = DateTime.parse(cita['fecha_hora_inicio']);
            final citaFin = DateTime.parse(cita['fecha_hora_fin']);

            // Si hay tiempo disponible antes de la cita
            if (horaActual.isBefore(citaInicio)) {
              bloquesDisponibles.add({'inicio': horaActual, 'fin': citaInicio});
            }

            // Actualizar hora actual al final de la cita
            horaActual = citaFin;
          }

          // Si hay tiempo disponible después de la última cita
          if (horaActual.isBefore(finDia)) {
            bloquesDisponibles.add({'inicio': horaActual, 'fin': finDia});
          }

          disponibilidad.add({
            'fecha': currentDate,
            'bloques_disponibles': bloquesDisponibles,
          });
        }

        // Avanzar al siguiente día
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return disponibilidad;
    } catch (e) {
      throw Exception(
        'Error al obtener disponibilidad del profesional: ${e.toString()}',
      );
    }
  }
}
