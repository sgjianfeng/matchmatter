import 'package:cloud_firestore/cloud_firestore.dart';
import 'team.dart'; // Assuming RoleModel is in team.dart

// Enums for different scopes
enum AppOwnerScope { sole, any, approved }
enum AppUserScope { ownerteam, any, approved }
enum PermissionTeamScope { ownerteam, approvedteam, anyteam }
enum PermissionRoleScope { anyrole, approvedrole }
enum PermissionUserScope { none, anyuser, approveduser }

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
  bool permissionUser;

  Status({
    this.ownApp = false,
    this.useApp = false,
    this.permissionTeam = false,
    this.permissionRole = false,
    this.permissionUser = false,
  });

  factory Status.fromMap(Map<String, dynamic> data) {
    return Status(
      ownApp: data['ownApp'] ?? false,
      useApp: data['useApp'] ?? false,
      permissionTeam: data['permissionTeam'] ?? false,
      permissionRole: data['permissionRole'] ?? false,
      permissionUser: data['permissionUser'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownApp': ownApp,
      'useApp': useApp,
      'permissionTeam': permissionTeam,
      'permissionRole': permissionRole,
      'permissionUser': permissionUser,
    };
  }
}

typedef ApproveCallback = Future<ApproveModel> Function({
  required Permission permission,
  required RoleModel role,
  String? userId,
});

// Class for Permission
class Permission {
  final String id;
  final String appId;
  final PermissionTeamScope? teamScope;
  final PermissionRoleScope? roleScope;
  final PermissionUserScope? userScope;
  final dynamic data;
  String _name;

  Permission({
    required this.id,
    String? name,
    required this.appId,
    this.teamScope,
    this.roleScope,
    this.userScope,
    required this.data,
  }) : _name = name ?? id; // 如果 name 没有提供，默认设置为 id

  String get name => _name; // 获取 name

  factory Permission.fromMap(Map<String, dynamic> data) {
    return Permission(
      id: data['id'],
      name: data['name'],
      appId: data['appId'],
      teamScope: data['teamScope'] != null ? PermissionTeamScope.values.firstWhere((e) => e.toString() == 'PermissionTeamScope.${data['teamScope']}') : null,
      roleScope: data['roleScope'] != null ? PermissionRoleScope.values.firstWhere((e) => e.toString() == 'PermissionRoleScope.${data['roleScope']}') : null,
      userScope: data['userScope'] != null ? PermissionUserScope.values.firstWhere((e) => e.toString() == 'PermissionUserScope.${data['userScope']}') : null,
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
      'userScope': userScope?.toString().split('.').last,
      'data': data,
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
  }) : createdAt = createdAt ?? Timestamp.now();

