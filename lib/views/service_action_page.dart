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
    String serviceId = service.getServiceId();
    final actionBuilder = ServiceActionsRegistry.getActionBuilder(serviceId, action.id);
    if (actionBuilder == null) {
      return Center(
        child: Text('Action not found: $serviceId/${action.id}'),
      );
    }
    final actionContent = actionBuilder(serviceId, action.id);

    String serviceName = service.name.length > 12 ? '${service.name.substring(0, 12)}...' : service.name;
    String rolesString = roles.join(', ').length > 12 ? '${roles.join(', ').substring(0, 12)}...' : roles.join(', ');

    String displayText = '$serviceName($rolesString)';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(), // This pushes the text to the right
            Tooltip(
              message: '${service.name}(${roles.join(', ')})',
              child: Text(
                displayText,
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
            ),
          ],
        ),
        toolbarHeight: 36.0, // Reduce the height of the AppBar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: actionContent),
        ],
      ),
    );
  }
}
