import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Importamos la pantalla de login que acabamos de crear`

void main() {
  runApp(const VeterinariaWebApp());
}

class VeterinariaWebApp extends StatelessWidget {
  const VeterinariaWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetCare Pro',
      debugShowCheckedModeBanner: false, // Oculta la etiqueta de debug
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        primaryColor: const Color(0xFF00C896),
      ),
      // Definimos la pantalla de login como la principal al abrir la web
      home: const LoginScreen(),
    );
  }
}