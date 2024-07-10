import 'package:flutter/material.dart';
import 'package:matchmatter/data/service.dart';
import 'package:matchmatter/data/action.dart' as mm; // Import with alias
import 'package:matchmatter/services/service_actions_registry.dart';

class ServiceActionPage extends StatelessWidget {
  final Service service;
  final mm.Action action;
  final String teamId;
  final List<String> roles;

  ServiceActionPage({
    required this.service,
    required this.action,
    required this.teamId,
    required this.roles,
  });

  @override
  Widget build(BuildContext context) {
    final actionBuilder = ServiceActionsRegistry.getActionBuilder(service.id, action.name);
    if (actionBuilder == null) {
      return Center(
        child: Text('Action not found: ${service.id}/${action.name}'),
      );
    }
    final actionContent = actionBuilder(service.id, action.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${service.name}\nRoles: ${roles.join(', ')}',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(child: actionContent),
      ],
    );
  }
}
