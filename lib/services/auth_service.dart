import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = 'http://10.0.2.2:5001/api/auth';

  Future<String?> registerUser(String phoneNumber, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return 'User registered successfully';
    } else {
      return 'Failed to register user';
    }
  }

  Future<String?> loginUser(String phoneNumber, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phoneNumber': phoneNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data['token']);
      return 'Login successful';
    } else {
      return 'Failed to login';
    }
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
