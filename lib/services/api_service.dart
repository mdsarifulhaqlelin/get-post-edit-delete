// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_model.dart';
import '../models/user_models.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';
  static const int limit = 30;

  String? _authToken;

  // কন্সট্রাক্টরে টোকেন নেওয়ার অপশন
  ApiService({String? token}) : _authToken = token;

  // টোকেন সেট করার মেথড
  void setToken(String token) {
    _authToken = token;
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      _authToken = loginResponse.accessToken; // অটো সেট হয়ে যাবে
      return loginResponse;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUsers(int skip) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users?limit=$limit&skip=$skip'),
      headers: {'Authorization': 'Bearer $_authToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<User> users = (data['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
      return {
        'users': users,
        'total': data['total'],
        'skip': data['skip'],
        'limit': data['limit'],
      };
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  }

  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/me'),
      headers: {'Authorization': 'Bearer $_authToken'},
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load current user: ${response.body}');
    }
  }

  Future<User> getUserById(int userId) async {
    if (_authToken == null) {
      throw Exception('No authentication token available');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Authorization': 'Bearer $_authToken'},
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to fetch user: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> searchUsers(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/search?q=$query'),
      headers: {'Authorization': 'Bearer $_authToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<User> users = (data['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();

      return {
        'users': users,
        'total': data['total'],
        'skip': data['skip'],
        'limit': data['limit'],
      };
    } else {
      throw Exception('Failed to search users: ${response.body}');
    }
  }

  // filterUsers
  Future<Map<String, dynamic>> filterUsers({
    required String key,
    required String value,
    int limit = 30,
    int skip = 0,
    String? hairColor,
    String? select,
  }) async {
    // Base filter URL
    String url =
        '$baseUrl/users/filter?key=$key&value=$value&limit=$limit&skip=$skip';

    // Add hair color filter (optional)
    if (hairColor != null && hairColor.isNotEmpty) {
      url += '&hair.color=$hairColor';
    }

    if (select != null && select.isNotEmpty) {
      url += '&select=$select';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_authToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<User> users = (data['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();

      return {
        'users': users,
        'total': data['total'],
        'skip': data['skip'],
        'limit': data['limit'],
      };
    } else {
      throw Exception('Failed to filter users: ${response.body}');
    }
  }
}
