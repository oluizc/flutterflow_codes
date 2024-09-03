// Escuta a chamda de deep linking e executa uma action (redirect, por exemplo).

import 'package:uni_links2/uni_links.dart';
import 'dart:async';

Future<void> handleDeepLink(Future Function(String code) action) async {
  // Escuta links em primeiro plano
  linkStream.listen((String? link) async {
    if (link != null) {
      await _handleLink(link, action);
      print('Escutou link em primeiro plano');
    }
  }, onError: (err) {
    // Handle exception here
    print('Erro ao receber deep link: $err');
  });
}

Future<void> _handleLink(
    String link, Future Function(String code) action) async {
  // Extrai e processa os parâmetros do deep link
  final Uri uri = Uri.parse(link);
  bool redirectGoogle = false;
  String? code;

  if (uri.queryParameters.containsKey('redirectGoogle')) {
    redirectGoogle = uri.queryParameters['redirectGoogle'] == 'true';
  }

  if (uri.queryParameters.containsKey('code')) {
    code = uri.queryParameters['code'];
  }

  // Verifica as condições e executa a ação ou imprime erro
  if (redirectGoogle) {
    if (code != null && code.isNotEmpty) {
      await action(code);
    } else {
      print('Erro: Código não encontrado');
    }
  } else {
    print('Erro: redirectGoogle não é true');
  }
}
