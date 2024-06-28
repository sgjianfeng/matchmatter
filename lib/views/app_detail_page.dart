import 'package:flutter/material.dart';
import 'package:matchmatter/data/app.dart';

class AppDetailPage extends StatelessWidget {
  final AppModel app;

  const AppDetailPage({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${app.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Description: ${app.description}'),
            const SizedBox(height: 10),
            const Text('Permissions:'),
            ...app.permissions.map((permission) {
              return ListTile(
                title: Text(permission.name),
                subtitle: Text(permission.data.toString()),
              );
            }),
          ],
        ),
      ),
    );
  }
}
