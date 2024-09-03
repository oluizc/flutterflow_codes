// Pega as informações do usuario na tabela users e disponibiliza num appState.
// Executar no main.dart e no ato de login

import 'package:supabase_flutter/supabase_flutter.dart';

Future getUserInfo() async {
  final supabase = SupaFlow.client;
  // Obtém o usuário autenticado
  final currentUser = supabase.auth.currentUser;

  if (currentUser != null) {
    // Faz a consulta na tabela 'users' para obter os dados do usuário
    final response = await supabase
        .from('users')
        .select()
        .eq('id', currentUser.id)
        .single()
        .execute();

    // Verifica se a resposta é bem-sucedida e se os dados existem
    if (response.status == 200 && response.data != null) {
      // Extrai os dados retornados da consulta
      final userInfo = response.data;

      // Converte e mapeia os dados para o App State
      FFAppState().currentUserData = UserDataStruct(
        empresaId: userInfo['empresa_id'],
        funcaoSistemaId: userInfo['funcao_sistema_id'],
        userNome: userInfo['user_nome'],
        userFoto: userInfo['user_foto'],
        userEmail: userInfo['user_email'],
      );
    } else {
      // Se a tabela não for encontrada ou não houver dados, a action é finalizada sem travar
      print('Tabela de usuários não encontrada ou nenhum dado retornado.');
      return;
    }
  } else {
    // Caso não haja um usuário autenticado
    print('Usuário não autenticado.');
    return;
  }
}
