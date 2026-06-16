// =============================================================================
// ARQUIVO: home_screen.dart
// OBJETIVO: Tela principal que lista os contatos e exibe uma frase aleatória
//           vinda de uma API REST pública (requisito do PDF).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'code_showcase_screen.dart';
import '../services/quote_service.dart';

// -----------------------------------------------------------------------------
// PASSO 7: HomeScreen — tela com a lista de conversas
// -----------------------------------------------------------------------------
// StatelessWidget porque a lista é fixa (contatos pré-definidos).
// O estado da frase da API é gerenciado internamente na build (FutureBuilder).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ---------------------------------------------------------------------------
  // PASSO 7.1: _deslogar()
  // Limpa SharedPreferences e retorna à tela de login.
  // ---------------------------------------------------------------------------
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

  @override
  Widget build(BuildContext context) {
    // Lista de contatos simulados (dados hardcoded para demonstração)
    final contatos = [
      {
        'nome': 'Professor da Disciplina',
        'msg': 'Projeto homologado na versão 2.0.1.',
        'foto': '👨‍🏫',
      },
      {
        'nome': 'Parceiro do Projeto',
        'msg': 'O visual Red & Black ficou sinistro!',
        'foto': '🚀',
      },
      {
        'nome': 'Diretoria de TI',
        'msg': 'Reunião de deploy agendada.',
        'foto': '💼',
      },
    ];

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
        // Ações do AppBar: info (showcase) e logout
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
        // Linha vermelha estilizada abaixo do AppBar
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: Color(0xFFD32F2F), height: 2),
        ),
      ),
      body: Column(
        children: [
          // -------------------------------------------------------------------
          // PASSO 8: Consumo de API REST
          // Exibe uma frase aleatória vinda da API pública quotable.io
          // -------------------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1A1A1A),
            child: FutureBuilder<String>(
              // Chama o método que faz a requisição HTTP
              future: QuoteService.fetchRandomQuote(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Enquanto a API não responde, mostra um loading
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
                // Frase carregada com sucesso!
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

          // -------------------------------------------------------------------
          // PASSO 9: Lista de contatos (ListView.builder)
          // -------------------------------------------------------------------
          Expanded(
            child: ListView.builder(
              itemCount: contatos.length,
              itemBuilder: (context, index) {
                final item = contatos[index];
                return Container(
                  // Borda inferior sutil para separar os itens
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF222222)),
                    ),
                  ),
                  child: ListTile(
                    // Avatar com emoji
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2A2A2A),
                      child: Text(
                        item['foto']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    // Nome do contato
                    title: Text(
                      item['nome']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // Última mensagem
                    subtitle: Text(
                      item['msg']!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    // Status "ONLINE"
                    trailing: const Text(
                      'ONLINE',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Ao clicar, navega para a tela de chat
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            nomeContato: item['nome']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