  factory AppModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return AppModel(
      id: data['id'],
      name: data['name'] ?? data['id'],
      appOwnerScope: AppOwnerScope.values.firstWhere((e) => e.toString() == 'AppOwnerScope.${data['appOwnerScope']}'),
      appUserScope: AppUserScope.values.firstWhere((e) => e.toString() == 'AppUserScope.${data['appUserScope']}'),
      scopeData: data['scopeData'],
      ownerTeamId: data['ownerTeamId'],
      permissions: (data['permissions'] as List<dynamic>).map((e) => Permission.fromMap(e as Map<String, dynamic>)).toList(),
      creator: data['creator'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      description: data['description'],
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
    };
  }

  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('apps').doc('$id-$ownerTeamId').set(toFirestore());
  }

  static Future<AppModel?> getAppData(String appId, String ownerTeamId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('apps').doc('$appId-$ownerTeamId').get();
    if (doc.exists) {
      return AppModel.fromFirestore(doc);
    }
    return null;
  }

  static Future<List<AppModel>> getAllApps() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('apps').get();
    return querySnapshot.docs.map((doc) => AppModel.fromFirestore(doc)).toList();
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
    // Check if creator has `myteamapp` app's `appadmins` permission, myteamapp is exclude
    if (id != 'myteamapp' && !(await hasAppAdminPermission(creator!, ownerTeamId, 'myteamapp'))) {
      throw Exception('Creator does not have required app admin permission in the owner team.');
    }

    if (appOwnerScope == AppOwnerScope.sole) {
      // Check if an app with sole ownership already exists
      QuerySnapshot existingSoleApps = await FirebaseFirestore.instance
        .collection('apps')
        .where('id', isEqualTo: id)
        .where('appOwnerScope', isEqualTo: 'sole')
        .get();

      if (existingSoleApps.docs.isNotEmpty) {
        throw Exception('App with sole ownership scope already exists.');
      }
    }

    // Check if the specific app-ownerTeam combination already exists
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('apps').doc('$id-$ownerTeamId').get();
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
  static Future<bool> hasAppAdminPermission(String userId, String teamId, String appId) async {
    DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    if (!teamSnapshot.exists) {
      return false;
    }

    Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;
    Map<String, List<dynamic>> roles = Map<String, List<dynamic>>.from(teamData['roles']);

    List<String> userRoles = [];
    roles.forEach((role, userIds) {
      if (userIds.contains(userId)) {
        userRoles.add(role);
      }
    });

    for (String role in userRoles) {
      DocumentSnapshot roleSnapshot = await FirebaseFirestore.instance.collection('rolePermissions').doc(teamId).get();
      if (roleSnapshot.exists) {
        Map<String, dynamic> rolePermissionsData = roleSnapshot.data() as Map<String, dynamic>;
        if (rolePermissionsData.containsKey(appId)) {
          List<dynamic> permissionsList = rolePermissionsData[appId];
          if (permissionsList.any((perm) => perm['permissionId'] == 'appadmins' && perm['roleId'] == role)) {
            return true;
          }
        }
      }
    }

    return false;
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
      userScope: PermissionUserScope.none,
      data: {},
    ),
    Permission(
      id: 'appusers',
      name: 'App Users',
      appId: app.id,
      teamScope: PermissionTeamScope.anyteam,
      roleScope: PermissionRoleScope.approvedrole,
      userScope: PermissionUserScope.none,
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
  final appDoc = FirebaseFirestore.instance.collection('apps').doc('${permission.appId}-${role.teamId}');
  final appSnapshot = await appDoc.get();

  if (!appSnapshot.exists) {
    print('App with ID ${permission.appId} does not exist.');
    return;
  }

  final appData = appSnapshot.data() as Map<String, dynamic>;

  final appUserScope = AppUserScope.values.firstWhere((e) => e.toString() == 'AppUserScope.${appData['appUserScope']}');
  final permissionTeamScope = permission.teamScope;
  final permissionRoleScope = permission.roleScope;
  final permissionUserScope = permission.userScope;

  ApproveModel approveModel = await approveCallback(
    permission: permission,
    role: role,
  );

  if (appUserScope == AppUserScope.approved && !approveModel.status.useApp) {
    print('UseApp status must be true to add this permission.');
    return;
  }

  if (permissionTeamScope == PermissionTeamScope.approvedteam && !approveModel.status.permissionTeam) {
    print('PermissionTeam status must be true to add this permission.');
    return;
  }

  if (permissionRoleScope == PermissionRoleScope.approvedrole && !approveModel.status.permissionRole) {
    print('PermissionRole status must be true to add this permission.');
    return;
  }

  if (permissionUserScope == PermissionUserScope.approveduser && !approveModel.status.permissionUser) {
    print('PermissionUser status must be true to add this permission.');
    return;
  }

  final rolePermissionsDoc = FirebaseFirestore.instance.collection('rolePermissions').doc(role.teamId);
  final rolePermissionsSnapshot = await rolePermissionsDoc.get();

  Map<String, dynamic> rolePermissions = {};
  if (rolePermissionsSnapshot.exists) {
    rolePermissions = Map<String, dynamic>.from(rolePermissionsSnapshot.data()!);
  }

  if (!rolePermissions.containsKey(permission.appId)) {
    rolePermissions[permission.appId] = [];
  }
  List<Map<String, dynamic>> permissionsList = List<Map<String, dynamic>>.from(rolePermissions[permission.appId]);

  bool permissionExists = permissionsList.any((perm) => perm['permissionId'] == permission.id && perm['roleId'] == role.id);

  if (!permissionExists) {
    permissionsList.add({
      'permissionId': permission.id,
      'roleId': role.id,
      'approverId': approveModel.approverId,
      'approverRoleTeamId': approveModel.approverRole.teamId,
      'approverRoleId': approveModel.approverRole.id,
      'status': approveModel.status.toMap(),
      'joinedAt': Timestamp.now(),
    });
    rolePermissions[permission.appId] = permissionsList;
  }

  await rolePermissionsDoc.set(rolePermissions);
}

