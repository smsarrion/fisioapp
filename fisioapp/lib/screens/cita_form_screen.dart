import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fisioapp/models/cita.dart';
import 'package:fisioapp/services/cita_service.dart';
import 'package:fisioapp/services/paciente_service.dart';
import 'package:fisioapp/models/paciente.dart';
import 'package:fisioapp/services/profesional_service.dart';
import 'package:fisioapp/models/profesional.dart';
import 'package:fisioapp/services/servicio_service.dart';
import 'package:fisioapp/models/servicio.dart';
import 'package:fisioapp/services/auth_services.dart';
import 'package:fisioapp/models/usuario.dart';
import 'package:fisioapp/services/empresa_service.dart';

class CitaFormScreen extends StatefulWidget {
  const CitaFormScreen({Key? key}) : super(key: key);

  @override
  _CitaFormScreenState createState() => _CitaFormScreenState();
}

class _CitaFormScreenState extends State<CitaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CitaService _citaService = CitaService();
  final PacienteService _pacienteService = PacienteService();
  final ProfesionalService _profesionalService = ProfesionalService();
  final ServicioService _servicioService = ServicioService();
  final AuthService _authService = AuthService();
  final EmpresaService _empresaService = EmpresaService();

  DateTime _fechaHoraInicio = DateTime.now();
  DateTime _fechaHoraFin = DateTime.now().add(const Duration(hours: 1));
  String _estado = 'programada';
  String _notas = '';

  List<Paciente> _pacientes = [];
  List<Profesional> _profesionales = [];
  List<Servicio> _servicios = [];

  Paciente? _selectedPaciente;
  Profesional? _selectedProfesional;
  Servicio? _selectedServicio;

  bool _isLoading = true;
  bool _isEditing = false;
  Cita? _cita;
  Usuario? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkIfEditing();
    _loadData();
  }

  void _checkIfEditing() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      if (args is String) {
        _isEditing = true;
        _loadCita(args);
      } else if (args is DateTime) {
        _fechaHoraInicio = args;
        _fechaHoraFin = args.add(const Duration(hours: 1));
      }
    }
  }

  Future<void> _loadCita(String id) async {
    try {
      // Aquí deberías tener un método en CitaService para obtener una cita por ID
      // final cita = await _citaService.getCitaById(id);
      // setState(() {
      //   _cita = cita;
      //   _fechaHoraInicio = cita.fechaHoraInicio;
      //   _fechaHoraFin = cita.fechaHoraFin;
      //   _estado = cita.estado;
      //   _notas = cita.notas ?? '';
      // });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar cita: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
        });

        final pacientes = await _pacienteService.getPacientesByEmpresa(
          user.empresaId,
        );
        final profesionales = await _profesionalService
            .getProfesionalesByEmpresa(user.empresaId);
        final servicios = await _servicioService.getServiciosByEmpresa(
          user.empresaId,
        );

        setState(() {
          _pacientes = pacientes;
          _profesionales = profesionales;
          _servicios = servicios;

          if (pacientes.isNotEmpty) _selectedPaciente = pacientes.first;
          if (profesionales.isNotEmpty)
            _selectedProfesional = profesionales.first;
          if (servicios.isNotEmpty) _selectedServicio = servicios.first;

          _isLoading = false;
        });
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

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _fechaHoraInicio : _fechaHoraFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartTime ? _fechaHoraInicio : _fechaHoraFin,
        ),
      );

      if (time != null) {
        setState(() {
          final newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          if (isStartTime) {
            _fechaHoraInicio = newDateTime;
            // Si la hora de fin es anterior a la hora de inicio, ajustarla
            if (_fechaHoraFin.isBefore(_fechaHoraInicio)) {
              _fechaHoraFin = _fechaHoraInicio.add(const Duration(hours: 1));
            }
          } else {
            _fechaHoraFin = newDateTime;
            // Si la hora de fin es anterior a la hora de inicio, ajustarla
            if (_fechaHoraFin.isBefore(_fechaHoraInicio)) {
              _fechaHoraInicio = _fechaHoraFin.subtract(
                const Duration(hours: 1),
              );
            }
          }
        });
      }
    }
  }

  Future<void> _saveCita() async {
    if (_formKey.currentState!.validate() &&
        _selectedPaciente != null &&
        _selectedProfesional != null &&
        _selectedServicio != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final cita = Cita(
          id: _cita?.id ?? '',
          empresaId: _currentUser!.empresaId,
          pacienteId: _selectedPaciente!.id,
          profesionalId: _selectedProfesional!.id,
          servicioId: _selectedServicio!.id,
          fechaHoraInicio: _fechaHoraInicio,
          fechaHoraFin: _fechaHoraFin,
          estado: _estado,
          notas: _notas.isEmpty ? null : _notas,
          createdAt: _cita?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (_isEditing) {
          await _citaService.updateCita(cita);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita actualizada correctamente')),
          );
        } else {
          await _citaService.createCita(cita);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita creada correctamente')),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar cita: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar Cita' : 'Nueva Cita')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Fecha y hora de inicio
                      ListTile(
                        title: const Text('Fecha y hora de inicio'),
                        subtitle: Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(_fechaHoraInicio),
                        ),
                        trailing: const Icon(Icons.event),
                        onTap: () => _selectDateTime(context, true),
                      ),

                      // Fecha y hora de fin
                      ListTile(
                        title: const Text('Fecha y hora de fin'),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(_fechaHoraFin),
                        ),
                        trailing: const Icon(Icons.event),
                        onTap: () => _selectDateTime(context, false),
                      ),

                      const SizedBox(height: 16),

                      // Paciente
                      DropdownButtonFormField<Paciente>(
                        decoration: const InputDecoration(
                          labelText: 'Paciente',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedPaciente,
                        items: _pacientes.map((paciente) {
                          return DropdownMenuItem<Paciente>(
                            value: paciente,
                            child: Text(
                              '${paciente.nombre} ${paciente.apellido}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPaciente = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor selecciona un paciente';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Profesional
                      DropdownButtonFormField<Profesional>(
                        decoration: const InputDecoration(
                          labelText: 'Profesional',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedProfesional,
                        items: _profesionales.map((profesional) {
                          return DropdownMenuItem<Profesional>(
                            value: profesional,
                            child: Text(
                              '${profesional.nombre} ${profesional.apellido}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedProfesional = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor selecciona un profesional';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Servicio
                      DropdownButtonFormField<Servicio>(
                        decoration: const InputDecoration(
                          labelText: 'Servicio',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedServicio,
                        items: _servicios.map((servicio) {
                          return DropdownMenuItem<Servicio>(
                            value: servicio,
                            child: Text(servicio.nombre),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedServicio = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor selecciona un servicio';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Estado
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                        ),
                        value: _estado,
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'programada',
                            child: Text('Programada'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'confirmada',
                            child: Text('Confirmada'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'cancelada',
                            child: Text('Cancelada'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'completada',
                            child: Text('Completada'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _estado = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Notas
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Notas',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          setState(() {
                            _notas = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Botón guardar
                      ElevatedButton(
                        onPressed: _saveCita,
                        child: Text(_isEditing ? 'Actualizar' : 'Guardar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
