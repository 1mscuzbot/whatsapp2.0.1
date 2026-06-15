import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Whatsapp2App());
}

class Whatsapp2App extends StatelessWidget {
  const Whatsapp2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp 2.0.1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212), // Fundo escuro geral
        primaryColor: const Color(0xFFD32F2F), // Vermelho Principal
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          primary: const Color(0xFFD32F2F),
          background: const Color(0xFF121212),
        ),
        // Aplicando a fonte diferenciada/formal em todo o app
        fontFamily: 'Courier New', 
      ),
      home: const LoginScreen(),
    );
  }
}