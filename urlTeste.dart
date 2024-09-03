// Verifica se a URL atual é igual a URL de teste do app e atualiza um appState Boolean.
// Dependencia uni_links2: ^0.6.0+2
// Executar no main.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:uni_links2/uni_links.dart';

Future urlTeste() async {
  // Declare uma variável para armazenar o resultado
  bool isEqual = false;

  if (kIsWeb) {
    // Se for a web, execute o código relacionado à web
    var url = Uri.base.toString();
    Uri uri = Uri.parse(url);
    String baseUrl = '${uri.scheme}://${uri.host}';

    // Verificar se a URL base é igual a https://creevo.art
    isEqual = baseUrl == 'https://creevo-x9qhtr.flutterflow.app';
  } else if (Platform.isAndroid || Platform.isIOS) {
    // Se for Android ou iOS, use uni_links para obter o link inicial
    String? initialLink = await getInitialLink();
    if (initialLink != null) {
      Uri uri = Uri.parse(initialLink);
      String baseUrl = '${uri.scheme}://${uri.host}';

      // Verificar se a URL base é igual a https://creevo.art
      isEqual = baseUrl == 'https://creevo-x9qhtr.flutterflow.app';
    }
  }

  // Atualize o estado com o resultado
  FFAppState().update(() {
    FFAppState().urlTeste = isEqual;
  });
}
