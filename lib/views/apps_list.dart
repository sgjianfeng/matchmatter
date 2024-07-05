import 'package:flutter/material.dart';
import 'package:matchmatter/data/app.dart';

class AppsList extends StatelessWidget {
  final List<AppModel> apps;
  final String searchQuery;
  final Function(AppModel) onAppSelected;

  const AppsList({
    super.key,
    required this.apps,
    required this.searchQuery,
    required this.onAppSelected,
  });

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
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () {
                onAppSelected(app);
              },
              child: ListTile(
                tileColor: _getTileColor(app), // 设置背景颜色
                title: Text(
                  '${app.name} (${app.id})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  app.description ?? 'No description available',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTileColor(AppModel app) {
    // 根据应用属性设置背景颜色，这里仅作示例
    if (app.name.toLowerCase().contains('important')) {
      return Colors.red.withOpacity(0.1);
    } else if (app.name.toLowerCase().contains('secondary')) {
      return Colors.blue.withOpacity(0.1);
    } else {
      return const Color.fromARGB(255, 183, 216, 233).withOpacity(0.1); // 默认背景颜色
    }
  }
}
