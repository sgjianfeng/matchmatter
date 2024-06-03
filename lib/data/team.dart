import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/apps/myteamapp/my_team_app.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/user.dart';

class RoleModel {
  final String id;
  final String? description;
  final String teamId;
  final String? creatorId;
  final Map<String, dynamic> data;
  String _name;

  RoleModel({
    required this.id,
    String? name,
    this.description,
    required this.teamId,
    this.creatorId,
    required this.data,
  }) : _name = name ?? id; // 如果 name 没有提供，默认设置为 id

  String get name => _name; // 获取 name

  factory RoleModel.fromMap(Map<String, dynamic> data) {
    return RoleModel(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      teamId: data['teamId'],
      creatorId: data['creatorId'],
      data: data['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': _name,
      'description': description,
      'teamId': teamId,
      'creatorId': creatorId,
      'data': data,
    };
  }
}

class Team {
  final String id;
  final String name;
  final String? description;
  final Timestamp createdAt;
  List<String> tags;
  Map<String, List<String>> roles;

  Team({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.tags = const [],
    required this.roles,
  });

  Future<void> addMember(UserModel user,
      {required String role, required String approverId}) async {
    roles.putIfAbsent(role, () => []);
    if (!roles[role]!.contains(user.uid)) {
      RoleModel roleModel = RoleModel(
        id: role,
        name: role,
        teamId: id,
        creatorId: approverId,
        data: {},
      );

      bool approverHasAdminRole =
          await hasAdminRolePermission(roleModel, approverId);
      if (!approverHasAdminRole) {
        throw Exception('Approver does not have the admin role permission.');
      }
      roles[role]!.add(user.uid);
    }

    await _updateRolesInFirestore();
  }

  Future<void> _updateRolesInFirestore() async {
    DocumentReference teamRef =
        FirebaseFirestore.instance.collection('teams').doc(id);
    await teamRef.update({'roles': roles});
  }

  Future<void> saveToFirestore(String creatorId) async {
    _ensureUniqueUsersInRoles();
    await _checkIfTeamExists();

    _initializeDefaultRoles(creatorId);

    await _saveTeamToFirestore();

    MyTeamApp app = await MyTeamApp.createOrGet(
      creator: creatorId,
      ownerTeamId: id,
    );

    await _assignPermissions(app, creatorId);
  }

  void _ensureUniqueUsersInRoles() {
    roles.forEach((role, userIds) {
      roles[role] = userIds.toSet().toList();
    });
  }

  Future<void> _checkIfTeamExists() async {
    final DocumentSnapshot teamSnapshot =
        await FirebaseFirestore.instance.collection('teams').doc(id).get();
    if (teamSnapshot.exists) {
      print('Team with ID $id already exists.');
      return;
    }
  }

  void _initializeDefaultRoles(String creatorId) {
    roles['admins'] = roles['admins'] ?? [];
    roles['members'] = roles['members'] ?? [];
    if (!roles['admins']!.contains(creatorId)) roles['admins']!.add(creatorId);
    if (!roles['members']!.contains(creatorId))
      roles['members']!.add(creatorId);
  }

  Future<void> _saveTeamToFirestore() async {
    await FirebaseFirestore.instance.collection('teams').doc(id).set({
      'id': id,
      'name': name,
      'description': description,
      'tags': tags,
      'roles': roles,
      'createdAt': createdAt,
    });
  }

  Future<void> _assignPermissions(MyTeamApp app, String? creatorId) async {
    for (String role in roles.keys) {
      List<String> userIds = roles[role]!;
      if (userIds.isNotEmpty) {
        creatorId = creatorId ?? userIds.first;

        if (role == 'admins') {
          await _assignPermissionToRole(app, 'appadmins', role, creatorId);
        } else if (role == 'members') {
          await _assignPermissionToRole(app, 'appusers', role, creatorId);
        }

        // Create RoleModel for the current role
        RoleModel roleModel = RoleModel(
          id: role,
          name: role,
          teamId: id,
          creatorId: creatorId,
          data: {},
        );

        // Assign adminrole to the creator of each role
        await _assignPermissionToUser(app, 'adminrole', creatorId, roleModel);
      }
    }
  }

