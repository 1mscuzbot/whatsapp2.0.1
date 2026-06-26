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
- Contatos são usuários **reais cadastrados no Firebase**
- Busca automática da coleção `usuarios` no Firestore
- Exibe nome amigável (parte antes do `@`) e email completo
- Status **ONLINE** ao lado de cada contato
- Layout escuro no estilo **Red & Black**

### 3. Frase do Dia (API REST)
- Consumo da API pública [dummyjson.com](https://dummyjson.com/docs/quotes)
- Toda vez que a Home Screen é carregada, uma frase aleatória é buscada via HTTP
- Enquanto carrega, exibe um indicador de progresso
- Se a requisição falhar (sem internet), exibe mensagem amigável

### 4. Chat em Tempo Real (Firebase Firestore)
- Conversa individual com cada contato (usuário real do Firebase)
- `chatId` único gerado pela concatenação dos dois emails em ordem alfabética
- Mensagens armazenadas em `chats/{chatId}/mensagens`
- Cada mensagem armazena o `senderEmail` para identificar o remetente
- Nome do remetente exibido **acima** do balão de mensagem
- Balões de mensagem alinhados:
  - **Vermelho (direita):** mensagens enviadas por **Você**
  - **Verde-água (esquerda):** mensagens do **contato**
- **Sistema de não lidas:** collection `unread` no Firestore → badge vermelho na Home
- Envio pelo botão de envio ou pressionando **Enter** no teclado
- Campo de texto com placeholder "DIGITE E APERTE ENTER..."

### 5. Notificações de Mensagens Não Lidas
- Ao enviar uma mensagem, incrementa `unreadCount` do destinatário no Firestore
- Ao abrir o chat, zera o contador de não lidas
- Badge vermelho com o número ao lado do contato na Home Screen

### 6. Case-Insensitive para Emails
- Todos os emails são convertidos para **lowercase** ao salvar e comparar
- Evita duplicatas por digitação de maiúsculas/minúsculas (ex.: "User@Email.com" vira "user@email.com")

---

## Arquitetura do Projeto

```
lib/
├── main.dart                  # Ponto de entrada, inicialização do Firebase
├── firebase_options.dart      # Configuração automática do Firebase
├── screens/
│   ├── login_screen.dart      # Login/cadastro + salva user no Firestore
│   ├── home_screen.dart       # Lista usuários REAIS + frase da API
│   ├── chat_screen.dart       # Chat com chatId único (2 emails)
│   └── code_showcase_screen.dart # Tela didática p/ apresentação
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
- Ao autenticar, salva o e-mail no SharedPreferences e **também salva o usuário na coleção `usuarios` do Firestore** (para aparecer na lista de contatos de outros usuários)

### `home_screen.dart`
- **StreamBuilder** busca em tempo real a coleção `usuarios` do Firestore
- Filtra o próprio usuário logado (não mostra ele mesmo na lista)
- Mostra nome amigável (parte antes do `@`) e email completo de cada usuário
- Before da lista: **FutureBuilder** que chama `QuoteService.fetchRandomQuote()`
- Botão de **logout** no AppBar limpa SharedPreferences e retorna ao login
- Cada contato navega para `ChatScreen` com o email e nome do contato

### `chat_screen.dart`
- Gera um `chatId` único ordenando os dois emails e concatenando com `___`
- Ambos os usuários olham para o **mesmo** caminho: `chats/{chatId}/mensagens`
- **StreamBuilder** escuta em tempo real as mensagens
- Ordena por `timestamp` decrescente (reverse: true para mostrar do fim pro começo)
- Campo de texto com `onSubmitted` para enviar ao pressionar Enter
- Mensagens armazenam `senderEmail` (email do remetente)
- Exibe "Você" (vermelho, direita) ou nome do contato (verde-água, esquerda) acima do balão

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
| 3 telas implementadas (4 com CodeShowcase) | ✅ |
| Projeto no GitHub | ✅ |
| Armazenamento local (SharedPreferences) | ✅ |
| Cloud Firestore (tempo real) | ✅ |
| Consumo de API REST (dummyjson.com) | ✅ |
| Firebase Auth | ✅ |
| Contatos reais do Firebase (não hardcoded) | ✅ |
| ChatId único entre 2 usuários | ✅ |
| Nome do remetente acima do balão | ✅ |
| Cores por usuário (Vermelho/Verde) | ✅ |
| Mensagens não lidas com badge | ✅ |
| Case-insensitive para emails | ✅ |
| Tema escuro personalizado | ✅ |

---

## Licença

Projeto acadêmico — sem fins comerciais.
