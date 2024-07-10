import 'package:flutter/material.dart';
import 'package:matchmatter/views/service_action_component.dart';

class MyRolesAction extends ServiceActionComponent {
  MyRolesAction({required String serviceId, required String actionName}) : super(serviceId: serviceId, actionName: actionName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('This is the My Roles action for $serviceId.'),
      ),
    );
  }
}
