// =============================================================================
// ARQUIVO: login_screen.dart
// OBJETIVO: Tela de login com Firebase Authentication + persistência local
//           via SharedPreferences. Também oferece opção de cadastro.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

// -----------------------------------------------------------------------------
// PASSO 4: LoginScreen — StatefulWidget porque precisamos gerenciar
//           estado dos TextFields e da autenticação.
// -----------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores dos campos de texto — vinculados aos TextField
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instância do Firebase Auth (singleton)
  final _auth = FirebaseAuth.instance;

  // Flag para alternar entre modo LOGIN e CADASTRO
  bool _modoCadastro = false;

  // ---------------------------------------------------------------------------
  // PASSO 4.1: initState() — executado quando a tela é montada.
  // Verifica se o usuário já estava logado (persistência local).
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _verificarLoginSalvo();
  }

  // ---------------------------------------------------------------------------
  // PASSO 4.2: _verificarLoginSalvo()
  // Lê o SharedPreferences para ver se há um e-mail salvo da última sessão.
  // Se sim, redireciona direto para a HomeScreen (login automático).
  // ---------------------------------------------------------------------------
  Future<void> _verificarLoginSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final emailSalvo = prefs.getString('email_logado');

    if (emailSalvo != null && mounted) {
      // Usuário já estava logado → vai direto para Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // PASSO 4.3: _salvarLogin()
  // Salva o e-mail no SharedPreferences para login automático futuro.
  // ---------------------------------------------------------------------------
  Future<void> _salvarLogin(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email_logado', email);
  }

  // ---------------------------------------------------------------------------
  // PASSO 4.4: _autenticar()
  // Faz login OU cadastro com Firebase Auth, dependendo do modo atual.
  // ---------------------------------------------------------------------------
  Future<void> _autenticar() async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();

    // Validação simples: campos não podem estar vazios
    if (email.isEmpty || senha.isEmpty) {
      _mostrarErro('Preencha e-mail e senha!');
      return;
    }

    try {
      if (_modoCadastro) {
        // --- MODO CADASTRO ---
        // Cria um novo usuário no Firebase Authentication
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: senha,
        );
      } else {
        // --- MODO LOGIN ---
        // Autentica um usuário existente
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: senha,
        );
      }

      // PASSO 4.5: Se chegou aqui, deu certo!
      // Salva o e-mail localmente e navega para Home
      await _salvarLogin(email);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Tratamento específico para erros do Firebase Auth
      // (ex.: e-mail já cadastrado, senha fraca, usuário inexistente)
      String mensagem;
      switch (e.code) {
        case 'email-already-in-use':
          mensagem = 'Este e-mail já está cadastrado.';
          break;
        case 'weak-password':
          mensagem = 'Senha muito fraca (mín. 6 caracteres).';
          break;
        case 'user-not-found':
          mensagem = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          mensagem = 'Senha incorreta.';
          break;
        case 'invalid-credential':
          mensagem = 'E-mail ou senha inválidos.';
          break;
        default:
          mensagem = 'Erro: ${e.message}';
      }
      _mostrarErro(mensagem);
    } catch (e) {
      _mostrarErro('Erro inesperado: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // PASSO 4.6: _mostrarErro()
  // Exibe um SnackBar vermelho com a mensagem de erro.
  // ---------------------------------------------------------------------------
  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFD32F2F),
        content: Text(msg),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PASSO 5: build() — constrói a interface da tela de login
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo escuro (já configurado no tema, mas vamos reforçar)
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de segurança (marca visual do app)
            const Icon(Icons.security, size: 80, color: Color(0xFFD32F2F)),
            const SizedBox(height: 16),

            // Título do app
            const Text(
              'WHATSAPP 2.0.1',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),

            // Campo de e-mail
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'E-MAIL',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD32F2F)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de senha (obscureText esconde os caracteres)
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'SENHA',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD32F2F)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botão principal: ENTRAR / CADASTRAR
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Botão reto (formal)
                ),
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: _autenticar,
              child: Text(
                _modoCadastro ? 'CADASTRAR' : 'CONECTAR',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TextButton para alternar entre login e cadastro
            TextButton(
              onPressed: () {
                setState(() {
                  // Inverte o modo
                  _modoCadastro = !_modoCadastro;
                });
              },
              child: Text(
                _modoCadastro
                    ? 'JÁ TEM CONTA? FAÇA LOGIN'
                    : 'NOVO? CRIE SUA CONTA',
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PASSO 6: dispose() — libera recursos ao sair da tela
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    // Sempre descarte os controladores para evitar vazamento de memória
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
