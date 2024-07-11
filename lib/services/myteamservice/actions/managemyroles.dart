import 'package:flutter/material.dart';
import 'package:matchmatter/views/service_action_component.dart';

class ManageMyRoles extends ServiceActionComponent {
  ManageMyRoles({required String serviceId, required String actionId}) : super(serviceId: serviceId, actionId: actionId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('This is the My Roles action for $serviceId.'),
      ),
    );
  }
}
