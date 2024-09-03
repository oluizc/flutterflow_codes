// Atualiza a senha do usuário.

import 'package:supabase/supabase.dart';

Future<bool> updateSupabasePassword(String newPassword) async {
  // Add your function code here!
  final response = await SupaFlow.client.auth
      .updateUser(UserAttributes(password: newPassword));

  if (response.user != null) {
    return true;
  } else {
    return false;
  }
}
