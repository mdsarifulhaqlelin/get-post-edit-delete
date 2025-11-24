import 'package:flutter/material.dart';
import '../models/user_models.dart';

class UserDetailsScreen extends StatelessWidget {
  final User user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${user.firstName} ${user.lastName}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipOval(
                child: Image.network(
                  user.image,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text("Name: ${user.firstName} ${user.lastName}",
                style: const TextStyle(fontSize: 18)),

            Text("Email: ${user.email}", style: const TextStyle(fontSize: 16)),
            Text("Phone: ${user.phone}", style: const TextStyle(fontSize: 16)),
            Text("Company: ${user.company.name}", style: const TextStyle(fontSize: 16)),
            Text("Age: ${user.age}", style: const TextStyle(fontSize: 16)),
            Text("Birth Date: ${user.birthDate}", style: const TextStyle(fontSize: 16)),
            Text("Address: ${user.address.city}, ${user.address.state}",
                style: const TextStyle(fontSize: 16)),
            Text("Blood Group: ${user.bloodGroup}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
