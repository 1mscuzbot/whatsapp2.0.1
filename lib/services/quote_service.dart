// =============================================================================
// ARQUIVO: quote_service.dart
// OBJETIVO: Consumir uma API REST pública (quotable.io) para exibir citações
//           aleatórias na tela inicial. Demonstra o uso de requisições HTTP
//           no app (requisito: consumo de API REST).
// =============================================================================

import 'dart:convert';   // Para usar jsonDecode()
import 'package:http/http.dart' as http; // Pacote para fazer requisições HTTP

// -----------------------------------------------------------------------------
// PASSO 3: Classe QuoteService — serviço de API REST
// -----------------------------------------------------------------------------
class QuoteService {
  // URL da API pública de citações (quotable.io)
  // Retorna um JSON com { content, author, ... }
  static const String _apiUrl = 'https://api.quotable.io/random';

  // -------------------------------------------------------------------------
  // Método: fetchRandomQuote()
  // Faz uma requisição GET para a API e retorna uma frase aleatória.
  // Retorna uma String com a citação ou uma mensagem de erro amigável.
  // -------------------------------------------------------------------------
  static Future<String> fetchRandomQuote() async {
    try {
      // PASSO 3.1: Dispara a requisição HTTP GET
      final response = await http.get(
        Uri.parse(_apiUrl),
        // Headers padrão para garantir resposta em JSON
        headers: {'Accept': 'application/json'},
      );

      // PASSO 3.2: Verifica se a resposta foi bem-sucedida (código 200)
      if (response.statusCode == 200) {
        // Converte o JSON da resposta em um Map Dart
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Extrai o conteúdo e o autor
        final content = data['content'] as String? ?? '';
        final author = data['author'] as String? ?? 'Desconhecido';

        // Retorna formatado
        return '"$content"\n\n— $author';
      } else {
        // Se a API retornou erro, lançamos uma exceção
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Se algo deu errado (rede fora do ar, API lenta, etc.),
      // retorna uma mensagem informativa em vez de quebrar o app
      return '★ Conecte-se à internet ★\n\n(Frase indisponível no momento)';
    }
  }

  // -------------------------------------------------------------------------
  // DESAFIO: Tente adicionar outras requisições aqui!
  // Ex.: Uma função buscarCep() que usa a API ViaCEP (viacep.com.br).
  // -------------------------------------------------------------------------
}
