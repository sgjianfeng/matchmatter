import 'package:flutter/material.dart';
import 'package:matchmatter/data/team.dart';

class RolesList extends StatelessWidget {
  final List<RoleModel> roles;

  const RolesList({super.key, required this.roles});

  @override
  Widget build(BuildContext context) {
    final joinedRoles = roles.where((role) {
      return true;
    }).toList();

    final notJoinedRoles = roles.where((role) {
      return false;
    }).toList();

    return ListView(
      children: [
        _buildRoleSection('Joined Roles', joinedRoles, true),
        _buildRoleSection('Not Joined Roles', notJoinedRoles, false),
      ],
    );
  }

  Widget _buildRoleSection(String title, List<RoleModel> roleList, bool isJoined) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        ...roleList.map((role) {
          final isAdmin = isJoined && role.data['apps']?.any((app) => app['roles']?.contains('adminrole')) ?? false;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(role.name),
                    trailing: isAdmin ? const Icon(Icons.admin_panel_settings) : null,
                  ),
                  if (role.data['apps'] != null)
                    ...role.data['apps'].map<Widget>((app) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (app['actions'] != null)
                              ...app['actions'].map<Widget>((action) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(action['name'], style: const TextStyle(fontStyle: FontStyle.italic)),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                        child: Text(action['description']),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
