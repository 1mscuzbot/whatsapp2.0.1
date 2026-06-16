// =============================================================================
// ARQUIVO: main.dart
// OBJETIVO: Ponto de entrada do app. Inicializa Firebase, SharedPreferences
//           e renderiza a tela de login.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

// -----------------------------------------------------------------------------
// PASSO 1: Função main() — tudo começa aqui.
// -----------------------------------------------------------------------------
// O Flutter exige que chamemos WidgetsFlutterBinding.ensureInitialized()
// antes de qualquer operação assíncrona no main(), como Firebase.initializeApp().
void main() async {
  // Garante que o binding do Flutter está pronto antes de rodar código nativo
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções específicas da plataforma
  // (Android, iOS, Web, etc.) — veja firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa o armazenamento local (SharedPreferences) antes do app rodar
  // Serve para persistir dados como e-mail do usuário logado
  await SharedPreferences.getInstance();

  // Sobe o app
  runApp(const Whatsapp2App());
}

// -----------------------------------------------------------------------------
// PASSO 2: Classe raiz do app — Whatsapp2App
// -----------------------------------------------------------------------------
// StatelessWidget porque a configuração do tema não muda após a construção.
class Whatsapp2App extends StatelessWidget {
  const Whatsapp2App({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp é o widget raiz que configura navegação, tema, etc.
    return MaterialApp(
      // Título usado pelo sistema (ex.: recents app switcher)
      title: 'WhatsApp 2.0.1',

      // Remove o banner de debug no canto superior direito
      debugShowCheckedModeBanner: false,

      // Tema escuro (Dark Theme) — estilo "Red & Black" formal
      theme: ThemeData(
        // Fundo escuro geral do scaffold
        scaffoldBackgroundColor: const Color(0xFF121212),

        // Vermelho como cor principal (destaques, AppBar, etc.)
        primaryColor: const Color(0xFFD32F2F),

        // Gera um ColorScheme completo a partir da cor vermelha
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          primary: const Color(0xFFD32F2F),
          // Em versões recentes do Flutter, "background" foi depreciado;
          // usamos "surface" e "onSurface" para o fundo
          surface: const Color(0xFF121212),
          onSurface: Colors.white,
        ),

        // Fonte monoespaçada para dar um visual mais formal/tech
        fontFamily: 'Courier New',
      ),

      // Tela inicial: LoginScreen (veja screens/login_screen.dart)
      home: const LoginScreen(),
    );
  }
}
