import 'package:flutter/material.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';

class TeamProfilePage extends StatelessWidget {
  final Team team;
  final Map<String, List<UserModel>> roles;

  const TeamProfilePage({
    super.key,
    required this.team,
    required this.roles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 不显示返回按钮
        title: const Text('Team Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team ID: ${team.id}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Team Name: ${team.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Description: ${team.description ?? 'No description available'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Created At: ${team.createdAt.toDate()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tags: ${team.tags.join(', ')}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Admins',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildRoleSection(roles['admins'], context),
            const SizedBox(height: 16),
            const Text(
              'Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildRoleSection(roles['members'], context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoleSection(List<UserModel>? users, BuildContext context, {List<UserModel>? excludeFrom}) {
    if (users == null || users.isEmpty) {
      return [const Text('No users in this role.')];
    }

    Set<String> excludeUids = excludeFrom?.map((user) => user.uid).toSet() ?? {};

    return users
        .where((user) => !excludeUids.contains(user.uid))
        .map((user) {
      print("Displaying user: ${user.name}, email: ${user.email}");
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(user.name[0]),
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Placeholder for role settings action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Role settings clicked')),
                );
              },
            ),
          ),
          const Divider(),
        ],
      );
    }).toList();
  }
}
