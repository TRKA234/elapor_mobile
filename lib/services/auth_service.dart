import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  // Fungsi Login Sederhana
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.authUrl));

      if (response.statusCode == 200 && response.body.contains("TERKONEKSI")) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
