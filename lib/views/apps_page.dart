import 'package:flutter/material.dart';

// 模型定义
class ActionModel {
  final String name;
  final String description;

  ActionModel({required this.name, required this.description});
}

class PermissionModel {
  final String name;
  final List<ActionModel> actions;

  PermissionModel({required this.name, required this.actions});
}

class AppModel {
  final String name;
  final List<String> roles;
  final List<ActionModel> actions;

  AppModel({required this.name, required this.roles, required this.actions});
}

class RoleModel {
  final String name;
  final List<AppModel> apps;

  RoleModel({required this.name, required this.apps});
}

// 模拟数据生成
final List<AppModel> apps = List.generate(10, (index) {
  return AppModel(
    name: 'application${index + 1}',
    roles: List.generate(2, (roleIndex) => 'role${index * 2 + roleIndex}'),
    actions: List.generate(2, (actionIndex) => ActionModel(
      name: 'action${index * 2 + actionIndex}',
      description: 'action${index * 2 + actionIndex} description',
    )),
  );
});

final List<RoleModel> roles = List.generate(5, (roleIndex) {
  return RoleModel(
    name: 'role${roleIndex + 1}',
    apps: List.generate(5, (appIndex) {
      return AppModel(
        name: 'app${roleIndex * 5 + appIndex + 1}',
        roles: [], // 角色列表不需要在这里定义
        actions: List.generate(3, (permIndex) {
          return ActionModel(
            name: 'permission${roleIndex * 15 + appIndex * 3 + permIndex + 1}',
            description: 'description for permission${roleIndex * 15 + appIndex * 3 + permIndex + 1}',
          );
        }),
      );
    }),
  );
});

// AppsPage 实现
class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  _AppsPageState createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  String searchQuery = '';
  bool showRoles = false;

  @override
  Widget build(BuildContext context) {
    final filteredApps = apps.where((app) {
      final query = searchQuery.toLowerCase();
      final appMatch = app.name.toLowerCase().contains(query);
      final roleMatch = app.roles.any((role) => role.toLowerCase().contains(query));
      final actionMatch = app.actions.any((action) =>
          action.name.toLowerCase().contains(query) ||
          action.description.toLowerCase().contains(query));
      return appMatch || roleMatch || actionMatch;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,  // 缩小搜索栏高度
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.apps),
                  onPressed: () {
                    setState(() {
                      showRoles = false;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    setState(() {
                      showRoles = true;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: showRoles ? _buildRolesList() : _buildAppsList(filteredApps),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsList(List<AppModel> apps) {
    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),  // 减少 header 和 action item 之间的空隙
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${app.name} (${app.roles.join(', ')})'),
                ),
                ...app.actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),  // 减少 action item 之间的空隙
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,  // 减少 ListTile 内部的 padding
                      title: Text(action.name),
                      subtitle: Text(action.description),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRolesList() {
    return ListView.builder(
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),  // 减少 header 和 action item 之间的空隙
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(role.name),
                ),
                ...role.apps.map((app) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),  // 减少 app item 之间的空隙
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ...app.actions.map((action) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(action.name, style: const TextStyle(fontStyle: FontStyle.italic)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                  child: Text(action.description),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
