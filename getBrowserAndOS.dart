// Obtém o nome do Browser e OS onde a aplicação está sendo executada.
// Dependencia universal_html: ^2.2.4

import 'package:universal_html/html.dart' as html;

Future<String> getBrowserAndOS() async {
  final userAgent = html.window.navigator.userAgent.toLowerCase();

  String browserName;
  if (userAgent.contains('crios') || userAgent.contains('chrome')) {
    browserName = 'Chrome';
  } else if (userAgent.contains('fxios') || userAgent.contains('firefox')) {
    browserName = 'Firefox';
  } else if (userAgent.contains('version') && userAgent.contains('safari')) {
    browserName = 'Safari';
  } else if (userAgent.contains('edg') || userAgent.contains('edge')) {
    browserName = 'Edge';
  } else if (userAgent.contains('opr') || userAgent.contains('opera')) {
    browserName = 'Opera';
  } else if (userAgent.contains('trident') || userAgent.contains('msie')) {
    browserName = 'Internet Explorer';
  } else {
    browserName = 'Unknown';
  }

  String os;
  if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
    os = 'iOS';
  } else if (userAgent.contains('android')) {
    os = 'Android';
  } else if (userAgent.contains('windows')) {
    os = 'Windows';
  } else if (userAgent.contains('macintosh') || userAgent.contains('mac os')) {
    os = 'macOS';
  } else if (userAgent.contains('linux')) {
    os = 'Linux';
  } else {
    os = 'Unknown OS';
  }

  return '$browserName - $os';
}
