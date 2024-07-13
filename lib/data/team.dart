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
  List<RoleModel> roles;

  Team({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.tags = const [],
    required this.roles,
  });

  Future<void> addMember(UserModel user,
      {required String roleId, required String approverId}) async {
    RoleModel? role = roles.firstWhere((role) => role.id == roleId,
        orElse: () => RoleModel(id: roleId, teamId: id, data: {}));

    bool approverIsRoleAdmin = await isRoleAdmin(role, approverId);
    if (!approverIsRoleAdmin) {
      throw Exception('Approver does not have the admin role permission.');
    }

    await _addUserRoleToFirestore(user.uid, roleId);
  }

  Future<void> _addUserRoleToFirestore(String userId, String roleId) async {
    DocumentReference userRoleRef =
        FirebaseFirestore.instance.collection('userroles').doc();
    await userRoleRef.set({
      'userId': userId,
      'roleId': roleId,
      'teamId': id,
    });
  }

  Future<void> saveToFirestore(String creatorId) async {
    await _checkIfTeamExists();

    _initializeDefaultRoles(creatorId);

    await _saveTeamToFirestore();

    await _addRoleAdmin(creatorId, 'admins');
    await _addRoleAdmin(creatorId, 'members');

    await _createDefaultServices(creatorId);
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
    RoleModel? adminRole = roles.firstWhere((role) => role.id == 'admins',
        orElse: () => RoleModel(id: 'admins', teamId: id, data: {}));
    RoleModel? memberRole = roles.firstWhere((role) => role.id == 'members',
        orElse: () => RoleModel(id: 'members', teamId: id, data: {}));

    roles = [adminRole, memberRole];

    _addUserRoleToFirestore(creatorId, 'admins');
    _addUserRoleToFirestore(creatorId, 'members');
  }

  Future<void> _saveTeamToFirestore() async {
    await FirebaseFirestore.instance.collection('teams').doc(id).set({
      'id': id,
      'name': name,
      'description': description,
      'tags': tags,
      'roles': roles.map((role) => role.toMap()).toList(),
      'createdAt': createdAt,
    });
  }

  Future<void> _createDefaultServices(String creatorId) async {
    MyTeamService myTeamService = MyTeamService(
      ownerTeamId: id,
      creatorId: creatorId,
      description: 'Default service for team management',
    );
    await myTeamService.saveToFirestore();
    await _assignServicePermissions(myTeamService);

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
    await addRolePermissions(
      teamId: id,
      roleId: 'admins',
      serviceId: service.getServiceId(),
      permissionId: 'serviceadmins',
      approverId: service.creatorId,
      status: {'permissionRole': true},
    );

    await addRolePermissions(
      teamId: id,
      roleId: 'members',
      serviceId: service.getServiceId(),
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

  Future<void> addRoleAdmin(
      String adminId, String userId, String roleId) async {
    RoleModel roleModel = roles.firstWhere((role) => role.id == roleId,
        orElse: () => RoleModel(id: roleId, teamId: id, data: {}));

    bool isAdmin = await isRoleAdmin(roleModel, adminId);
    if (!isAdmin) {
      throw Exception('Only a role admin can add another admin.');
    }

    await _addRoleAdmin(userId, roleId);
  }

  Future<void> removeRoleAdmin(
      String adminId, String userId, String roleId) async {
    RoleModel roleModel = roles.firstWhere((role) => role.id == roleId,
        orElse: () => RoleModel(id: roleId, teamId: id, data: {}));

    bool isAdmin = await isRoleAdmin(roleModel, adminId);
    if (!isAdmin) {
      throw Exception('Only a role admin can remove another admin.');
    }

    await _removeRoleAdmin(userId, roleId);
  }

  Future<List<RoleModel>> getAllRoles() async {
    return roles;
  }

  Future<List<RoleModel>> getUserRoles(String userId) async {
    QuerySnapshot userRolesSnapshot = await FirebaseFirestore.instance
        .collection('userroles')
        .where('userId', isEqualTo: userId)
        .where('teamId', isEqualTo: id)
        .get();

    List<RoleModel> userRoles = [];

    for (var doc in userRolesSnapshot.docs) {
      String roleId = doc['roleId'];
      RoleModel? role = roles.firstWhere((role) => role.id == roleId);
      userRoles.add(role);
    }

    return userRoles;
  }

  @override
  String toString() {
    return 'Team: $name, ID: $id, Description: $description, Created At: $createdAt, Tags: $tags, Roles: ${roles.map((role) => role.name).join(', ')}';
  }

  static Future<Team> getTeamData(String teamId) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
    if (!docSnapshot.exists) {
      throw Exception('Team does not exist');
    }

    var data = docSnapshot.data()!;
    var rolesData = data['roles'] ?? [];

    return Team(
      id: teamId,
      name: data['name'] ?? 'Unknown Team',
      description: data['description'] ?? 'No description available',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      tags: data['tags']?.cast<String>() ?? [],
      roles: List<RoleModel>.from(
          rolesData.map((roleData) => RoleModel.fromMap(roleData))),
    );
  }

  static Future<Map<String, List<UserModel>>> getTeamRoles(
      List<RoleModel> roles) async {
    Map<String, List<UserModel>> rolesWithUsers = {};

    for (var role in roles) {
      QuerySnapshot userRolesSnapshot = await FirebaseFirestore.instance
          .collection('userroles')
          .where('roleId', isEqualTo: role.id)
          .where('teamId', isEqualTo: role.teamId)
          .get();

      List<UserModel> users =
          await Future.wait(userRolesSnapshot.docs.map((doc) async {
        String uid = doc['userId'];
        UserModel user = await UserDatabaseService(uid: uid).getUserData();
        print("User fetched for role ${role.name}: ${user.email}");
        return user;
      }));

      rolesWithUsers[role.id] = users;
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
