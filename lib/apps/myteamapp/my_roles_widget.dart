import 'package:flutter/material.dart';
import 'package:matchmatter/views/app_widget_component.dart';

class MyRolesWidget extends AppWidgetComponent {
  MyRolesWidget({required String appId, required String widgetName}) : super(appId: appId, widgetName: widgetName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('This is the My Roles widget for $appId.'),
      ),
    );
  }
}
