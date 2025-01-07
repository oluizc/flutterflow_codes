/*
Sobre: Serve para criar um sistema de app traduzido alternativo ao do flutterflow (atualmente quebrado).
Action: Pega um arquivo JSON de tradução e importa num appState para ser consultado dentro do app.
Formato do JSON sugerido:
{
  "home": {
    "hello": "Olá",
    "welcome": "Bem-vindo",
    "logout": "Sair"
  } }
*/

import 'dart:convert';
import 'package:flutter/services.dart';

Future<void> refreshLanguageData() async {
  // MODIFY CODE ONLY BELOW THIS LINE

  // Log inicial indicando que a função foi chamada
  print('refreshLanguageData: Função chamada');

  // 1. Verifica o valor do AppState `currentLanguage`
  final Idiomas? currentLanguage = FFAppState().currentLanguage;
  if (currentLanguage == null) {
    print('refreshLanguageData: currentLanguage está null. Função encerrada.');
    return;
  }
  print('refreshLanguageData: currentLanguage encontrado -> $currentLanguage');

  // 2. Usa o nome do enum (valor literal) para concatenar com ".json"
  final String fileName = '${currentLanguage.name}.json';
  print('refreshLanguageData: Nome do arquivo JSON -> $fileName');

  // 3. Caminho do arquivo JSON
  final String filePath = 'assets/jsons/$fileName';
  print('refreshLanguageData: Caminho completo do arquivo -> $filePath');

  try {
    // 4. Carrega o conteúdo do arquivo JSON
    print('refreshLanguageData: Tentando carregar o arquivo JSON...');
    final String jsonString = await rootBundle.loadString(filePath);
    print('refreshLanguageData: Arquivo JSON carregado com sucesso');

    // 5. Decodifica o JSON
    print('refreshLanguageData: Decodificando o JSON...');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    print('refreshLanguageData: JSON decodificado com sucesso');

    // 6. Salva o JSON no AppState `appLanguage`
    FFAppState().appLanguage = jsonMap;
    print('refreshLanguageData: JSON salvo no appState.appLanguage');
  } catch (e) {
    // Log detalhado do erro
    print('refreshLanguageData: Erro ao carregar o arquivo JSON -> $e');
  }

  // MODIFY CODE ONLY ABOVE THIS LINE
}
