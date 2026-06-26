import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _modoCadastro = false;

  @override
  void initState() {
    super.initState();
    _verificarLoginSalvo();
  }

  Future<void> _verificarLoginSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final emailSalvo = prefs.getString('email_logado');

    if (emailSalvo != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _salvarLogin(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email_logado', email);
  }

  Future<void> _autenticar() async {
    final email = _emailController.text.trim().toLowerCase();
    final senha = _passwordController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _mostrarErro('Preencha e-mail e senha!');
      return;
    }

    try {
      if (_modoCadastro) {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: senha,
        );
      } else {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: senha,
        );
      }

      await _salvarLogin(email);

      await _firestore.collection('usuarios').doc(email).set({
        'email': email,
        'ultimoLogin': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
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

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFD32F2F),
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Color(0xFFD32F2F)),
            const SizedBox(height: 16),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
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
            TextButton(
              onPressed: () {
                setState(() {
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
