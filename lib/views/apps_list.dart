import 'package:flutter/material.dart';
import 'package:matchmatter/data/app.dart';

class AppsList extends StatelessWidget {
  final List<AppModel> apps;
  final String searchQuery;
  final Function(AppModel) onAppSelected;

  const AppsList({super.key, required this.apps, required this.searchQuery, required this.onAppSelected});

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
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Adjust the padding for more spacing
          child: Card(
            elevation: 4.0, // Slight elevation for a subtle floating effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Rounded corners for a softer look
            ),
            child: InkWell(
              onTap: () {
                onAppSelected(app); // Call the callback function
              },
              child: ListTile(
                title: Text(
                  '${app.name} (${app.id})',
                  style: Theme.of(context).textTheme.titleMedium, // Use theme for consistent styling
                ),
                subtitle: Text(
                  app.description ?? 'No description available',
                  style: Theme.of(context).textTheme.bodySmall, // Use theme for consistent styling
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
