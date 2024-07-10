import 'package:flutter/material.dart';

class ServiceActionComponent extends StatelessWidget {
  final String serviceId;
  final String actionName;

  ServiceActionComponent({required this.serviceId, required this.actionName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('This is the base action for $serviceId/$actionName.'),
    );
  }
}
