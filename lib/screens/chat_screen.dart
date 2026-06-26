import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String emailContato;
  final String nomeContato;

  const ChatScreen({
    super.key,
    required this.emailContato,
    required this.nomeContato,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  late final String _chatId;
  late final String _meuEmail;

  @override
  void initState() {
    super.initState();

    _meuEmail =
        (FirebaseAuth.instance.currentUser?.email ?? '').toLowerCase();
    final emailContatoLower = widget.emailContato.toLowerCase();

    final emails = [_meuEmail, emailContatoLower]..sort();
    _chatId = emails.join('___');

    _resetarNaoLidas();
  }

  Future<void> _resetarNaoLidas() async {
    final myDocId =
        '${_chatId}_${_meuEmail.replaceAll(RegExp(r'[@.]'), '_')}';
    await _firestore.collection('unread').doc(myDocId).set({
      'chatId': _chatId,
      'email': _meuEmail,
      'unreadCount': 0,
    }, SetOptions(merge: true));
  }

  Future<void> _enviarMensagem() async {
    final texto = _msgController.text.trim();
    if (texto.isEmpty) return;

    _msgController.clear();

    try {
      await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('mensagens')
          .add({
        'texto': texto,
        'timestamp': FieldValue.serverTimestamp(),
        'senderEmail': _meuEmail,
      });

      final recipEmail = widget.emailContato.toLowerCase();
      final recipDocId =
          '${_chatId}_${recipEmail.replaceAll(RegExp(r'[@.]'), '_')}';
      await _firestore.collection('unread').doc(recipDocId).set({
        'chatId': _chatId,
        'email': recipEmail,
        'unreadCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
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

  bool _ehMinhaMensagem(String senderEmail) {
    return senderEmail.toLowerCase() == _meuEmail;
  }

  String _nomeRemetente(String senderEmail) {
    if (_ehMinhaMensagem(senderEmail)) return 'Você';
    return widget.nomeContato;
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nomeContato.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
            Text(
              widget.emailContato,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_chatId)
                  .collection('mensagens')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD32F2F),
                    ),
                  );
                }

                final mensagens = snapshot.data!.docs;

                if (mensagens.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma mensagem ainda.\nEnvie a primeira!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final dados =
                        mensagens[index].data() as Map<String, dynamic>;
                    final senderEmail =
                        dados['senderEmail'] as String? ?? '';
                    final souEu = _ehMinhaMensagem(senderEmail);
                    final nome = _nomeRemetente(senderEmail);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: souEu
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: souEu
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF00BFA5),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Align(
                            alignment: souEu
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: souEu
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF1A3A2A),
                                borderRadius: BorderRadius.zero,
                              ),
                              child: Text(
                                dados['texto'] ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: souEu
                                      ? Colors.white
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1A1A1A),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _enviarMensagem(),
                    decoration: const InputDecoration(
                      hintText: 'DIGITE E APERTE ENTER...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
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
