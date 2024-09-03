// Em app nativo, abre o link no navegador padrão (e não em webview).

import 'package:url_launcher/url_launcher.dart';

Future launchInExternalBrowser(String urlString) async {
  final Uri uri = Uri.parse(urlString);

  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
