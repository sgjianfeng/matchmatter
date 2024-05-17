import 'package:flutter/material.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';

class TeamProfilePage extends StatelessWidget {
  final Team team;
  final Map<String, List<UserModel>> roles;

  const TeamProfilePage({
    Key? key,
    required this.team,
    required this.roles,
  }) : super(key: key);

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
            Text(
              'Admins',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildRoleSection(roles['admins']),
            const SizedBox(height: 16),
            Text(
              'Members',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildRoleSection(roles['members']),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRoleSection(List<UserModel>? users, {List<UserModel>? excludeFrom}) {
    if (users == null || users.isEmpty) {
      return [const Text('No users in this role.')];
    }

    Set<String> excludeUids = excludeFrom?.map((user) => user.uid!).toSet() ?? {};

    return users
        .where((user) => !excludeUids.contains(user.uid))
        .map((user) {
      return ListTile(
        leading: CircleAvatar(
          child: Text(user.name[0]),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
      );
    }).toList();
  }
}
