import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matchmatter/data/service.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/data/action.dart' as mm; // Import with alias
import 'package:matchmatter/services/service_actions_registry.dart';

class ServiceActionListPage extends StatefulWidget {
  final Service service;
  final String teamId;
  final ValueChanged<mm.Action> onActionSelected; // Use alias here

  ServiceActionListPage({
    required this.service,
    required this.teamId,
    required this.onActionSelected,
  });

  @override
  _ServiceActionListPageState createState() => _ServiceActionListPageState();
}

class _ServiceActionListPageState extends State<ServiceActionListPage> {
  late Future<Map<String, List<mm.Action>>> userActionsFuture; // Use alias here

  @override
  void initState() {
    super.initState();
    final userId = UserDatabaseService.getCurrentUserId();
    ServiceActionsRegistry.registerAllForService(widget.service.id); // 注册当前 service 的所有 action
    userActionsFuture = getUserActionsInService(userId: userId, teamId: widget.teamId, serviceId: widget.service.id);
    _setServiceId();
  }

  Future<void> _setServiceId() async {
    await UserDatabaseService(uid: FirebaseAuth.instance.currentUser?.uid).setServiceId(widget.service.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<mm.Action>>>(
      future: userActionsFuture, // Use alias here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final roleActions = snapshot.data!;
          final actionDefinitions = widget.service.actions.where((action) {
            return roleActions.values.any((actions) => actions.contains(action));
          }).toList();

          return ListView.builder(
            itemCount: actionDefinitions.length,
            itemBuilder: (context, index) {
              final actionDef = actionDefinitions[index];
              final roles = roleActions.entries
                  .where((entry) => entry.value.contains(actionDef))
                  .map((entry) => entry.key)
                  .toList();

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  title: Text(
                    actionDef.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Roles: ${roles.join(', ')}\nDescription: ${actionDef.description}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => widget.onActionSelected(actionDef), // Use alias here
                ),
              );
            },
          );
        }
      },
    );
  }
}
