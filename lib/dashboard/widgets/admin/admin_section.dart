import 'package:flutter/material.dart';
import 'create_user_card.dart';
import 'user_list_card.dart';

class AdminSection extends StatelessWidget {
  const AdminSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Admin Tools:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        CreateUserCard(),
        SizedBox(height: 16),
        UserListCard(), // 👈 This displays the user list with role changer
        Divider(),
      ],
    );
  }
}