// Function to add permission to a user
Future<void> addPermissionToUser(
  Permission permission,
  RoleModel userRole,
  String userId,
  ApproveCallback approveCallback,
) async {
  final appDoc = FirebaseFirestore.instance.collection('apps').doc('${permission.appId}-${userRole.teamId}');
  final appSnapshot = await appDoc.get();

  if (!appSnapshot.exists) {
    print('App with ID ${permission.appId} does not exist.');
    return;
  }

  final appData = appSnapshot.data() as Map<String, dynamic>;

  ApproveModel approveModel = await approveCallback(
    permission: permission,
    role: userRole,
    userId: userId,
  );

  if (userRole.teamId != approveModel.approverRole.teamId || userRole.id != approveModel.approverRole.id) {
    print('User role and approver role must be the same.');
    return;
  }

  final appUserScope = AppUserScope.values.firstWhere((e) => e.toString() == 'AppUserScope.${appData['appUserScope']}');
  final permissionTeamScope = permission.teamScope;
  final permissionRoleScope = permission.roleScope;
  final permissionUserScope = permission.userScope;

  if (appUserScope == AppUserScope.approved && !approveModel.status.useApp) {
    print('UseApp status must be true to add this permission.');
    return;
  }

  if (permissionTeamScope == PermissionTeamScope.approvedteam && !approveModel.status.permissionTeam) {
    print('PermissionTeam status must be true to add this permission.');
    return;
  }

  if (permissionRoleScope == PermissionRoleScope.approvedrole && !approveModel.status.permissionRole) {
    print('PermissionRole status must be true to add this permission.');
    return;
  }

  if (permissionUserScope == PermissionUserScope.approveduser && !approveModel.status.permissionUser) {
    print('PermissionUser status must be true to add this permission。');
    return;
  }

  final userPermissionsDoc = FirebaseFirestore.instance.collection('userPermissions').doc(userId);
  final userPermissionsSnapshot = await userPermissionsDoc.get();

  Map<String, dynamic> userPermissions = {};
  if (userPermissionsSnapshot.exists) {
    userPermissions = Map<String, dynamic>.from(userPermissionsSnapshot.data()!);
  }

  if (!userPermissions.containsKey(userRole.teamId)) {
    userPermissions[userRole.teamId] = {};
  }
  if (!userPermissions[userRole.teamId].containsKey(userRole.id)) {
    userPermissions[userRole.teamId][userRole.id] = [];
  }

  List<Map<String, dynamic>> permissionsList = List<Map<String, dynamic>>.from(userPermissions[userRole.teamId][userRole.id]);

  bool permissionExists = permissionsList.any((perm) => perm['permissionId'] == permission.id);

  if (!permissionExists) {
    permissionsList.add({
      'permissionId': permission.id,
      'approverId': approveModel.approverId,
      'approverRoleTeamId': approveModel.approverRole.teamId,
      'approverRoleId': approveModel.approverRole.id,
      'status': approveModel.status.toMap(),
      'joinedAt': Timestamp.now(),
    });

    userPermissions[userRole.teamId][userRole.id] = permissionsList;
    await userPermissionsDoc.set(userPermissions);
  }
}


// Function to get user permissions in a team
Future<UserPermissionsResult> getUserPermissionsInTeam(String teamId, String userId) async {
  try {
    // Step 1: Get user roles in the team
    DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    if (!teamSnapshot.exists) {
      throw Exception('Team does not exist');
    }

    Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;
    Map<String, List<dynamic>> roles = Map<String, List<dynamic>>.from(teamData['roles']);

    List<String> userRoles = [];
    roles.forEach((role, userIds) {
      if (userIds.contains(userId)) {
        userRoles.add(role);
      }
    });

    // Debug: Print user roles
    print('User roles: $userRoles');

    // Step 2: Get permissions for each role
    List<RolePermissions> rolesPermissions = [];
    List<AppPermissions> appsPermissions = [];
    Set<String> appIds = {};

    DocumentSnapshot roleSnapshot = await FirebaseFirestore.instance.collection('rolePermissions').doc(teamId).get();
    if (roleSnapshot.exists) {
      Map<String, dynamic> rolePermissionsData = roleSnapshot.data() as Map<String, dynamic>;
      rolePermissionsData.forEach((appId, permissionsList) {
        if (permissionsList is List) {
          List<String> rolePermissions = [];
          for (var perm in permissionsList) {
            if (userRoles.contains(perm['roleId'])) {
              rolePermissions.add(perm['permissionId']);
              appIds.add(appId);
            }
          }
          rolesPermissions.add(RolePermissions(
            roleId: userRoles.join(','), // Assuming the permissions apply to the combination of roles
            roleName: userRoles.join(','),
            permissions: rolePermissions,
          ));
        }
      });
    }

    // Debug: Print roles permissions
    print('Roles permissions: $rolesPermissions');

    // Step 3: Get apps and aggregate permissions for each app
    for (String appId in appIds) {
      DocumentSnapshot appSnapshot = await FirebaseFirestore.instance.collection('apps').doc('$appId-$teamId').get();
      if (appSnapshot.exists) {
        Map<String, dynamic> appData = appSnapshot.data() as Map<String, dynamic>;
        String appName = appData['name'];
        List<String> appPermissions = [];

        for (var rolePerm in rolesPermissions) {
          if (rolePerm.permissions.contains(appId)) {
            appPermissions.addAll(rolePerm.permissions);
          }
        }

        appsPermissions.add(AppPermissions(
          appId: appId,
          appName: appName,
          permissions: appPermissions.toSet().toList(),
        ));
      }
    }

    // Debug: Print apps permissions
    print('Apps permissions: $appsPermissions');

    return UserPermissionsResult(
      appsPermissions: appsPermissions,
      rolesPermissions: rolesPermissions,
    );
  } catch (error) {
    print('Error fetching data: $error');
    rethrow;
  }
}

// Supporting classes for user permissions result
class UserPermissionsResult {
  final List<AppPermissions> appsPermissions;
  final List<RolePermissions> rolesPermissions;

  UserPermissionsResult({
    required this.appsPermissions,
    required this.rolesPermissions,
  });
}

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
  final String roleName;
  final List<String> permissions;

  RolePermissions({
    required this.roleId,
    required this.roleName,
    required this.permissions,
  });
}

