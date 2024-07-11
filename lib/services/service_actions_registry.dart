import 'package:flutter/material.dart';
import 'package:matchmatter/services/myteamservice/actions/managemyroles.dart';
import 'package:matchmatter/services/myteamservice/actions/manageteamroles.dart';
import 'package:matchmatter/views/service_action_component.dart';
import 'package:matchmatter/data/service.dart';

typedef ActionBuilderFunction = ServiceActionComponent Function(String serviceId, String actionId);

class ServiceActionsRegistry {
  static final Map<String, ActionBuilderFunction> _registry = {};

  static void registerAction(String serviceId, String actionId, ActionBuilderFunction builder) {
    _registry['$serviceId/$actionId'] = builder;
  }

  static ActionBuilderFunction? getActionBuilder(String serviceId, String actionId) {
    return _registry['$serviceId/$actionId'];
  }

  static void clearRegistry() {
    _registry.clear();
  }

  static Future<void> registerAllForService(String serviceId) async {
    clearRegistry(); // 清空之前的注册
    Service? service = await Service.getServiceData(serviceId);

    if (service == null) {
      print('Service not found for ID: $serviceId');
      return;
    }

    if (service.id == 'myteamservice') {
      registerAction(serviceId, 'managemyroles', (serviceId, actionId) => ManageMyRoles(serviceId: serviceId, actionId: actionId));
      registerAction(serviceId, 'manageteamroles', (serviceId, actionId) => ManageTeamRoles(serviceId: serviceId, actionId: actionId));
      // 注册更多 myteamservice 的动作
    }

    // 可以为其他 serviceId 添加更多的注册
  }
}
