import 'package:cloud_firestore/cloud_firestore.dart';
import 'team.dart'; // Assuming RoleModel is in team.dart

// Enums for different scopes
enum AppOwnerScope { sole, any, approved }
enum AppUserScope { ownerteam, any, approved }
enum PermissionTeamScope { ownerteam, approvedteam, anyteam }
enum PermissionRoleScope { anyrole, approvedrole }

// Class for ApproveModel
class ApproveModel {
  final String approverId;
  final RoleModel approverRole;
  final Status status;
  final dynamic data;

  ApproveModel({
    required this.approverId,
    required this.approverRole,
    required this.status,
    this.data,
  });

  factory ApproveModel.fromMap(Map<String, dynamic> data) {
    return ApproveModel(
      approverId: data['approverId'],
      approverRole: RoleModel.fromMap(data['approverRole']),
      status: Status.fromMap(data['status']),
      data: data['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'approverId': approverId,
      'approverRole': approverRole.toMap(),
      'status': status.toMap(),
      'data': data,
    };
  }
}

// Class for Status
class Status {
  bool ownApp;
  bool useApp;
  bool permissionTeam;
  bool permissionRole;

  Status({
    this.ownApp = false,
    this.useApp = false,
    this.permissionTeam = false,
    this.permissionRole = false,
  });

  factory Status.fromMap(Map<String, dynamic> data) {
    return Status(
      ownApp: data['ownApp'] ?? false,
      useApp: data['useApp'] ?? false,
      permissionTeam: data['permissionTeam'] ?? false,
      permissionRole: data['permissionRole'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownApp': ownApp,
      'useApp': useApp,
      'permissionTeam': permissionTeam,
      'permissionRole': permissionRole,
    };
  }
}

typedef ApproveCallback = Future<ApproveModel> Function({
  required Permission permission,
  required RoleModel role,
});

// Class for Permission
class Permission {
  final String id;
  final String appId;
  final PermissionTeamScope? teamScope;
  final PermissionRoleScope? roleScope;
  final dynamic data;
  String _name;

  Permission({
    required this.id,
    String? name,
    required this.appId,
    this.teamScope,
    this.roleScope,
    required this.data,
  }) : _name = name ?? id; // 如果 name 没有提供，默认设置为 id

  String get name => _name; // 获取 name

  factory Permission.fromMap(Map<String, dynamic> data) {
    return Permission(
      id: data['id'],
      name: data['name'],
      appId: data['appId'],
      teamScope: data['teamScope'] != null
          ? PermissionTeamScope.values.firstWhere(
              (e) => e.toString() == 'PermissionTeamScope.${data['teamScope']}')
          : null,
      roleScope: data['roleScope'] != null
          ? PermissionRoleScope.values.firstWhere(
              (e) => e.toString() == 'PermissionRoleScope.${data['roleScope']}')
          : null,
      data: data['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': _name,
      'appId': appId,
      'teamScope': teamScope?.toString().split('.').last,
      'roleScope': roleScope?.toString().split('.').last,
      'data': data,
    };
  }
}

// Class for AppWidget
class AppWidget {
  final String name;
  final String title;
  final List<String> permissions;
  final String description;

  AppWidget({
    required this.name,
    required this.title,
    required this.permissions,
    required this.description,
  });

  factory AppWidget.fromMap(Map<String, dynamic> data) {
    return AppWidget(
      name: data['name'],
      title: data['title'],
      permissions: List<String>.from(data['permissions']),
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'permissions': permissions,
      'description': description,
    };
  }
}

// Class for App Model
class AppModel {
  final String id;
  final String name;
  final AppOwnerScope appOwnerScope;
  final AppUserScope appUserScope;
  final dynamic scopeData;
  final String ownerTeamId;
  final List<Permission> permissions;
  final String? creator;
  final Timestamp createdAt;
  final String? description;
  List<AppWidget> appWidgetList; // 新增的属性

  AppModel({
    required this.id,
    required this.name,
    this.appOwnerScope = AppOwnerScope.sole,
    this.appUserScope = AppUserScope.ownerteam,
    this.scopeData,
    required this.ownerTeamId,
    required this.permissions,
    this.creator,
    Timestamp? createdAt,
    this.description,
    this.appWidgetList = const [], // 初始化为空列表
  }) : createdAt = createdAt ?? Timestamp.now();

