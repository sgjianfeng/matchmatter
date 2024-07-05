import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/user.dart';


class AppWidgetListPage extends StatefulWidget {
  final String appId;
  final String teamId;

  AppWidgetListPage({
    required this.appId,
    required this.teamId,
  });

  @override
  _AppWidgetListPageState createState() => _AppWidgetListPageState();
}

class _AppWidgetListPageState extends State<AppWidgetListPage> {
  late Future<AppModel?> appFuture;
  late Future<List<RolePermissions>> rolesPermissionsFuture;

  @override
  void initState() {
    super.initState();
    final userId = UserDatabaseService.getCurrentUserId();
    appFuture = AppModel.getAppData(widget.appId, widget.teamId);
    rolesPermissionsFuture = getUserRolePermissions(widget.teamId, userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Widgets'),
      ),
      body: FutureBuilder<AppModel?>(
        future: appFuture,
        builder: (context, appSnapshot) {
          if (appSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (appSnapshot.hasError) {
            return Center(child: Text('Error: ${appSnapshot.error}'));
          } else if (!appSnapshot.hasData) {
            return Center(child: Text('App not found'));
          } else {
            final app = appSnapshot.data!;
            return FutureBuilder<List<RolePermissions>>(
              future: rolesPermissionsFuture,
              builder: (context, rolesPermissionsSnapshot) {
                if (rolesPermissionsSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (rolesPermissionsSnapshot.hasError) {
                  return Center(child: Text('Error: ${rolesPermissionsSnapshot.error}'));
                } else {
                  final rolesPermissions = rolesPermissionsSnapshot.data!;
                  final widgetDefinitions = app.getAppWidgetList();
                  return ListView.builder(
                    itemCount: widgetDefinitions.length,
                    itemBuilder: (context, index) {
                      final widgetDef = widgetDefinitions[index];
                      final roles = rolesPermissions
                          .where((rolePerm) => widgetDef.permissions.contains(rolePerm.permissionId))
                          .map((rolePerm) => rolePerm.roleId)
                          .toList();

                      return ListTile(
                        title: Text(widgetDef.name),
                        subtitle: Text('Roles: ${roles.join(', ')}\nDescription: ${widgetDef.description}'),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
