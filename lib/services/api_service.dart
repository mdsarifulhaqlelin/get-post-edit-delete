import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_model.dart';
import '../models/user_models.dart';

class ApiService {
  // ❌ ঠিক করুন: URL-এর শেষে স্পেস নেই
  static const String baseUrl = 'https://dummyjson.com';
  static const int limit = 30;

  String? _authToken;

  ApiService({String? token}) : _authToken = token;

  void setToken(String token) {
    _authToken = token;
  }

  // ------------------ Authentication ------------------

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      _authToken = loginResponse.accessToken;
      return loginResponse;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // ------------------ User Management ------------------

  Future<User> addUser(User newUser) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newUser.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add user: ${response.body}');
    }
  }

  // ✅ আপনার মেথডটি ঠিক করা হয়েছে:
  Future<Map<String, dynamic>> getUsers(int skip) async {
    // ❌ চেক করুন: টোকেন null কিনা
    if (_authToken == null) {
      throw Exception('Authentication token is missing');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users?limit=$limit&skip=$skip'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // ❌ চেক করুন: data['users'] null কিনা
      if (data['users'] == null || data['users'] is! List) {
        throw Exception('Invalid response format');
      }

      List<User> users = (data['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();

      return {
        'users': users,
        'total': data['total'] ?? 0,
        'skip': data['skip'] ?? 0,
        'limit': data['limit'] ?? limit,
      };
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  }

  Future<User> getCurrentUser() async {
    if (_authToken == null) {
      throw Exception('No authentication token available');
    }

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
    if (_authToken == null) {
      throw Exception('No authentication token available');
    }

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

  Future<Map<String, dynamic>> filterUsers({
    required String key,
    required String value,
    int limit = 30,
    int skip = 0,
    String? select,
  }) async {
    if (_authToken == null) {
      throw Exception('No authentication token available');
    }

    String url = '$baseUrl/users/filter?key=$key&value=$value&limit=$limit&skip=$skip';

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