  factory AppModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return AppModel(
      id: data['id'],
      name: data['name'] ?? data['id'],
      appOwnerScope: AppOwnerScope.values.firstWhere(
          (e) => e.toString() == 'AppOwnerScope.${data['appOwnerScope']}'),
      appUserScope: AppUserScope.values.firstWhere(
          (e) => e.toString() == 'AppUserScope.${data['appUserScope']}'),
      scopeData: data['scopeData'],
      ownerTeamId: data['ownerTeamId'],
      permissions: (data['permissions'] as List<dynamic>)
          .map((e) => Permission.fromMap(e as Map<String, dynamic>))
          .toList(),
      creator: data['creator'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      description: data['description'],
      appWidgetList: (data['appWidgetList'] as List<dynamic>?)
              ?.map((e) => AppWidget.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'appOwnerScope': appOwnerScope.toString().split('.').last,
      'appUserScope': appUserScope.toString().split('.').last,
      'scopeData': scopeData,
      'ownerTeamId': ownerTeamId,
      'permissions': permissions.map((e) => e.toMap()).toList(),
      'creator': creator,
      'createdAt': createdAt,
      'description': description,
      'appWidgetList': appWidgetList.map((e) => e.toMap()).toList(),
    };
  }

  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance
        .collection('apps')
        .doc('$id-$ownerTeamId')
        .set(toFirestore());
  }

  static Future<AppModel?> getAppData(String appId, String ownerTeamId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('apps')
        .doc('$appId-$ownerTeamId')
        .get();
    if (doc.exists) {
      return AppModel.fromFirestore(doc);
    }
    return null;
  }

  static Future<List<AppModel>> getAllApps() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('apps').get();
    return querySnapshot.docs
        .map((doc) => AppModel.fromFirestore(doc))
        .toList();
  }

  static Future<AppModel> createOrGet({
    required String id,
    String? name,
    String? description,
    AppOwnerScope appOwnerScope = AppOwnerScope.sole,
    AppUserScope appUserScope = AppUserScope.ownerteam,
    dynamic scopeData,
    required String ownerTeamId,
    String? creator,
  }) async {
    // Check if creator has `myteamapp` app's `appadmins` permission, myteamapp is excluded
    if (id != 'myteamapp' &&
        !(await hasAppAdminPermission(creator!, ownerTeamId, 'myteamapp'))) {
      throw Exception(
          'Creator does not have required app admin permission in the owner team。');
    }

    if (appOwnerScope == AppOwnerScope.sole) {
      // Check if an app with sole ownership already exists
      QuerySnapshot existingSoleApps = await FirebaseFirestore.instance
          .collection('apps')
          .where('id', isEqualTo: id)
          .where('appOwnerScope', isEqualTo: 'sole')
          .get();

      if (existingSoleApps.docs.isNotEmpty) {
        throw Exception('App with sole ownership scope already exists。');
      }
    }

    // Check if the specific app-ownerTeam combination already exists
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('apps')
        .doc('$id-$ownerTeamId')
        .get();
    if (doc.exists) {
      return AppModel.fromFirestore(doc);
    }

    AppModel app = AppModel(
      id: id,
      name: name ?? id,
      appOwnerScope: appOwnerScope,
      appUserScope: appUserScope,
      scopeData: scopeData,
      ownerTeamId: ownerTeamId,
      creator: creator,
      description: description,
      permissions: [],
    );

    await app.saveToFirestore();
    await addDefaultPermissions(app);
    return app;
  }

