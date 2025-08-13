import 'package:flutter/material.dart';
import 'package:fisioapp/models/cita.dart';
import 'package:fisioapp/services/cita_service.dart';
import 'package:fisioapp/services/auth_services.dart';
import 'package:fisioapp/models/usuario.dart';
import 'package:fisioapp/models/empresa.dart';
import 'package:fisioapp/services/empresa_service.dart';
import 'package:intl/intl.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({Key? key}) : super(key: key);

  @override
  _CitasScreenState createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final CitaService _citaService = CitaService();
  final AuthService _authService = AuthService();
  final EmpresaService _empresaService = EmpresaService();

  List<Cita> _citas = [];
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
          final citas = await _citaService.getCitasByEmpresa(user.empresaId);

          setState(() {
            _currentUser = user;
            _currentEmpresa = empresa;
            _citas = citas;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Citas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _citas.isEmpty
          ? const Center(child: Text('No hay citas registradas'))
          : ListView.builder(
              itemCount: _citas.length,
              itemBuilder: (context, index) {
                final cita = _citas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(
                      '${DateFormat('dd/MM/yyyy').format(cita.fechaHoraInicio)} ${DateFormat.Hm().format(cita.fechaHoraInicio)}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estado: ${cita.estado}'),
                        if (cita.notas != null && cita.notas!.isNotEmpty)
                          Text('Notas: ${cita.notas}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/cita-form',
                              arguments: cita.id,
                            ).then((_) => _loadData());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(cita);
                          },
                        ),
                      ],
                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cita-form').then((_) => _loadData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Cita cita) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _citaService.deleteCita(cita.id);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cita eliminada correctamente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar cita: ${e.toString()}'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
