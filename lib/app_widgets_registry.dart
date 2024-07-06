import 'package:flutter/material.dart';
import 'package:matchmatter/apps/myteamapp/my_roles_widget.dart';
import 'package:matchmatter/views/app_widget_component.dart';

typedef WidgetBuilderFunction = AppWidgetComponent Function(String appId, String widgetName);

class AppWidgetsRegistry {
  static final Map<String, WidgetBuilderFunction> _registry = {};

  static void registerWidget(String appId, String widgetName, WidgetBuilderFunction builder) {
    _registry['$appId/$widgetName'] = builder;
  }

  static WidgetBuilderFunction? getWidgetBuilder(String appId, String widgetName) {
    return _registry['$appId/$widgetName'];
  }

  static void clearRegistry() {
    _registry.clear();
  }

  static void registerAllForApp(String appId) {
    clearRegistry(); // 清空之前的注册
    if (appId == 'myteamapp') {
      registerWidget(appId, 'myroles', (appId, widgetName) => MyRolesWidget(appId: appId, widgetName: widgetName));
      // 注册更多 myteamapp 的小部件
    }
    // 可以为其他 appId 添加更多的注册
  }
}
