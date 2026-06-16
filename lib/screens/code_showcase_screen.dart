// =============================================================================
// ARQUIVO: code_showcase_screen.dart
// OBJETIVO: Tela didática que explica o projeto, sua arquitetura e
//           exibe o código-fonte comentado para fins de apresentação.
// =============================================================================

import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// PASSO 1: Estruturas de dados para organizar as seções do showcase
// -----------------------------------------------------------------------------

/// Representa um bloco de código com título e linhas para exibição
class CodeSnippet {
  final String titulo;
  final String codigo;
  CodeSnippet(this.titulo, this.codigo);
}

/// Representa uma seção do showcase (ex.: Sobre, Arquitetura, Código)
class SecaoShowcase {
  final String titulo;
  final IconData icone;
  final Widget conteudo;
  SecaoShowcase(this.titulo, this.icone, this.conteudo);
}

// -----------------------------------------------------------------------------
// PASSO 2: CodeShowcaseScreen — tela principal de apresentação didática
// -----------------------------------------------------------------------------
class CodeShowcaseScreen extends StatelessWidget {
  const CodeShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cria todas as seções chamando métodos separados
    final secoes = [
      _secaoSobre(),
      _secaoTecnologias(),
      _secaoArquitetura(),
      _secaoFeatures(),
      _secaoCodeSnippets(),
      _secaoCreditos(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'PROJETO WHATSAPP 2.0.1',
          style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: Color(0xFFD32F2F), height: 2),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: secoes.length,
        itemBuilder: (context, index) {
          return _CardSecao(secao: secoes[index]);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEÇÃO 1: Sobre o Projeto
  // ---------------------------------------------------------------------------
  SecaoShowcase _secaoSobre() {
    return SecaoShowcase(
      'SOBRE O PROJETO',
      Icons.info_outline,
      _TextoFormatado(
        '''
WhatsApp 2.0.1 é um clone funcional do WhatsApp desenvolvido em Flutter como trabalho da disciplina Programação Mobile.

O app utiliza Firebase para autenticação e armazenamento em nuvem, SharedPreferences para persistência local, e consome uma API REST pública para exibir citações aleatórias.

Público-alvo: acadêmico — demonstrar integração de múltiplas tecnologias em um app mobile funcional.''',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEÇÃO 2: Tecnologias Utilizadas
  // ---------------------------------------------------------------------------
  SecaoShowcase _secaoTecnologias() {
    return SecaoShowcase(
      'TECNOLOGIAS',
      Icons.settings_applications,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _itemTecnologia(Icons.flutter_dash, 'Flutter', 'Framework cross-platform (Dart)'),
          _itemTecnologia(Icons.fireplace, 'Firebase Auth', 'Autenticação de usuários'),
          _itemTecnologia(Icons.cloud_queue, 'Cloud Firestore', 'Banco NoSQL em tempo real'),
          _itemTecnologia(Icons.storage, 'SharedPreferences', 'Armazenamento local de sessão'),
          _itemTecnologia(Icons.api, 'HTTP (quotable.io)', 'Consumo de API REST'),
        ],
      ),
    );
  }

  Widget _itemTecnologia(IconData icone, String nome, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icone, color: const Color(0xFFD32F2F), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEÇÃO 3: Arquitetura
  // ---------------------------------------------------------------------------
  SecaoShowcase _secaoArquitetura() {
    return SecaoShowcase(
      'ARQUITETURA',
      Icons.account_tree,
      _TextoFormatado(
        '''
A estrutura segue o padrão simples de camadas:

lib/
├── main.dart              ← Ponto de entrada
├── firebase_options.dart  ← Config Firebase
├── screens/               ← Telas do app
│   ├── login_screen.dart  ← Login/Cadastro
│   ├── home_screen.dart   ← Contatos + API
│   └── chat_screen.dart   ← Chat Firestore
└── services/              ← Serviços
    └── quote_service.dart ← API REST

Fluxo de navegação:
Login → Home (contatos) → Chat (conversa)''',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEÇÃO 4: Funcionalidades
  // ---------------------------------------------------------------------------
  SecaoShowcase _secaoFeatures() {
    return SecaoShowcase(
      'FUNCIONALIDADES',
      Icons.checklist,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _featureItem('Autenticação', 'Login e cadastro com Firebase Auth'),
          _featureItem('Sessão Persistente', 'SharedPreferences mantém login'),
          _featureItem('Lista de Contatos', 'Contatos simulados com status ONLINE'),
          _featureItem('API REST', 'Frase aleatória da API quotable.io'),
          _featureItem('Chat em Tempo Real', 'Mensagens sincronizadas via Firestore'),
          _featureItem('Tema Escuro', 'Visual Red & Black formal'),
        ],
      ),
    );
  }

  Widget _featureItem(String titulo, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFD32F2F), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEÇÃO 5: Código Comentado (snippets principais)
  // ---------------------------------------------------------------------------
  SecaoShowcase _secaoCodeSnippets() {
    // Lista de snippets de código para exibir
    final snippets = [
      CodeSnippet(
        'main.dart — inicialização',
        '''void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferences.getInstance();
  runApp(const Whatsapp2App());
}''',
      ),
      CodeSnippet(
        'login_screen.dart — autenticar',
        '''Future<void> _autenticar() async {
  // Se for cadastro, cria usuário
  // Se for login, autentica existente
  if (_modoCadastro) {
    await _auth.createUserWithEmailAndPassword(
      email: email, password: senha);
  } else {
    await _auth.signInWithEmailAndPassword(
      email: email, password: senha);
  }
  // Salva sessão e navega para Home
  await _salvarLogin(email);
}''',
      ),
      CodeSnippet(
        'home_screen.dart — API REST',
        '''// FutureBuilder consome API pública
FutureBuilder<String>(
  future: QuoteService.fetchRandomQuote(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting)
      return CircularProgressIndicator();
    // Exibe a frase carregada
    return Text(snapshot.data!);
  },
);''',
      ),
      CodeSnippet(
        'chat_screen.dart — Firestore',
        '''// Stream em tempo real do Firestore
StreamBuilder<QuerySnapshot>(
  stream: _firestore
    .collection('chats/\$contato/mensagens')
    .orderBy('timestamp', descending: true)
    .snapshots(),
  builder: (context, snapshot) {
    final mensagens = snapshot.data!.docs;
    // Constrói lista de balões de chat
    return ListView.builder(
      reverse: true,
      itemCount: mensagens.length,
      itemBuilder: (context, index) {
        final dados = mensagens[index].data() as Map;
        return Align(
          alignment: souEu
            ? Alignment.centerRight
            : Alignment.centerLeft,
          child: Container(/* balão */),
        );
      },
    );
  },
);''',
      ),
      CodeSnippet(
        'quote_service.dart — HTTP',
        '''static Future<String> fetchRandomQuote() async {
  try {
    final response = await http.get(
      Uri.parse('https://api.quotable.io/random'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return '\${data['content']}\\n\\n— \${data['author']}';
    }
  } catch (e) {
    return 'Frase indisponível (sem internet)';
  }
}''',
      ),
    ];

    return SecaoShowcase(
      'CÓDIGO COMENTADO',
      Icons.code,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: snippets.map((s) => _BlocoCodigo(s)).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEÇÃO 6: Créditos
  // ---------------------------------------------------------------------------
  SecaoShowcase _secaoCreditos() {
    return SecaoShowcase(
      'EQUIPE',
      Icons.people,
      Column(
        children: const [
          _MembroEquipe('👨‍💻', 'Davi Emannoel', 'Desenvolvedor'),
          _MembroEquipe('👨‍💻', 'João Thomaz', 'Desenvolvedor'),
          _MembroEquipe('👨‍💻', 'Klaus Siegfried', 'Desenvolvedor'),
          _MembroEquipe('👨‍💻', 'Lucas Müller', 'Desenvolvedor'),
          SizedBox(height: 16),
          Text(
            'Disciplina: Programação Mobile\nProva Prática 2.3',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPONENTES REUTILIZÁVEIS
// =============================================================================

/// Cartão que envolve cada seção com título, ícone e conteúdo
class _CardSecao extends StatelessWidget {
  final SecaoShowcase secao;
  const _CardSecao({required this.secao});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da seção com ícone
            Row(
              children: [
                Icon(secao.icone, color: const Color(0xFFD32F2F), size: 22),
                const SizedBox(width: 10),
                Text(
                  secao.titulo,
                  style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFF333333), height: 24),
            // Conteúdo da seção
            secao.conteudo,
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir texto formatado com fonte monoespaçada
class _TextoFormatado extends StatelessWidget {
  final String texto;
  const _TextoFormatado(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        height: 1.6,
      ),
    );
  }
}

/// Bloco de código com título e fonte monoespaçada
class _BlocoCodigo extends StatelessWidget {
  final CodeSnippet snippet;
  const _BlocoCodigo(this.snippet);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do arquivo/snippet
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFFD32F2F),
            child: Text(
              snippet.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          // Bloco de código
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            color: const Color(0xFF0A0A0A),
            child: SelectableText(
              snippet.codigo,
              style: const TextStyle(
                color: Color(0xFF8BC34A), // Verde terminal
                fontSize: 12,
                fontFamily: 'Courier New',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de membro da equipe
class _MembroEquipe extends StatelessWidget {
  final String emoji;
  final String nome;
  final String papel;
  const _MembroEquipe(this.emoji, this.nome, this.papel);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(papel, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
