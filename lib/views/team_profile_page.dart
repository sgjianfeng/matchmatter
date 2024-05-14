import 'package:flutter/material.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';

class TeamProfilePage extends StatelessWidget {
  final Team team;

  TeamProfilePage({required this.team});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Section: Team Basic Properties
          Text(
            'Team ID: ${team.id}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Team Name: ${team.name}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Tags: ${team.tags.join(', ')}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),

          // Second Section: Team Roles and Members
          Text(
            'Roles:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: team.roles.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key}:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ...entry.value.map((user) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${user.name}',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Email: ${user.email}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
