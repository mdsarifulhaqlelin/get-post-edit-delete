// screens/users_screen.dart
import 'package:flutter/material.dart';
import '../models/user_models.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class UsersScreen extends StatefulWidget {
  final String token;
  
  const UsersScreen({super.key, required this.token});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late final ApiService _apiService;
  List<User> _users = [];
  bool _isLoadingUsers = true;
  String? _usersError;
  int _currentSkip = 0;
  int _totalUsers = 0;
  final int _limit = 30;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService()..setToken(widget.token);
    _fetchUsers();
  }

  Future<void> _fetchUsers({int skip = 0}) async {
    setState(() {
      _isLoadingUsers = true;
      _usersError = null;
    });

    try {
      final data = await _apiService.getUsers(skip);
      setState(() {
        _users = data['users'];
        _totalUsers = data['total'];
        _currentSkip = data['skip'];
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _usersError = e.toString();
        _isLoadingUsers = false;
      });
    }
  }

  void _nextPage() {
    if (_currentSkip + _limit < _totalUsers) {
      _fetchUsers(skip: _currentSkip + _limit);
    }
  }

  void _previousPage() {
    if (_currentSkip > 0) {
      _fetchUsers(skip: _currentSkip - _limit);
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'moderator':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchUsers(skip: _currentSkip),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '👥 User List',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _fetchUsers(skip: _currentSkip),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Showing ${_currentSkip + 1}-${_currentSkip + (_users.isEmpty ? 0 : _users.length)} of $_totalUsers users',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),
                      if (_isLoadingUsers)
                        const Center(child: CircularProgressIndicator())
                      else if (_usersError != null)
                        _buildErrorWidget()
                      else if (_users.isEmpty)
                        const Center(child: Text('No users found'))
                      else
                        _buildUsersList(),
                      const SizedBox(height: 20),
                      _buildPagination(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '❌ Error: $_usersError',
        style: TextStyle(
          color: Colors.red[900],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.network(
                    user.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            user.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('📧 ${user.email}', style: const TextStyle(fontSize: 13)),
                      Text('📱 ${user.phone}', style: const TextStyle(fontSize: 13)),
                      Text('🏢 ${user.company.name}', style: const TextStyle(fontSize: 13)),
                      Text('🎂 ${user.birthDate} (${user.age} years)', style: const TextStyle(fontSize: 13)),
                      Text('📍 ${user.address.city}, ${user.address.state}', style: const TextStyle(fontSize: 13)),
                      Text('🩸 ${user.bloodGroup}', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _currentSkip > 0 ? _previousPage : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          child: const Text('Previous'),
        ),
        const SizedBox(width: 15),
        Text(
          'Page ${_currentSkip ~/ _limit + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: _currentSkip + _limit < _totalUsers ? _nextPage : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          child: const Text('Next'),
        ),
      ],
    );
  }
}