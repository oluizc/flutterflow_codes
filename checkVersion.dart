// Atualiza um app state com a versão atual do app e compara com a versão de uma tabela do supabase de controle de versão do app.
// Dependencia package_info_plus: ^8.0.0
// Executar no main.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert'; // Para converter o resultado em JSON
import 'package:package_info_plus/package_info_plus.dart'; // Certifique-se de importar o package_info_plus

Future checkVersion() async {
  // Obtenha a versão atual do app
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  // Atualize o FFAppState com a versão atual
  FFAppState().update(() {
    FFAppState().currentVersion = currentVersion;
  });

  final supabase = SupaFlow.client;
  final response = await supabase
      .from('controle_versao')
      .select('*')
      .order('data_lancamento', ascending: false)
      .limit(1)
      .execute();

  if (response.status != 200 || response.data == null) {
    print('Erro ao buscar a versão ou dados nulos.');
    return;
  }

  final List<dynamic> data = response.data;

  if (data.isEmpty) {
    print('Nenhuma versão encontrada.');
    return;
  }

  final Map<String, dynamic> latestVersionData =
      data[0]; // Obtenha a última versão
  final String latestVersion = latestVersionData['versao'];

  bool isVersionLower(String currentVersion, String minimumVersion) {
    List<String> currentParts = currentVersion.split('.');
    List<String> minimumParts = minimumVersion.split('.');

    for (int i = 0; i < currentParts.length; i++) {
      int currentPart = int.parse(currentParts[i]);
      int minimumPart = int.parse(minimumParts[i]);

      if (currentPart < minimumPart) {
        return true;
      } else if (currentPart > minimumPart) {
        return false;
      }
    }

    return false; // As versões são iguais
    print('Nenhuma nova versão do app foi encontrada!');
  }

  if (isVersionLower(currentVersion, latestVersion)) {
    FFAppState().update(() {
      FFAppState().newVersionData = latestVersionData;
    });
  }
}
