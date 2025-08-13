import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fisioapp/config/supabase_config.dart';
import 'package:fisioapp/models/cita.dart';
import 'package:fisioapp/services/cita_service.dart';
import 'package:fisioapp/services/auth_service.dart';
import 'package:fisioapp/models/usuario.dart';
import 'package:fisioapp/models/empresa.dart';
import 'package:fisioapp/services/empresa_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CitaService _citaService = CitaService();
  final AuthService _authService = AuthService();
  final EmpresaService _empresaService = EmpresaService();

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Cita>> _citasByDay = {};
  List<Cita> _selectedDayCitas = [];

  Usuario? _currentUser;
  Empresa? _currentEmpresa;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final empresa = await _empresaService.getEmpresaById(user.empresaId);
        if (empresa != null) {
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0);

          final citas = await _citaService.getCitasByEmpresaAndDateRange(
            user.empresaId,
            startOfMonth,
            endOfMonth,
          );

          final Map<DateTime, List<Cita>> citasByDay = {};
          for (var cita in citas) {
            final day = DateTime(
              cita.fechaHoraInicio.year,
              cita.fechaHoraInicio.month,
              cita.fechaHoraInicio.day,
            );

            if (!citasByDay.containsKey(day)) {
              citasByDay[day] = [];
            }
            citasByDay[day]!.add(cita);
          }

          setState(() {
            _currentUser = user;
            _currentEmpresa = empresa;
            _citasByDay = citasByDay;
            _selectedDay = _focusedDay;
            _selectedDayCitas = _getCitasForDay(_focusedDay);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    }
  }

  List<Cita> _getCitasForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _citasByDay[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedDayCitas = _getCitasForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Citas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<Cita>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getCitasForDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: const CalendarStyle(
                    markersMaxCount: 4,
                    markerDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: _selectedDayCitas.isEmpty
                      ? const Center(
                          child: Text('No hay citas programadas para este día'),
                        )
                      : ListView.builder(
                          itemCount: _selectedDayCitas.length,
                          itemBuilder: (context, index) {
                            final cita = _selectedDayCitas[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.event),
                                title: Text(
                                  '${DateFormat.Hm().format(cita.fechaHoraInicio)} - ${DateFormat.Hm().format(cita.fechaHoraFin)}',
                                ),
                                subtitle: Text('Estado: ${cita.estado}'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/cita-detail',
                                    arguments: cita.id,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cita-form', arguments: _selectedDay);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
