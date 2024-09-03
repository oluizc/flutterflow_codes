// Dependencia onesignal_flutter: ^5.2.3
// Executar action no main.dart

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart'; // Import necessário para usar kIsWeb

Future oneSignal() async {
  if (!kIsWeb) {
    // Verifica se NÃO é Web
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("465fa791-bf39-471d-9670-2aaab0d4e5b9");
    OneSignal.Notifications.requestPermission(true);

    // Obtém o OneSignal ID do usuário
    var oneSignalId = await OneSignal.User.getOnesignalId();
    if (oneSignalId != null) {
      FFAppState().update(() {
        FFAppState().oneSignalUserId = oneSignalId;
      });
    }
  } else {
    print("OneSignal não é compatível com a Web. Ação ignorada.");
  }
}
