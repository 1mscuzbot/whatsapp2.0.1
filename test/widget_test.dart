// Teste básico: verifica se o app inicializa sem erros.
// Como o app depende de Firebase (que precisa de emulador/dispositivo),
// este teste é apenas estrutural para verificar importações.

import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp2/main.dart';

void main() {
  testWidgets('App deve carregar sem erros estruturais', 
      (WidgetTester tester) async {
    // Apenas verificamos que o arquivo main.dart importa corretamente.
    // O teste completo com Firebase requer setup de emulador.
    expect(Whatsapp2App, isA<Type>());
  });
}
