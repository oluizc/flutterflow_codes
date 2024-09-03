// Cria uma session_id, considerando fechamento e segundo plano do app, e atualiza num appState.
// Executar no main.dart

Future sessionControl() async {
  // Gere um novo session_id se necessário
  int newSessionId = DateTime.now().millisecondsSinceEpoch;
  print("Novo session_id gerado: $newSessionId");

  // Verifique se há um session_id existente
  if (FFAppState().sessionId == null ||
      FFAppState().sessionId == 0 ||
      FFAppState().sessionId == -1) {
    // Se não houver, atribua o novo session_id
    FFAppState().update(() {
      FFAppState().sessionId = newSessionId;
    });
    print(
        "Nenhum session_id existente. Novo session_id atribuído: ${FFAppState().sessionId}");
  } else {
    print("Session_id existente encontrado: ${FFAppState().sessionId}");
  }

  // Inicie a observação do ciclo de vida do app
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  print("Observador de ciclo de vida do app iniciado.");
}

// Classe para observar mudanças no ciclo de vida do app
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Armazene o momento em que o app foi para segundo plano
      FFAppState().update(() {
        FFAppState().lastPausedTime = DateTime.now();
      });
      print(
          "App foi para segundo plano. lastPausedTime atualizado para: ${FFAppState().lastPausedTime}");
    } else if (state == AppLifecycleState.resumed) {
      // O app voltou para o primeiro plano
      print("App retornou ao primeiro plano.");

      // Verifica se precisa gerar um novo session_id
      DateTime? lastPausedTime = FFAppState().lastPausedTime;
      if (lastPausedTime != null) {
        Duration timeSpentInBackground =
            DateTime.now().difference(lastPausedTime);
        print(
            "Tempo gasto em segundo plano: ${timeSpentInBackground.inMinutes} minutos");

        if (timeSpentInBackground.inMinutes > 30) {
          // Se mais de 1 minuto se passou, gere um novo session_id
          FFAppState().update(() {
            FFAppState().sessionId = DateTime.now().millisecondsSinceEpoch;
          });
          print(
              "Session_id expirado. Novo session_id atribuído: ${FFAppState().sessionId}");
        } else {
          print("Session_id ainda válido. Nenhuma alteração feita.");
        }
      } else {
        print(
            "Nenhum lastPausedTime encontrado ao retornar ao primeiro plano.");
      }
    }
  }
}
