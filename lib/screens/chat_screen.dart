import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String nomeContato;
  const ChatScreen({super.key, required this.nomeContato});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  void _enviar() async {
    if (_msgController.text.trim().isNotEmpty) {
      final textoParaEnviar = _msgController.text.trim();
      _msgController.clear(); // Limpa o campo imediatamente para dar fluidez

      await _firestore.collection('chats/${widget.nomeContato}/mensagens').add({
        'texto': textoParaEnviar,
        'timestamp': FieldValue.serverTimestamp(),
        'enviadoPorMim': true, 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Fundo quase preto
      appBar: AppBar(
        title: Text(widget.nomeContato.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1)),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: Color(0xFFD32F2F), height: 2),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('chats/${widget.nomeContato}/mensagens').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)));
                final mensagens = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final dados = mensagens[index].data() as Map<String, dynamic>;
                    final souEu = dados['enviadoPorMim'] ?? false;
                    return Align(
                      alignment: souEu ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: souEu ? const Color(0xFFD32F2F) : const Color(0xFF222222),
                          borderRadius: BorderRadius.zero, // Balões formais retos
                        ),
                        child: Text(
                          dados['texto'] ?? '', 
                          style: TextStyle(fontSize: 15, color: souEu ? Colors.white : Colors.white70)
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Barra de digitação formal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1A1A1A),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    // 🔑 MÁGICA DO ENTER: Envia ao pressionar Enter no teclado
                    onSubmitted: (_) => _enviar(), 
                    decoration: const InputDecoration(
                      hintText: "DIGITE A MENSAGEM E APERTE ENTER...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_and_archive, color: Color(0xFFD32F2F)), 
                  onPressed: _enviar
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}