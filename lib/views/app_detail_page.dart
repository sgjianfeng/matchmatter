import 'package:flutter/material.dart';
import 'package:matchmatter/data/app.dart';

class AppDetailPage extends StatelessWidget {
  final AppModel app;

  const AppDetailPage({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'App ID: ${app.id}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Description: ${app.description ?? 'No description available'}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Permissions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: app.permissions.map((permission) {
              return ListTile(
                title: Text(permission.name),
                subtitle: Text(permission.data.toString()),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
