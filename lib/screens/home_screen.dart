import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'code_showcase_screen.dart';
import '../services/quote_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _deslogar(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email_logado');

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  String _nomeAmigavel(String email) {
    return email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final meuEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WHATSAPP v2.0.1',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          IconButton(
            icon: const Icon(Icons.code, color: Color(0xFFD32F2F)),
            tooltip: 'Ver código do projeto',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CodeShowcaseScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
            tooltip: 'Sair',
            onPressed: () => _deslogar(context),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: Color(0xFFD32F2F), height: 2),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1A1A1A),
            child: FutureBuilder<String>(
              future: QuoteService.fetchRandomQuote(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Carregando frase do dia...',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text(
                    '★ Frase do dia indisponível ★',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  );
                }
                return Text(
                  snapshot.data!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.people, color: Color(0xFFD32F2F), size: 18),
                const SizedBox(width: 8),
                Text(
                  'CONTATOS DISPONÍVEIS',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD32F2F),
                    ),
                  );
                }

                final usuarios = snapshot.data!.docs.where((doc) {
                  final email = doc['email'] as String? ?? '';
                  return email != meuEmail;
                }).toList();

                if (usuarios.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum outro usuário cadastrado.\nCompartilhe o app com alguém!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final dados = usuarios[index].data()
                        as Map<String, dynamic>;
                    final email = dados['email'] as String? ?? '';
                    final nome = _nomeAmigavel(email);

                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF222222)),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF2A2A2A),
                          child: Text(
                            nome[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          email,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        trailing: const Text(
                          'ONLINE',
                          style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                emailContato: email,
                                nomeContato: nome,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
