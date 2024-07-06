import 'package:flutter/material.dart';

class AppWidgetComponent extends StatelessWidget {
  final String appId;
  final String widgetName;

  AppWidgetComponent({required this.appId, required this.widgetName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('This is the base widget for $appId/$widgetName.'),
    );
  }
}