  Future<void> _assignPermissionToRole(MyTeamApp app, String permissionId,
      String roleName, String creatorId) async {
    Permission permission =
        app.permissions.firstWhere((perm) => perm.id == permissionId);

    RoleModel role = RoleModel(
      id: roleName,
      name: roleName,
      teamId: id,
      creatorId: creatorId,
      data: {},
    );

    await addPermissionToRole(
      permission,
      role,
      (
          {required Permission permission,
          required RoleModel role,
          String? userId}) async {
        return ApproveModel(
          approverId: creatorId,
          approverRole: role,
          status: Status(permissionRole: true),
          data: {},
        );
      },
    );
  }

  Future<void> _assignPermissionToUser(MyTeamApp app, String permissionId,
      String userId, RoleModel userRole) async {
    Permission permission =
        app.permissions.firstWhere((perm) => perm.id == permissionId);

    await addPermissionToUser(
      permission,
      userRole,
      userId,
      (
          {required Permission permission,
          required RoleModel role,
          String? userId}) async {
        return ApproveModel(
          approverId: userId ?? '',
          approverRole: userRole,
          status: Status(
            permissionUser: true,
          ),
          data: {},
        );
      },
    );
  }

  Future<List<RoleModel>> getAllRoles() async {
    List<RoleModel> allRoles = [];

    for (String roleId in roles.keys) {
      // 从 Firestore 获取 role 的详细信息
      DocumentSnapshot roleSnapshot = await FirebaseFirestore.instance
          .collection('roles')
          .doc(roleId)
          .get();

      if (roleSnapshot.exists) {
        Map<String, dynamic> roleData =
            roleSnapshot.data() as Map<String, dynamic>;
        // 确保 roleData 中有必要的字段
        roleData['id'] = roleId;
        roleData['name'] = roleData['name'] ?? roleId;
        roleData['description'] = roleData['description'] ?? '';
        RoleModel role = RoleModel.fromMap(roleData);
        allRoles.add(role);
      }
    }

    return allRoles;
  }

  Future<List<RoleModel>> getUserRoles(String userId) async {
    List<RoleModel> userRoles = [];

    for (String roleId in roles.keys) {
      if (roles[roleId]!.contains(userId)) {
        // 从 Firestore 获取 role 的详细信息
        DocumentSnapshot roleSnapshot = await FirebaseFirestore.instance
            .collection('roles')
            .doc(roleId)
            .get();

        if (roleSnapshot.exists) {
          Map<String, dynamic> roleData =
              roleSnapshot.data() as Map<String, dynamic>;
          // 确保 roleData 中有必要的字段
          roleData['id'] = roleId;
          roleData['name'] = roleData['name'] ?? roleId;
          roleData['description'] = roleData['description'] ?? '';
          RoleModel role = RoleModel.fromMap(roleData);
          userRoles.add(role);
        }
      }
    }

    return userRoles;
  }

  @override
  String toString() {
    return 'Team: $name, ID: $id, Description: $description, Created At: $createdAt, Tags: $tags, Roles: ${roles.keys.join(', ')}';
  }

  static Future<Team> getTeamData(String teamId) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    if (!docSnapshot.exists) {
      throw Exception('Team does not exist');
    }

    var data = docSnapshot.data()!;
    var rolesData = data['roles'] ?? {};

    return Team(
      id: teamId,
      name: data['name'] ?? 'Unknown Team',
      description: data['description'] ?? 'No description available',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      tags: data['tags']?.cast<String>() ?? [],
      roles: rolesData
          .map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }

  static Future<Map<String, List<UserModel>>> getTeamRoles(
      Map<String, List<String>> roles) async {
    Map<String, List<UserModel>> rolesWithUsers = {};

    for (var role in roles.entries) {
      List<UserModel> users = await Future.wait(role.value.map((uid) async {
        UserModel user = await UserDatabaseService(uid: uid).getUserData();
        print("User fetched for role ${role.key}: ${user.email}");
        return user;
      }));
      rolesWithUsers[role.key] = users;
    }

    return rolesWithUsers;
  }

  Future<bool> hasAdminRolePermission(
      RoleModel roleModel, String userId) async {
    if (!roles[roleModel.id]!.contains(userId)) {
      return false;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('userPermissions')
        .doc(userId)
        .get();
    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      var permissions = userData['permissions'] as Map<String, dynamic>?;
      if (permissions != null && permissions['myteamapp'] != null) {
        var appPermissions = permissions['myteamapp'] as List<dynamic>;
        return appPermissions.any((perm) =>
            perm['permissionId'] == 'adminrole' &&
            perm['teamId'] == id &&
            perm['roleId'] == roleModel.id &&
            perm['userId'] == userId);
      }
    }
    return false;
  }
}
