import 'package:flutter/material.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contatos = [
      {"nome": "Professor da Disciplina", "msg": "Projeto homologado na versão 2.0.1.", "foto": "👨‍🏫"},
      {"nome": "Parceiro do Projeto", "msg": "O visual Red & Black ficou sinistro!", "foto": "🚀"},
      {"nome": "Diretoria de TI", "msg": "Reunião de deploy agendada.", "foto": "💼"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('WHATSAPP v2.0.1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: const Color(0xFF1A1A1A),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: Color(0xFFD32F2F), height: 2), // Linha vermelha estilizada abaixo do AppBar
        ),
      ),
      body: ListView.builder(
        itemCount: contatos.length,
        itemBuilder: (context, index) {
          final item = contatos[index];
          return Container(
            // A borda DEVE ficar dentro de um BoxDecoration no Container!
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF222222))),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF2A2A2A),
                child: Text(item["foto"]!, style: const TextStyle(fontSize: 20)),
              ),
              title: Text(item["nome"]!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text(item["msg"]!, style: const TextStyle(color: Colors.grey)),
              trailing: const Text("ONLINE", style: TextStyle(color: Color(0xFFD32F2F), fontSize: 10, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(nomeContato: item["nome"]!)));
              },
            ),
          );
        },
      ),
    );
  }
}