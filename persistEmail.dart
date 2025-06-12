import 'package:shared_preferences/shared_preferences.dart';

Future persistEmail(String? userEmail) async {
  // Add your function code here!
  if (userEmail != null) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', userEmail);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getPersistedEmail() async {
  // Add your function code here!
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_email');
}
