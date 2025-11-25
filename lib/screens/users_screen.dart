// screens/users_screen.dart
import 'package:flutter/material.dart';
import 'package:project/screens/user_details_screen.dart';
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
  TextEditingController _searchController = TextEditingController();
  List<String> _hairColors = []; // Hair colors dropdown এর জন্য
  String? _selectedHairColor; // Selected hair color for filtering

  Future<void> _fetchHairColors() async {
    setState(() {
      _hairColors = [
        'Black',
        'Brown',
        'Blonde',
        'Red',
        'Gray',
        'Auburn',
        'Chestnut',
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _apiService = ApiService()..setToken(widget.token);
    _fetchHairColors();
    _fetchUsers();
    _searchController = TextEditingController();
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

  void _searchUsers(String query) {
    if (query.isEmpty) {
      _fetchUsers(skip: _currentSkip);
      return;
    }

    setState(() {
      _users = _users.where((user) {
        final name = "${user.firstName} ${user.lastName}".toLowerCase();
        final email = user.email.toLowerCase();
        final phone = user.phone.toLowerCase();

        return name.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase()) ||
            phone.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _filterByHairColor(String color) async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final data = await _apiService.filterUsers(
        key: "hair.color",
        value: color,
        limit: _limit,
        skip: 0,
      );

      setState(() {
        _users = data['users'];
        _totalUsers = data['total'];
        _currentSkip = 0;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _usersError = e.toString();
        _isLoadingUsers = false;
      });
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
            icon: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 255, 0, 0),
            ),
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
                      

                      // 🔍 SEARCH FIELD
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _searchUsers(value);
                        },
                        decoration: InputDecoration(
                          hintText: "Search users...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // CLEAR FILTERS BUTTON,
                      if (_searchController.text.isNotEmpty ||
                          _selectedHairColor != null)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _selectedHairColor = null;
                            });
                            _fetchUsers(skip: 0);
                          },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),

                      const SizedBox(height: 20),

                      // 🎨 FILTER DROPDOWN
                      DropdownButtonFormField<String>(
                        value: _selectedHairColor,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: "Filter by Hair Color",
                          suffixIcon: _selectedHairColor != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _selectedHairColor = null;
                                      _fetchUsers(skip: _currentSkip);
                                    });
                                  },
                                )
                              : null,
                        ),
                        items: _hairColors.map((color) {
                          return DropdownMenuItem(
                            value: color,
                            child: Text(color),
                          );
                        }).toList(),
                        onChanged: (color) {
                          if (color != null) {
                            setState(() {
                              _selectedHairColor = color;
                            });
                            _filterByHairColor(color);
                          }
                        },
                      ),
                      const SizedBox(height: 15),

                      // 📊 SORT DROPDOWN
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: "Sort By",
                          prefixIcon: const Icon(Icons.sort),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "name",
                            child: Text("Name (A-Z)"),
                          ),
                          DropdownMenuItem(value: "age", child: Text("Age")),
                          DropdownMenuItem(
                            value: "company",
                            child: Text("Company"),
                          ),
                        ],
                        onChanged: (sortBy) {
                          setState(() {
                            // সর্টিং লজিক অ্যাড করুন
                            if (sortBy == "name") {
                              _users.sort(
                                (a, b) => "${a.firstName} ${a.lastName}"
                                    .compareTo("${b.firstName} ${b.lastName}"),
                              );
                            } else if (sortBy == "age") {
                              _users.sort((a, b) => a.age.compareTo(b.age));
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      
Card(
  color: Colors.blue[50],
  child: Padding(
    padding: const EdgeInsets.all(15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Total', '$_totalUsers', Icons.people),
        _buildStatItem('Avg Age', '${_users.isEmpty ? 0 : (_users.map((u) => u.age).reduce((a, b) => a + b) / _users.length).toStringAsFixed(1)}', Icons.calculate),
        _buildStatItem('Active', '${_users.where((u) => u.role.toLowerCase() != 'inactive').length}', Icons.check_circle),
      ],
    ),
  ),
),

const SizedBox(height: 20),

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
        style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
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

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailsScreen(user: user),
              ),
            );
          },
          child: Card(
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
                        Text('📧 ${user.email}'),
                        Text('📱 ${user.phone}'),
                        Text('🏢 ${user.company.name}'),
                        Text('🎂 ${user.birthDate} (${user.age} years)'),
                        Text('📍 ${user.address.city}, ${user.address.state}'),
                        Text('🩸 ${user.bloodGroup}'),
                      ],
                    ),
                  ),
                ],
              ),
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
  Widget _buildStatItem(String label, String value, IconData icon) {
  return Column(
    children: [
      Icon(icon, color: Colors.blue, size: 30),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ],
  );
}
}
