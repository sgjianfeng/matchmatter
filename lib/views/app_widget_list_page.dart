import 'package:flutter/material.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/app_widgets_registry.dart';

class AppWidgetListPage extends StatefulWidget {
  final AppModel app;
  final String teamId;
  final ValueChanged<AppWidget> onWidgetSelected;

  AppWidgetListPage({
    required this.app,
    required this.teamId,
    required this.onWidgetSelected,
  });

  @override
  _AppWidgetListPageState createState() => _AppWidgetListPageState();
}

class _AppWidgetListPageState extends State<AppWidgetListPage> {
  late Future<List<RolePermissions>> rolesPermissionsFuture;

  @override
  void initState() {
    super.initState();
    final userId = UserDatabaseService.getCurrentUserId();
    AppWidgetsRegistry.registerAllForApp(widget.app.id); // 注册当前 app 的所有小部件
    rolesPermissionsFuture = getUserRolePermissions(widget.teamId, userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RolePermissions>>(
      future: rolesPermissionsFuture,
      builder: (context, rolesPermissionsSnapshot) {
        if (rolesPermissionsSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (rolesPermissionsSnapshot.hasError) {
          return Center(child: Text('Error: ${rolesPermissionsSnapshot.error}'));
        } else {
          final rolesPermissions = rolesPermissionsSnapshot.data!;
          final widgetDefinitions = widget.app.getAppWidgetList();

          return ListView.builder(
            itemCount: widgetDefinitions.length,
            itemBuilder: (context, index) {
              final widgetDef = widgetDefinitions[index];
              final roles = rolesPermissions
                  .where((rolePerm) => widgetDef.permissions.contains(rolePerm.permissionId))
                  .map((rolePerm) => rolePerm.roleId)
                  .toList();

              return ListTile(
                title: Text(widgetDef.title),
                subtitle: Text('Roles: ${roles.join(', ')}\nDescription: ${widgetDef.description}'),
                onTap: () => widget.onWidgetSelected(widgetDef),
              );
            },
          );
        }
      },
    );
  }
}
