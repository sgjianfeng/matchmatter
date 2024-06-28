import 'package:flutter/material.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/views/app_detail_page.dart';

class AppsList extends StatelessWidget {
  final List<AppModel> apps;
  final String searchQuery;

  const AppsList({super.key, required this.apps, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final filteredApps = apps.where((app) {
      final query = searchQuery.toLowerCase();
      final appMatch = app.name.toLowerCase().contains(query);
      final permissionMatch = app.permissions.any((permission) =>
          permission.name.toLowerCase().contains(query) ||
          permission.data.toString().toLowerCase().contains(query));
      return appMatch || permissionMatch;
    }).toList();

    return ListView.builder(
      itemCount: filteredApps.length,
      itemBuilder: (context, index) {
        final app = filteredApps[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppDetailPage(app: app)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${app.name} (${app.id})'),
                  ),
                  ...app.permissions.map((permission) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(permission.name),
                        subtitle: Text(permission.data.toString()),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
