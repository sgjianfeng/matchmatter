/*
AppHub is an application that is automatically added to every team. Using AppHub, teams can register and publish their own applications, as well as use existing applications. AppHub includes three permissions: appadmins, appmembers, and appuseadmins.

- appadmins: This permission is for the app's management team and corresponds to the apphub members role. AppHub members will manage the app, including operations like approving, rejecting, suspending, and deleting apps, managing permissions, adding actions, and role-permission matching.
- appmembers: This permission is for using the app and is typically assigned to members. For AppHub, it doesn't have any specific actions for now.
- appuseadmins: This permission allows role admins to manage app usage, including adding app permissions to roles.

AppAdminScope and AppUseScope:
- AppAdminScope:
  - onlyOwnerTeam: The app is managed only by the owner team.
  - allowMultipleAdmin: The app can have multiple admin teams.

- AppUseScope:
  - onlyOwnerTeam: The app is used only by the owner team.
  - allowAllRole: The app can be added to any role for use.
*/

import 'package:cloud_firestore/cloud_firestore.dart';

enum AppAdminScope {
  onlyOwnerTeam,
  allowMultipleAdmin,
}

enum AppUseScope {
  onlyOwnerTeam,
  allowAllRole,
}

class AppModel {
  final String id;
  final String name;
  final String ownerTeam;
  final AppAdminScope appAdminScope;
  final AppUseScope appUseScope;
  final Map<String, List<String>> permissions;
  final Map<String, dynamic> meta;

  AppModel({
    required this.id,
    required this.name,
    required this.ownerTeam,
    required this.appAdminScope,
    required this.appUseScope,
    required this.permissions,
    required this.meta,
  });

  factory AppModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppModel(
      id: data['id'],
      name: data['name'],
      ownerTeam: data['ownerTeam'],
      appAdminScope: AppAdminScope.values.firstWhere((e) => e.toString() == 'AppAdminScope.${data['appAdminScope']}'),
      appUseScope: AppUseScope.values.firstWhere((e) => e.toString() == 'AppUseScope.${data['appUseScope']}'),
      permissions: Map<String, List<String>>.from(data['permissions']),
      meta: Map<String, dynamic>.from(data['meta']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'ownerTeam': ownerTeam,
      'appAdminScope': appAdminScope.toString().split('.').last,
      'appUseScope': appUseScope.toString().split('.').last,
      'permissions': permissions,
      'meta': meta,
    };
  }

  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('apps').doc(id).set(toFirestore());
  }

  static Future<AppModel?> getAppData(String appId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('apps').doc(appId).get();
    if (doc.exists) {
      return AppModel.fromFirestore(doc);
    }
    return null;
  }

  static Future<List<AppModel>> getAllApps() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('apps').get();
    return querySnapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
  }

  Future<void> addRoleToApp(String roleId, List<String> actions) async {
    if (!permissions.containsKey(roleId)) {
      permissions[roleId] = [];
    }
    permissions[roleId]?.addAll(actions);
    await saveToFirestore();
  }

  static Future<void> addDefaultPermissions(AppModel app) async {
    app.permissions['appadmins'] = ['approve_app', 'reject_app', 'suspend_app', 'delete_app'];
    app.permissions['appmembers'] = ['use_app_functionality'];
    await app.saveToFirestore();
  }
}
