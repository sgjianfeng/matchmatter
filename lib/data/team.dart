import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/service.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/services/matchmatterservice/matchmatterservice.dart';
import 'package:matchmatter/services/myteamservice/myteamservice.dart';

// Class for RoleModel
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
  }) : _name = name ?? id;

  String get name => _name;

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

// Class for Team
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

  Future<void> addMember(UserModel user, {required String role, required String approverId}) async {
    roles.putIfAbsent(role, () => []);
    if (!roles[role]!.contains(user.uid)) {
      RoleModel roleModel = RoleModel(
        id: role,
        name: role,
        teamId: id,
        creatorId: approverId,
        data: {},
      );

      bool approverIsRoleAdmin = await isRoleAdmin(roleModel, approverId);
      if (!approverIsRoleAdmin) {
        throw Exception('Approver does not have the admin role permission.');
      }
      roles[role]!.add(user.uid);
    }

    await _updateRolesInFirestore();
  }

  Future<void> _updateRolesInFirestore() async {
    DocumentReference teamRef = FirebaseFirestore.instance.collection('teams').doc(id);
    await teamRef.update({'roles': roles});
  }

  Future<void> saveToFirestore(String creatorId) async {
    _ensureUniqueUsersInRoles();
    await _checkIfTeamExists();

    _initializeDefaultRoles(creatorId);

    await _saveTeamToFirestore();

    await _addRoleAdmin(creatorId, 'admins');
    await _addRoleAdmin(creatorId, 'members');

    await _createDefaultServices(creatorId);
  }

  void _ensureUniqueUsersInRoles() {
    roles.forEach((role, userIds) {
      roles[role] = userIds.toSet().toList();
    });
  }

  Future<void> _checkIfTeamExists() async {
    final DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').doc(id).get();
    if (teamSnapshot.exists) {
      print('Team with ID $id already exists.');
      return;
    }
  }

  void _initializeDefaultRoles(String creatorId) {
    roles['admins'] = roles['admins'] ?? [];
    roles['members'] = roles['members'] ?? [];
    if (!roles['admins']!.contains(creatorId)) roles['admins']!.add(creatorId);
    if (!roles['members']!.contains(creatorId)) {
      roles['members']!.add(creatorId);
    }
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

  Future<void> _createDefaultServices(String creatorId) async {
    // 创建 MyTeamService
    MyTeamService myTeamService = MyTeamService(
      ownerTeamId: id,
      creatorId: creatorId,
      description: 'Default service for team management',
    );
    await myTeamService.saveToFirestore();
    await _assignServicePermissions(myTeamService);

    // 如果 teamId 是 matchmatterteam，则创建 MatchMatterService
    if (id == 'matchmatterteam') {
      MatchMatterService matchMatterService = MatchMatterService(
        ownerTeamId: id,
        creatorId: creatorId,
        description: 'Default service for MatchMatter team',
      );
      await matchMatterService.saveToFirestore();
      await _assignServicePermissions(matchMatterService);
    }
  }

  Future<void> _assignServicePermissions(Service service) async {
    // Assign serviceadmins permission to admins role
    await addRolePermissions(
      teamId: id,
      roleId: 'admins',
      serviceId: service.getServiceId(), // 使用 combinedId
      permissionId: 'serviceadmins',
      approverId: service.creatorId,
      status: {'permissionRole': true},
    );

    // Assign serviceusers permission to members role
    await addRolePermissions(
      teamId: id,
      roleId: 'members',
      serviceId: service.getServiceId(), // 使用 combinedId
      permissionId: 'serviceusers',
      approverId: service.creatorId,
      status: {'permissionRole': true},
    );
  }

  Future<void> _addRoleAdmin(String userId, String roleId) async {
    await FirebaseFirestore.instance.collection('roleadmins').add({
      'roleId': roleId,
      'teamId': id,
      'adminId': userId,
    });
  }

  Future<void> _removeRoleAdmin(String userId, String roleId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('roleadmins')
        .where('roleId', isEqualTo: roleId)
        .where('teamId', isEqualTo: id)
        .where('adminId', isEqualTo: userId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> addRoleAdmin(String adminId, String userId, String roleId) async {
    RoleModel roleModel = RoleModel(
      id: roleId,
      name: roleId,
      teamId: id,
      creatorId: adminId,
      data: {},
    );

    bool isAdmin = await isRoleAdmin(roleModel, adminId);
    if (!isAdmin) {
      throw Exception('Only a role admin can add another admin.');
    }

    await _addRoleAdmin(userId, roleId);
  }

  Future<void> removeRoleAdmin(String adminId, String userId, String roleId) async {
    RoleModel roleModel = RoleModel(
      id: roleId,
      name: roleId,
      teamId: id,
      creatorId: adminId,
      data: {},
    );

    bool isAdmin = await isRoleAdmin(roleModel, adminId);
    if (!isAdmin) {
      throw Exception('Only a role admin can remove another admin.');
    }

    await _removeRoleAdmin(userId, roleId);
  }

  Future<List<RoleModel>> getAllRoles() async {
    List<RoleModel> allRoles = [];

    for (String roleId in roles.keys) {
      DocumentSnapshot roleSnapshot = await FirebaseFirestore.instance.collection('roles').doc(roleId).get();

      if (roleSnapshot.exists) {
        Map<String, dynamic> roleData = roleSnapshot.data() as Map<String, dynamic>;
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
        DocumentSnapshot roleSnapshot = await FirebaseFirestore.instance.collection('roles').doc(roleId).get();

        if (roleSnapshot.exists) {
          Map<String, dynamic> roleData = roleSnapshot.data() as Map<String, dynamic>;
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
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
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
      roles: rolesData.map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }

  static Future<Map<String, List<UserModel>>> getTeamRoles(Map<String, List<String>> roles) async {
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

  Future<bool> isRoleAdmin(RoleModel roleModel, String userId) async {
    final roleAdminSnapshot = await FirebaseFirestore.instance
        .collection('roleadmins')
        .where('roleId', isEqualTo: roleModel.id)
        .where('teamId', isEqualTo: roleModel.teamId)
        .where('adminId', isEqualTo: userId)
        .get();

    return roleAdminSnapshot.docs.isNotEmpty;
  }
}
