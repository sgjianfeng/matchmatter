import 'package:flutter/material.dart';
import 'package:matchmatter/services/myteamservice/myrolesaction.dart';
import 'package:matchmatter/views/service_action_component.dart';

typedef ActionBuilderFunction = ServiceActionComponent Function(String serviceId, String actionName);

class ServiceActionsRegistry {
  static final Map<String, ActionBuilderFunction> _registry = {};

  static void registerAction(String serviceId, String actionName, ActionBuilderFunction builder) {
    _registry['$serviceId/$actionName'] = builder;
  }

  static ActionBuilderFunction? getActionBuilder(String serviceId, String actionName) {
    return _registry['$serviceId/$actionName'];
  }

  static void clearRegistry() {
    _registry.clear();
  }

  static void registerAllForService(String serviceId) {
    clearRegistry(); // 清空之前的注册
    if (serviceId == 'myteamservice') {
      registerAction(serviceId, 'myroles', (serviceId, actionName) => MyRolesAction(serviceId: serviceId, actionName: actionName));
      // 注册更多 myteamservice 的动作
    }
    // 可以为其他 serviceId 添加更多的注册
  }
}
