import 'package:flutter/material.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/views/app_detail_page.dart';

class AppsSearchDelegate extends SearchDelegate<String> {
  final List<AppModel> apps;
  final String currentQuery;
  final ValueChanged<String> onQueryUpdate;

  AppsSearchDelegate(this.apps, this.currentQuery, this.onQueryUpdate) {
    query = currentQuery;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onQueryUpdate(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = apps.where((app) {
      final appMatch = app.name.toLowerCase().contains(query.toLowerCase());
      final permissionMatch = app.permissions.any((permission) =>
          permission.name.toLowerCase().contains(query.toLowerCase()) || 
          permission.data.toString().toLowerCase().contains(query.toLowerCase()));
      return appMatch || permissionMatch;
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final app = results[index];
        return ListTile(
          title: Text(app.name),
          subtitle: Text(app.description ?? ''),
          onTap: () {
            close(context, app.name);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppDetailPage(app: app)),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
