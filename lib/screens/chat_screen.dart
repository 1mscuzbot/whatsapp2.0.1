// =============================================================================
// ARQUIVO: chat_screen.dart
// OBJETIVO: Tela de chat individual. As mensagens são armazenadas e
//           sincronizadas em tempo real via Cloud Firestore (Firebase).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// -----------------------------------------------------------------------------
// PASSO 10: ChatScreen — tela de conversa com um contato
// -----------------------------------------------------------------------------
// StatefulWidget porque precisamos gerenciar TextEditingController e
// nos inscrever no Stream do Firestore em tempo real.
class ChatScreen extends StatefulWidget {
  // --- Parâmetro obrigatório: nome do contato com quem estamos falando ---
  final String nomeContato;

  const ChatScreen({super.key, required this.nomeContato});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Controlador do campo de digitação
  final _msgController = TextEditingController();

  // Instância do Cloud Firestore (banco de dados NoSQL do Firebase)
  final _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // PASSO 10.1: _enviarMensagem()
  // Envia uma mensagem para o Firestore na coleção do contato atual.
  // ---------------------------------------------------------------------------
  Future<void> _enviarMensagem() async {
    final texto = _msgController.text.trim();

    // Só envia se o texto não estiver vazio
    if (texto.isEmpty) return;

    // Limpa o campo imediatamente para dar sensação de fluidez
    _msgController.clear();

    try {
      // --- ESTRUTURA DOS DADOS NO FIRESTORE ---
      // Coleção: chats/{nomeContato}/mensagens
      // Cada documento tem:
      //   - texto: String
      //   - timestamp: Timestamp (data/hora do servidor)
      //   - enviadoPorMim: bool (true = eu enviei)
      await _firestore
          .collection('chats/${widget.nomeContato}/mensagens')
          .add({
        'texto': texto,
        // FieldValue.serverTimestamp() usa o relógio do servidor Firebase
        // para garantir ordenação correta, independente do fuso horário
        'timestamp': FieldValue.serverTimestamp(),
        'enviadoPorMim': true,
      });
    } catch (e) {
      // Em caso de erro (ex.: sem internet), exibe um SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFD32F2F),
            content: Text('Erro ao enviar: $e'),
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // PASSO 10.2: dispose() — libera recursos
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // PASSO 10.3: build() — constrói a interface do chat
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Fundo quase preto
      appBar: AppBar(
        // Título dinâmico: nome do contato em maiúsculas
        title: Text(
          widget.nomeContato.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: Color(0xFFD32F2F), height: 2),
        ),
      ),
      body: Column(
        children: [
          // -------------------------------------------------------------------
          // PASSO 11: StreamBuilder — lista de mensagens em tempo real
          // -------------------------------------------------------------------
          // O StreamBuilder se inscreve em um Stream do Firestore e
          // reconstrói a UI automaticamente quando novos dados chegam.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Stream: collectionReference.orderBy().snapshots()
              // Escuta em tempo real as mensagens ordenadas por timestamp
              stream: _firestore
                  .collection('chats/${widget.nomeContato}/mensagens')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Enquanto carrega, mostra um indicador de progresso
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD32F2F),
                    ),
                  );
                }

                final mensagens = snapshot.data!.docs;

                return ListView.builder(
                  // reverse: true faz a lista crescer de baixo para cima
                  // (as mensagens mais recentes ficam em cima)
                  reverse: true,
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    // Converte o documento do Firestore para Map
                    final dados =
                        mensagens[index].data() as Map<String, dynamic>;
                    final souEu = dados['enviadoPorMim'] ?? false;

                    // -------------------------------------------------------------------
                    // PASSO 11.1: Balão de mensagem
                    // Alinhado à direita se for minha mensagem, à esquerda se não.
                    // -------------------------------------------------------------------
                    return Align(
                      alignment: souEu
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          // Minhas mensagens: vermelho; outras: cinza escuro
                          color: souEu
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF222222),
                          // Bordas retas (estilo formal)
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Text(
                          dados['texto'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color: souEu ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // -------------------------------------------------------------------
          // PASSO 12: Barra de digitação
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1A1A1A),
            child: Row(
              children: [
                // Campo de texto expansível
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    // onSubmitted: envia ao pressionar Enter no teclado
                    onSubmitted: (_) => _enviarMensagem(),
                    decoration: const InputDecoration(
                      hintText: 'DIGITE E APERTE ENTER...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // Botão de envio (ícone de avião de papel estilizado)
                IconButton(
                  icon: const Icon(
                    Icons.send_and_archive,
                    color: Color(0xFFD32F2F),
                  ),
                  onPressed: _enviarMensagem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
