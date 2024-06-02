import 'package:cloud_firestore/cloud_firestore.dart';

// Enum for the different scopes
enum AppOwnerScope {
  sole,
  any,
  approved,
}

enum AppUserScope {
  ownerteam,
  any,
  approved,
}

enum PermissionTeamScope {
  ownerteam,
  approvedteam,
  anyteam,
}

enum PermissionRoleScope {
  anyrole,
  approvedrole,
}

enum PermissionUserScope {
  none,
  anyuser,
  approveduser,
}

// Class for Action
class ActionModel {
  final String id;
  final String? name;
  final dynamic data;

  ActionModel({
    required this.id,
    this.name,
    this.data,
  });

  factory ActionModel.fromMap(Map<String, dynamic> data) {
    return ActionModel(
      id: data['id'],
      name: data['name'],
      data: data['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'data': data,
    };
  }
}

class ApproveModel {
  final String approverId;
  final Role approverRole;
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
      approverRole: Role.fromMap(data['approverRole']),
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
  required Role role,
  String? userId,
});

// Class for Permission
class Permission {
  final String id;
  final String? name;
  final String appId;
  final List<ActionModel>? actions;
  final PermissionTeamScope? teamScope;
  final PermissionRoleScope? roleScope;
  final PermissionUserScope? userScope;
  final dynamic data;

  Permission({
    required this.id,
    this.name,
    required this.appId,
    this.actions,
    this.teamScope,
    this.roleScope,
    this.userScope,
    required this.data,
  });

  factory Permission.fromMap(Map<String, dynamic> data) {
    return Permission(
      id: data['id'],
      name: data['name'],
      appId: data['appId'],
      actions: (data['actions'] as List<dynamic>).map((e) => ActionModel.fromMap(e)).toList(),
      teamScope: PermissionTeamScope.values.firstWhere((e) => e.toString() == 'PermissionTeamScope.${data['teamScope']}'),
      roleScope: PermissionRoleScope.values.firstWhere((e) => e.toString() == 'PermissionRoleScope.${data['roleScope']}'),
      userScope: data['userScope'] != null
          ? PermissionUserScope.values.firstWhere((e) => e.toString() == 'PermissionUserScope.${data['userScope']}')
          : null,
      data: data['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'appId': appId,
      'actions': actions?.map((e) => e.toMap()).toList(),
      'teamScope': teamScope.toString().split('.').last,
      'roleScope': roleScope.toString().split('.').last,
      'userScope': userScope?.toString().split('.').last,
      'data': data,
    };
  }
}

// Class for Role
class Role {
  final String id;
  final String? name;
  final String teamId;
  final String? creatorId;
  final dynamic data;

  Role({
    required this.id,
    this.name,
    required this.teamId,
    this.creatorId,
    required this.data,
  });

  factory Role.fromMap(Map<String, dynamic> data) {
    return Role(
      id: data['id'],
      name: data['name'],
      teamId: data['teamId'],
      creatorId: data['creatorId'],
      data: data['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teamId': teamId,
      'creatorId': creatorId,
      'data': data,
    };
  }
}

// Class for Owner Team
class OwnerTeamModel {
  final String id;
  final dynamic data;

  OwnerTeamModel({
    required this.id,
    required this.data,
  });

  factory OwnerTeamModel.fromMap(Map<String, dynamic> data) {
    return OwnerTeamModel(
      id: data['id'],
      data: data['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
    };
  }
}

// Class for App Model
class AppModel {
  final String id;
  final String name;
  final AppOwnerScope appownerscope;
  final AppUserScope appuserscope;
  final dynamic scopeData;
  final OwnerTeamModel ownerTeam;
  final List<Permission> permissions;
  final String creator;
  final Timestamp createdAt;

  AppModel({
    required this.id,
    required this.name,
    required this.appownerscope,
    required this.appuserscope,
    required this.scopeData,
    required this.ownerTeam,
    required this.permissions,
    required this.creator,
    required this.createdAt,
  });

