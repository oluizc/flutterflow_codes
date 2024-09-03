// Na web, abre o link na mesma aba do navegador.

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

Future<void> launchURLsameTab(String url) async {
  print("Attempting to launch URL: $url");

  if (url != null && await canLaunch(url)) {
    try {
      if (kIsWeb) {
        print("Launching on Web");
        await launch(
          url,
          webOnlyWindowName:
              '_self', // Isso deve garantir que abra na mesma aba
        );
      } else {
        print("This code is intended to run on the web only.");
      }
    } catch (e) {
      print("Error launching URL: $e");
      throw 'Could not launch $url';
    }
  } else {
    print("Could not launch $url");
    throw 'Could not launch $url';
  }
}