  // Helper method to check if a user has the specified app's appadmins permission in a team
  static Future<bool> hasAppAdminPermission(
      String userId, String teamId, String appId) async {
    DocumentSnapshot teamSnapshot =
        await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    if (!teamSnapshot.exists) {
      return false;
    }

    Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;
    Map<String, List<dynamic>> roles =
        Map<String, List<dynamic>>.from(teamData['roles']);

    List<String> userRoles = [];
    roles.forEach((role, userIds) {
      if (userIds.contains(userId)) {
        userRoles.add(role);
      }
    });

    for (String role in userRoles) {
      QuerySnapshot rolePermissionsSnapshot = await FirebaseFirestore.instance
          .collection('rolePermissions')
          .where('teamId', isEqualTo: teamId)
          .where('roleId', isEqualTo: role)
          .where('appId', isEqualTo: appId)
          .where('permissionId', isEqualTo: 'appadmins')
          .get();
      if (rolePermissionsSnapshot.docs.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  // Method for returning widget definitions
  List<AppWidget> getAppWidgetList() {
    return appWidgetList;
  }

  // Methods to manage app widgets
  void addWidget(AppWidget widget) {
    appWidgetList.add(widget);
    saveToFirestore();
  }

  void removeWidget(String widgetName) {
    appWidgetList.removeWhere((widget) => widget.name == widgetName);
    saveToFirestore();
  }

  void updateWidget(AppWidget updatedWidget) {
    int index = appWidgetList.indexWhere((widget) => widget.name == updatedWidget.name);
    if (index != -1) {
      appWidgetList[index] = updatedWidget;
      saveToFirestore();
    }
  }
}

// Function to add default permissions to an app
Future<void> addDefaultPermissions(AppModel app) async {
  app.permissions.addAll([
    Permission(
      id: 'appadmins',
      name: 'App Admins',
      appId: app.id,
      teamScope: PermissionTeamScope.ownerteam,
      roleScope: PermissionRoleScope.approvedrole,
      data: {},
    ),
    Permission(
      id: 'appusers',
      name: 'App Users',
      appId: app.id,
      teamScope: PermissionTeamScope.anyteam,
      roleScope: PermissionRoleScope.approvedrole,
      data: {},
    ),
  ]);
  await app.saveToFirestore();
}

// Function to add permission to a role
Future<void> addPermissionToRole(
  Permission permission,
  RoleModel role,
  ApproveCallback approveCallback,
) async {
  final appDoc = FirebaseFirestore.instance
      .collection('apps')
      .doc('${permission.appId}-${role.teamId}');
  final appSnapshot = await appDoc.get();

  if (!appSnapshot.exists) {
    print('App with ID ${permission.appId} does not exist。');
    return;
  }

  final appData = appSnapshot.data() as Map<String, dynamic>;

  final appUserScope = AppUserScope.values.firstWhere(
      (e) => e.toString() == 'AppUserScope.${appData['appUserScope']}');
  final permissionTeamScope = permission.teamScope;
  final permissionRoleScope = permission.roleScope;

  ApproveModel approveModel = await approveCallback(
    permission: permission,
    role: role,
  );

  if (appUserScope == AppUserScope.approved && !approveModel.status.useApp) {
    print('UseApp status must be true to add this permission。');
    return;
  }

  if (permissionTeamScope == PermissionTeamScope.approvedteam &&
      !approveModel.status.permissionTeam) {
    print('PermissionTeam status must be true to add this permission。');
    return;
  }

  if (permissionRoleScope == PermissionRoleScope.approvedrole &&
      !approveModel.status.permissionRole) {
    print('PermissionRole status must be true to add this permission。');
    return;
  }

  final rolePermissionsDoc = FirebaseFirestore.instance
      .collection('rolePermissions')
      .doc('${role.teamId}-${role.id}-${permission.appId}-${permission.id}');
  final rolePermissionsSnapshot = await rolePermissionsDoc.get();

  Map<String, dynamic> rolePermissions = {};
  if (rolePermissionsSnapshot.exists) {
    rolePermissions =
        Map<String, dynamic>.from(rolePermissionsSnapshot.data()!);
  }

  rolePermissions = {
    'teamId': role.teamId,
    'appId': permission.appId,
    'roleId': role.id,
    'permissionId': permission.id,
    'approverId': approveModel.approverId,
    'approverRoleTeamId': approveModel.approverRole.teamId,
    'approverRoleId': approveModel.approverRole.id,
    'status': approveModel.status.toMap(),
    'joinedAt': Timestamp.now(),
  };

  await rolePermissionsDoc.set(rolePermissions);
}

// Function to get role permissions in a team
Future<List<RolePermissions>> getUserRolePermissions(
    String teamId, String userId) async {
  try {
    DocumentSnapshot teamSnapshot =
        await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    if (!teamSnapshot.exists) {
      throw Exception('Team does not exist');
    }

    Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;
    Map<String, List<dynamic>> roles =
        Map<String, List<dynamic>>.from(teamData['roles']);

    List<String> userRoles = [];
    roles.forEach((role, userIds) {
      if (userIds.contains(userId)) {
        userRoles.add(role);
      }
    });

    print('User roles: $userRoles');

    List<RolePermissions> rolesPermissions = [];

    QuerySnapshot rolePermissionsSnapshot = await FirebaseFirestore.instance
        .collection('rolePermissions')
        .where('teamId', isEqualTo: teamId)
        .get();
    if (rolePermissionsSnapshot.docs.isNotEmpty) {
      for (var doc in rolePermissionsSnapshot.docs) {
        if (userRoles.contains(doc['roleId'])) {
          rolesPermissions.add(RolePermissions(
            roleId: doc['roleId'],
            teamId: teamId,
            appId: doc['appId'],
            permissionId: doc['permissionId'],
          ));
        }
      }
    }

    print('Roles permissions: $rolesPermissions');
    return rolesPermissions;
  } catch (error) {
    print('Error fetching data: $error');
    rethrow;
  }
}

// Supporting classes for role permissions result
class AppPermissions {
  final String appId;
  final String appName;
  final List<String> permissions;

  AppPermissions({
    required this.appId,
    required this.appName,
    required this.permissions,
  });
}

class RolePermissions {
  final String roleId;
  final String teamId;
  final String appId;
  final String permissionId;

  RolePermissions({
    required this.roleId,
    required this.teamId,
    required this.appId,
    required this.permissionId,
  });

  factory RolePermissions.fromMap(Map<String, dynamic> data) {
    return RolePermissions(
      roleId: data['roleId'],
      teamId: data['teamId'],
      appId: data['appId'],
      permissionId: data['permissionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roleId': roleId,
      'teamId': teamId,
      'appId': appId,
      'permissionId': permissionId,
    };
  }
}