  factory AppModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return AppModel(
      id: data['id'],
      name: data['name'],
      appownerscope: AppOwnerScope.values.firstWhere((e) => e.toString() == 'AppOwnerScope.${data['appownerscope']}'),
      appuserscope: AppUserScope.values.firstWhere((e) => e.toString() == 'AppUserScope.${data['appuserscope']}'),
      scopeData: data['scopeData'],
      ownerTeam: OwnerTeamModel.fromMap(data['ownerTeam']),
      permissions: (data['permissions'] as List<dynamic>).map((e) => Permission.fromMap(e)).toList(),
      creator: data['creator'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'appownerscope': appownerscope.toString().split('.').last,
      'appuserscope': appuserscope.toString().split('.').last,
      'scopeData': scopeData,
      'ownerTeam': ownerTeam.toMap(),
      'permissions': permissions.map((e) => e.toMap()).toList(),
      'creator': creator,
      'createdAt': createdAt,
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

  static Future<AppModel> createOrGet({
    required String id,
    required String name,
    required AppOwnerScope appOwnerScope,
    required AppUserScope appUserScope,
    required dynamic scopeData,
    required OwnerTeamModel ownerTeam,
    required String creator,
  }) async {
    if (appOwnerScope == AppOwnerScope.sole) {
      // Check if an app with the given ID already exists
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('apps').doc(id).get();
      
      if (doc.exists) {
        throw Exception('An app with the given ID already exists.');
      }
    } else {
      // Check if an app with the given ID and ownerTeam ID already exists
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('apps')
          .where('id', isEqualTo: id)
          .where('ownerTeam.id', isEqualTo: ownerTeam.id)
          .get();

      if (query.docs.isNotEmpty) {
        // If the app exists, return the existing AppModel
        DocumentSnapshot doc = query.docs.first;
        return AppModel.fromFirestore(doc);
      }
    }

    // If the app does not exist, create a new AppModel instance
    AppModel app = AppModel(
      id: id,
      name: name,
      appownerscope: appOwnerScope,
      appuserscope: appUserScope,
      scopeData: scopeData,
      ownerTeam: ownerTeam,
      permissions: [], // Initialize with an empty list of permissions
      creator: creator,
      createdAt: Timestamp.now(),
    );

    // Save the new app to Firestore
    await app.saveToFirestore();

    // Add default permissions to the newly created app
    await addDefaultPermissions(app);

    // Return the newly created AppModel
    return app;
  }
}

// Function to add default permissions to an app
Future<void> addDefaultPermissions(AppModel app) async {
  app.permissions.addAll([
    Permission(
      id: 'appadmins',
      name: 'App Admins',
      appId: app.id,
      actions: [],
      teamScope: PermissionTeamScope.ownerteam,
      roleScope: PermissionRoleScope.approvedrole,
      userScope: PermissionUserScope.none,
      data: {},
    ),
    Permission(
      id: 'appusers',
      name: 'App Users',
      appId: app.id,
      actions: [],
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
  Role role,
  ApproveCallback approveCallback,
) async {
  final appDoc = FirebaseFirestore.instance.collection('apps').doc(permission.appId);
  final appSnapshot = await appDoc.get();

  if (!appSnapshot.exists) {
    print('App with ID ${permission.appId} does not exist.');
    return;
  }

  final appData = appSnapshot.data() as Map<String, dynamic>;

  // Check appUserScope and permission's teamScope
  final appUserScope = AppUserScope.values.firstWhere((e) => e.toString() == 'AppUserScope.${appData['appuserscope']}');
  final permissionTeamScope = permission.teamScope;
  final permissionRoleScope = permission.roleScope;
  final permissionUserScope = permission.userScope;

  // Call approveCallback function
  ApproveModel approveModel = await approveCallback(
    permission: permission,
    role: role,
  );

  // Perform checks
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

  bool permissionExists = permissionsList.any((perm) => perm['permissionName'] == permission.name && perm['roleName'] == role.name);

  if (!permissionExists) {
    permissionsList.add({
      'permissionName': permission.name,
      'roleName': role.name,
      'approverId': approveModel.approverId,
      'approverRoleTeamId': approveModel.approverRole.teamId,
      'approverRoleName': approveModel.approverRole.name,
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
  Role userRole,
  String userId,
  ApproveCallback approveCallback,
) async {
  final appDoc = FirebaseFirestore.instance.collection('apps').doc(permission.appId);
  final appSnapshot = await appDoc.get();

  if (!appSnapshot.exists) {
    print('App with ID ${permission.appId} does not exist.');
    return;
  }

  final appData = appSnapshot.data() as Map<String, dynamic>;

  // Call approveCallback function
  ApproveModel approveModel = await approveCallback(
    permission: permission,
    role: userRole,
    userId: userId,
  );

  // Check if userRole and approverRole match
  if (userRole.teamId != approveModel.approverRole.teamId || userRole.name != approveModel.approverRole.name) {
    print('User role and approver role must be the same.');
    return;
  }

  // Check appUserScope and permission's teamScope
  final appUserScope = AppUserScope.values.firstWhere((e) => e.toString() == 'AppUserScope.${appData['appuserscope']}');
  final permissionTeamScope = permission.teamScope;
  final permissionRoleScope = permission.roleScope;
  final permissionUserScope = permission.userScope;

  // Perform checks
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

  final userPermissionsDoc = FirebaseFirestore.instance.collection('userPermissions').doc(userId);
  final userPermissionsSnapshot = await userPermissionsDoc.get();

  Map<String, dynamic> userPermissions = {};
  if (userPermissionsSnapshot.exists) {
    userPermissions = Map<String, dynamic>.from(userPermissionsSnapshot.data()!);
  }

  if (!userPermissions.containsKey(permission.appId)) {
    userPermissions[permission.appId] = [];
  }
  List<Map<String, dynamic>> permissionsList = List<Map<String, dynamic>>.from(userPermissions[permission.appId]);

  bool permissionExists = permissionsList.any((perm) => perm['permissionName'] == permission.name);

  if (!permissionExists) {
    permissionsList.add({
      'permissionName': permission.name,
      'userRoleTeamId': userRole.teamId,
      'userRoleName': userRole.name,
      'approverId': approveModel.approverId,
      'approverRoleTeamId': approveModel.approverRole.teamId,
      'approverRoleName': approveModel.approverRole.name,
      'status': approveModel.status.toMap(),
      'joinedAt': Timestamp.now(),
    });
    userPermissions[permission.appId] = permissionsList;
  }

  await userPermissionsDoc.set(userPermissions);
}
