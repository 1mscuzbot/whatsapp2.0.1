# WhatsApp 2.0.1

**Equipe:** Davi Emannoel, João Thomaz, Klaus Siegfried, Lucas Müller

Aplicativo mobile de chat inspirado no WhatsApp, desenvolvido em **Flutter** com integração **Firebase**. Projeto da disciplina **Programação Mobile** — Prova Prática 2.3.

---

## Funcionalidades

### 1. Autenticação (Firebase Auth)
- **Login** com e-mail e senha
- **Cadastro** de novos usuários
- **Persistência de sessão** via SharedPreferences — o usuário não precisa logar toda vez que abre o app
- **Logout** pelo botão na tela principal

### 2. Lista de Contatos (Home Screen)
- Exibição de contatos simulados com avatar (emoji), nome e última mensagem
- Status **ONLINE** ao lado de cada contato
- Layout escuro no estilo **Red & Black**

### 3. Frase do Dia (API REST)
- Consumo da API pública [dummyjson.com](https://dummyjson.com/docs/quotes)
- Toda vez que a Home Screen é carregada, uma frase aleatória é buscada via HTTP
- Enquanto carrega, exibe um indicador de progresso
- Se a requisição falhar (sem internet), exibe mensagem amigável

### 4. Chat em Tempo Real (Firebase Firestore)
- Conversa individual com cada contato
- Mensagens armazenadas e sincronizadas em tempo real via **Cloud Firestore**
- Balões de mensagem alinhados:
  - **Vermelho (direita):** mensagens enviadas pelo usuário
  - **Cinza (esquerda):** mensagens recebidas
- Envio pelo botão de envio ou pressionando **Enter** no teclado
- Campo de texto com placeholder "DIGITE E APERTE ENTER..."

---

## Arquitetura do Projeto

```
lib/
├── main.dart                  # Ponto de entrada, inicialização do Firebase
├── firebase_options.dart      # Configuração automática do Firebase
├── screens/
│   ├── login_screen.dart      # Tela de login/cadastro
│   ├── home_screen.dart       # Lista de contatos + frase da API
│   └── chat_screen.dart       # Chat em tempo real com Firestore
└── services/
    └── quote_service.dart     # Serviço de consumo da API REST
```

### Tecnologias Utilizadas

| Tecnologia | Finalidade |
|---|---|
| **Flutter** | Framework cross-platform |
| **Firebase Auth** | Autenticação de usuários |
| **Cloud Firestore** | Banco de dados NoSQL em tempo real |
| **SharedPreferences** | Armazenamento local de sessão |
| **HTTP (dart)** | Consumo de API REST (dummyjson.com) |
| **Material Design** | Interface visual |

---

## Como Executar

### Pré-requisitos
- Flutter SDK (versão ^3.12.1)
- Dispositivo/emulador Android ou iOS
- Conexão com internet

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/1mscuzbot/whatsapp2.0.1.git

# 2. Entre na pasta
cd whatsapp2

# 3. Instale as dependências
flutter pub get

# 4. Execute o app
flutter run
```

> **Nota:** O Firebase já está configurado com as credenciais do projeto `whatsapp-2-9fa03`. Para testar em outro projeto Firebase, gere um novo arquivo `firebase_options.dart` com o FlutterFire CLI.

---

## Estrutura do Código — Passo a Passo

### `main.dart`
- Inicializa o `WidgetsFlutterBinding.ensureInitialized()`
- Chama `Firebase.initializeApp()` com as opções da plataforma
- Inicializa o `SharedPreferences` antes de rodar o app
- Configura o tema escuro (Red & Black) com fonte monoespaçada

### `login_screen.dart`
- **StatefulWidget** com controladores de e-mail e senha
- `initState()` verifica se há sessão salva no SharedPreferences
- Botão alterna entre modo **LOGIN** e **CADASTRO**
- Tratamento de erros do Firebase Auth (e-mail já cadastrado, senha fraca, etc.)
- Ao autenticar, salva o e-mail no SharedPreferences e navega para Home

### `home_screen.dart`
- Exibe lista de contatos (dados fixos para demonstração)
- Before da lista: **FutureBuilder** que chama `QuoteService.fetchRandomQuote()`
- Botão de **logout** no AppBar limpa SharedPreferences e retorna ao login
- Cada contato navega para `ChatScreen` com o nome do contato

### `chat_screen.dart`
- **StreamBuilder** escuta em tempo real a coleção `chats/{nomeContato}/mensagens`
- Ordena por `timestamp` decrescente (reverse: true para mostrar do fim pro começo)
- Campo de texto com `onSubmitted` para enviar ao pressionar Enter
- Mensagens enviadas vão para o Firestore com `enviadoPorMim: true`

### `quote_service.dart`
- Requisição HTTP GET para `https://dummyjson.com/quotes/random`
- Retorna a frase formatada com autor
- Tratamento de exceções (sem internet, timeout, etc.)
- Fácil de estender com outros endpoints

---

## Avaliação (PDF Prova Prática 2.3)

| Critério | Atendido |
|---|---|
| App funcional sem falhas críticas | ✅ |
| Navegação entre telas (Login → Home → Chat) | ✅ |
| 3 telas implementadas | ✅ |
| Projeto no GitHub | ✅ |
| Armazenamento local (SharedPreferences) | ✅ |
| Cloud Firestore (tempo real) | ✅ |
| Consumo de API REST (dummyjson.com) | ✅ |
| Firebase Auth | ✅ |
| Tema escuro personalizado | ✅ |

---

## Licença

Projeto acadêmico — sem fins comerciais.
