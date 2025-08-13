import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fisioapp/models/cita.dart';
import 'package:fisioapp/services/cita_service.dart';
import 'package:fisioapp/services/auth_service.dart';
import 'package:fisioapp/models/usuario.dart';
import 'package:fisioapp/models/empresa.dart';
import 'package:fisioapp/services/empresa_service.dart';
import 'package:fisioapp/services/servicio_service.dart';
import 'package:fisioapp/models/servicio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CitaService _citaService = CitaService();
  final AuthService _authService = AuthService();
  final EmpresaService _empresaService = EmpresaService();
  final ServicioService _servicioService = ServicioService();

  Usuario? _currentUser;
  Empresa? _currentEmpresa;
  bool _isLoading = true;

  // Datos para las tarjetas
  double _ingresosMes = 0;
  double _porcentajeIngresos = 0;
  int _totalCitas = 0;
  double _porcentajeCitas = 0;
  int _citasCompletadas = 0;
  double _porcentajeCompletadas = 0;

  // Datos para los gráficos
  List<double> _ingresosPorDia = [];
  List<Cita> _citasRecientes = [];
  Map<String, int> _citasPorServicio = {};
  Map<int, int> _citasPorDiaSemana = {};

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
          // Obtener citas del mes actual
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0);

          final citasMes = await _citaService.getCitasByEmpresaAndDateRange(
            user.empresaId,
            startOfMonth,
            endOfMonth,
          );

          // Obtener citas del mes anterior para comparación
          final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
          final endOfLastMonth = DateTime(now.year, now.month, 0);

          final citasMesAnterior = await _citaService
              .getCitasByEmpresaAndDateRange(
                user.empresaId,
                startOfLastMonth,
                endOfLastMonth,
              );

          // Obtener servicios
          final servicios = await _servicioService.getServiciosByEmpresa(
            user.empresaId,
          );

          // Calcular estadísticas
          double ingresosMesActual = 0;
          double ingresosMesAnterior = 0;
          int citasCompletadasMes = 0;
          int citasCompletadasMesAnterior = 0;

          // Calcular ingresos del mes actual
          for (var cita in citasMes) {
            if (cita.estado == 'completada') {
              final servicio = servicios.firstWhere(
                (s) => s.id == cita.servicioId,
                orElse: () => Servicio(
                  id: '',
                  empresaId: '',
                  nombre: '',
                  descripcion: '',
                  duracion: 0,
                  precio: 0,
                  color: '#000000',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
              ingresosMesActual += servicio.precio;
              citasCompletadasMes++;
            }
          }

          // Calcular ingresos del mes anterior
          for (var cita in citasMesAnterior) {
            if (cita.estado == 'completada') {
              final servicio = servicios.firstWhere(
                (s) => s.id == cita.servicioId,
                orElse: () => Servicio(
                  id: '',
                  empresaId: '',
                  nombre: '',
                  descripcion: '',
                  duracion: 0,
                  precio: 0,
                  color: '#000000',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
              ingresosMesAnterior += servicio.precio;
              citasCompletadasMesAnterior++;
            }
          }

          // Calcular porcentajes de cambio
          double porcentajeIngresos = 0;
          if (ingresosMesAnterior > 0) {
            porcentajeIngresos =
                ((ingresosMesActual - ingresosMesAnterior) /
                    ingresosMesAnterior) *
                100;
          }

          double porcentajeCitas = 0;
          if (citasMesAnterior.isNotEmpty) {
            porcentajeCitas =
                ((citasMes.length - citasMesAnterior.length) /
                    citasMesAnterior.length) *
                100;
          }

          double porcentajeCompletadas = 0;
          if (citasCompletadasMesAnterior > 0) {
            porcentajeCompletadas =
                ((citasCompletadasMes - citasCompletadasMesAnterior) /
                    citasCompletadasMesAnterior) *
                100;
          }

          // Calcular ingresos por día del mes actual
          List<double> ingresosPorDia = List.filled(
            DateTime(now.year, now.month + 1, 0).day,
            0,
          );
          for (var cita in citasMes) {
            if (cita.estado == 'completada') {
              final servicio = servicios.firstWhere(
                (s) => s.id == cita.servicioId,
                orElse: () => Servicio(
                  id: '',
                  empresaId: '',
                  nombre: '',
                  descripcion: '',
                  duracion: 0,
                  precio: 0,
                  color: '#000000',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
              final dia =
                  cita.fechaHoraInicio.day -
                  1; // Los días empiezan en 1, el índice en 0
              if (dia >= 0 && dia < ingresosPorDia.length) {
                ingresosPorDia[dia] += servicio.precio;
              }
            }
          }

          // Calcular citas por servicio
          Map<String, int> citasPorServicio = {};
          for (var servicio in servicios) {
            citasPorServicio[servicio.nombre] = 0;
          }

          for (var cita in citasMes) {
            final servicio = servicios.firstWhere(
              (s) => s.id == cita.servicioId,
              orElse: () => Servicio(
                id: '',
                empresaId: '',
                nombre: 'Otro',
                descripcion: '',
                duracion: 0,
                precio: 0,
                color: '#000000',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
            if (citasPorServicio.containsKey(servicio.nombre)) {
              citasPorServicio[servicio.nombre] =
                  (citasPorServicio[servicio.nombre] ?? 0) + 1;
            } else {
              citasPorServicio[servicio.nombre] = 1;
            }
          }

          // Calcular citas por día de la semana
          Map<int, int> citasPorDiaSemana = {
            1: 0, // Lunes
            2: 0, // Martes
            3: 0, // Miércoles
            4: 0, // Jueves
            5: 0, // Viernes
            6: 0, // Sábado
            7: 0, // Domingo
          };

          for (var cita in citasMes) {
            final diaSemana = cita.fechaHoraInicio.weekday;
            if (citasPorDiaSemana.containsKey(diaSemana)) {
              citasPorDiaSemana[diaSemana] =
                  (citasPorDiaSemana[diaSemana] ?? 0) + 1;
            }
          }

          // Obtener citas recientes (últimas 10)
          final citasRecientes = List<Cita>.from(citasMes);
          citasRecientes.sort(
            (a, b) => b.fechaHoraInicio.compareTo(a.fechaHoraInicio),
          );
          if (citasRecientes.length > 10) {
            citasRecientes.removeRange(10, citasRecientes.length);
          }

          setState(() {
            _currentUser = user;
            _currentEmpresa = empresa;
            _ingresosMes = ingresosMesActual;
            _porcentajeIngresos = porcentajeIngresos;
            _totalCitas = citasMes.length;
            _porcentajeCitas = porcentajeCitas;
            _citasCompletadas = citasCompletadasMes;
            _porcentajeCompletadas = porcentajeCompletadas;
            _ingresosPorDia = ingresosPorDia;
            _citasRecientes = citasRecientes;
            _citasPorServicio = citasPorServicio;
            _citasPorDiaSemana = citasPorDiaSemana;
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
        title: Text(_currentEmpresa?.nombre ?? 'FisioApp'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _authService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saludo
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Hola, ${_currentUser?.nombre ?? 'Usuario'}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Tarjetas de datos
                    Row(
                      children: [
                        Expanded(
                          child: _DataCard(
                            title: 'Ingresos del Mes',
                            value: _formatCurrency(_ingresosMes),
                            percentage: _porcentajeIngresos,
                            icon: Icons.euro,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DataCard(
                            title: 'Total de Citas',
                            value: _totalCitas.toString(),
                            percentage: _porcentajeCitas,
                            icon: Icons.event,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DataCard(
                            title: 'Citas Completadas',
                            value: _citasCompletadas.toString(),
                            percentage: _porcentajeCompletadas,
                            icon: Icons.check_circle,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child:
                              Container(), // Espacio vacío para mantener el diseño
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Gráficos
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gráfico de tendencia de ingresos
                        Expanded(
                          flex: 3,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tendencia de Ingresos',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total: ${_formatCurrency(_ingresosMes)}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                if (value.toInt() % 5 == 0) {
                                                  return Text(
                                                    '${value.toInt() + 1}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        minX: 0,
                                        maxX:
                                            _ingresosPorDia.length.toDouble() -
                                            1,
                                        minY: 0,
                                        maxY: _ingresosPorDia.isEmpty
                                            ? 100
                                            : _ingresosPorDia.reduce(
                                                    (a, b) => a > b ? a : b,
                                                  ) *
                                                  1.2,
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: _ingresosPorDia
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                                  return FlSpot(
                                                    entry.key.toDouble(),
                                                    entry.value,
                                                  );
                                                })
                                                .toList(),
                                            isCurved: true,
                                            color: Colors.green,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: Colors.green.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Gráficos circulares y de barras
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              // Gráfico circular de servicios
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Distribución de Servicios',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 150,
                                        child: PieChart(
                                          PieChartData(
                                            sections: _citasPorServicio.entries
                                                .map((entry) {
                                                  final value = entry.value
                                                      .toDouble();
                                                  final total =
                                                      _citasPorServicio.values
                                                          .fold(
                                                            0,
                                                            (sum, val) =>
                                                                sum + val,
                                                          )
                                                          .toDouble();
                                                  final percentage = total > 0
                                                      ? (value / total) * 100
                                                      : 0;

                                                  return PieChartSectionData(
                                                    value: value,
                                                    title:
                                                        '${percentage.toStringAsFixed(1)}%',
                                                    radius: 60,
                                                    titleStyle: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                    color: _getServiceColor(
                                                      entry.key,
                                                    ),
                                                  );
                                                })
                                                .toList(),
                                            centerSpaceRadius: 30,
                                            sectionsSpace: 2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: _citasPorServicio.entries.map((
                                          entry,
                                        ) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                color: _getServiceColor(
                                                  entry.key,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${entry.key}: ${entry.value}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Gráfico de barras por día de la semana
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Citas por Día de la Semana',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 150,
                                        child: BarChart(
                                          BarChartData(
                                            alignment:
                                                BarChartAlignment.spaceAround,
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              topTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget:
                                                      (value, meta) {
                                                        final days = [
                                                          'L',
                                                          'M',
                                                          'X',
                                                          'J',
                                                          'V',
                                                          'S',
                                                          'D',
                                                        ];
                                                        final index =
                                                            value.toInt() - 1;
                                                        if (index >= 0 &&
                                                            index <
                                                                days.length) {
                                                          return Text(
                                                            days[index],
                                                          );
                                                        }
                                                        return const Text('');
                                                      },
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: false,
                                            ),
                                            barGroups: _citasPorDiaSemana
                                                .entries
                                                .map((entry) {
                                                  return BarChartGroupData(
                                                    x: entry.key,
                                                    barRods: [
                                                      BarChartRodData(
                                                        toY: entry.value
                                                            .toDouble(),
                                                        color: Colors.blue,
                                                        width: 16,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                    ],
                                                  );
                                                })
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Tabla de citas recientes
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Citas Recientes',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Paciente')),
                                DataColumn(label: Text('Fecha')),
                                DataColumn(label: Text('Servicio')),
                                DataColumn(label: Text('Estado')),
                                DataColumn(label: Text('Precio')),
                              ],
                              rows: _citasRecientes.map((cita) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(cita.id.substring(0, 8))),
                                    DataCell(
                                      Text(_getPacienteName(cita.pacienteId)),
                                    ),
                                    DataCell(
                                      Text(
                                        DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(cita.fechaHoraInicio),
                                      ),
                                    ),
                                    DataCell(
                                      Text(_getServicioName(cita.servicioId)),
                                    ),
                                    DataCell(_buildStatusChip(cita.estado)),
                                    DataCell(
                                      Text(
                                        _formatCurrency(
                                          _getServicioPrice(cita.servicioId),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'es_ES', symbol: '€');
    return format.format(amount);
  }

  Color _getServiceColor(String serviceName) {
    // Asignar colores basados en el nombre del servicio
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    final index = serviceName.hashCode % colors.length;
    return colors[index.abs()];
  }

  String _getPacienteName(String pacienteId) {
    // En una implementación real, esto debería obtener el nombre del paciente desde el servicio
    return 'Paciente ${pacienteId.substring(0, 4)}';
  }

  String _getServicioName(String servicioId) {
    // En una implementación real, esto debería obtener el nombre del servicio desde el servicio
    return 'Servicio ${servicioId.substring(0, 4)}';
  }

  double _getServicioPrice(String servicioId) {
    // En una implementación real, esto debería obtener el precio del servicio desde el servicio
    return 50.0; // Valor por defecto
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'programada':
        color = Colors.blue;
        text = 'Programada';
        break;
      case 'confirmada':
        color = Colors.green;
        text = 'Confirmada';
        break;
      case 'cancelada':
        color = Colors.red;
        text = 'Cancelada';
        break;
      case 'completada':
        color = Colors.purple;
        text = 'Completada';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final String title;
  final String value;
  final double percentage;
  final IconData icon;
  final Color color;

  const _DataCard({
    required this.title,
    required this.value,
    required this.percentage,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  percentage >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: percentage >= 0 ? Colors.green : Colors.red,
                  size: 16,
                ),
                Text(
                  '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(1)}% desde el mes pasado',
                  style: TextStyle(
                    color: percentage >= 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
