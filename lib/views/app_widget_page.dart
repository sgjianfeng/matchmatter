import 'package:flutter/material.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/app_widgets_registry.dart';

class AppWidgetPage extends StatelessWidget {
  final AppModel app;
  final AppWidget appWidget;
  final String teamId;
  final List<String> roles;

  AppWidgetPage({
    required this.app,
    required this.appWidget,
    required this.teamId,
    required this.roles,
  });

  @override
  Widget build(BuildContext context) {
    final widgetBuilder = AppWidgetsRegistry.getWidgetBuilder(app.id, appWidget.name);
    if (widgetBuilder == null) {
      return Center(
        child: Text('Widget not found: ${app.id}/${appWidget.name}'),
      );
    }
    final widgetContent = widgetBuilder(app.id, appWidget.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appWidget.title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              Text(
                '${app.name}\nRoles: ${roles.join(', ')}',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(child: widgetContent),
      ],
    );
  }
}
