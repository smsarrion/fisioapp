import 'package:flutter/material.dart';
import 'package:fisioapp/config/supabase_config.dart';
import 'package:fisioapp/screens/auth/login_screen.dart';
import 'package:fisioapp/screens/home_screen.dart';
import 'package:fisioapp/screens/calendar_screen.dart';
import 'package:fisioapp/screens/citas_screen.dart';
import 'package:fisioapp/screens/cita_form_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FisioApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/citas': (context) => const CitasScreen(),
        '/cita-form': (context) => const CitaFormScreen(),
      },
    );
  }
}
