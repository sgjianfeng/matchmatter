import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/apps/apphub.dart';
import 'package:matchmatter/data/user.dart';
import 'app.dart'; // Import the AppModel

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

  Future<void> addMember(UserModel user, {String role = 'members', bool isAdmin = false}) async {
    if (!roles.containsKey(role)) {
      roles[role] = [];
    }

    // Check if user is already in the role
    if (!roles[role]!.contains(user.uid)) {
      roles[role]!.add(user.uid!);
    }

    if (isAdmin) {
      if (!roles.containsKey('admins')) {
        roles['admins'] = [];
      }
      if (!roles['admins']!.contains(user.uid)) {
        roles['admins']!.add(user.uid!);
      }
    }

    // Add to corresponding role admin role
    String roleAdmin = '${role}_radmin';
    if (!roles.containsKey(roleAdmin)) {
      roles[roleAdmin] = [];
    }
    if (!roles[roleAdmin]!.contains(user.uid)) {
      roles[roleAdmin]!.add(user.uid!);
    }

    await updateRolesInFirestore();
  }

  Future<void> updateRolesInFirestore() async {
    DocumentReference teamRef = FirebaseFirestore.instance.collection('teams').doc(id);
    await teamRef.update({
      'roles': roles,
    });
  }

  Future<void> saveToFirestore() async {
    // Ensure no duplicate users in roles
    roles.forEach((role, userIds) {
      roles[role] = userIds.toSet().toList();
    });

    print('Roles to save: $roles');

    await FirebaseFirestore.instance.collection('teams').doc(id).set({
      'id': id,
      'name': name,
      'description': description,
      'tags': tags,
      'roles': roles,
      'createdAt': createdAt,
    });
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
      roles: rolesData.map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }

  static Future<Map<String, List<UserModel>>> getTeamRoles(Map<String, List<String>> roles) async {
    Map<String, List<UserModel>> rolesWithUsers = {};

    for (var role in roles.entries) {
      List<UserModel> users = await Future.wait(role.value.map((uid) => UserDatabaseService(uid: uid).getUserData()));
      rolesWithUsers[role.key] = users;
    }

    return rolesWithUsers;
  }

  /*
  Initialize default teams: AppHub and MatchHub

  AppHub:
  - appadminscope: onlyOwnerTeam
  - appusescope: allowAllRole
  - members role matches appmodule's appadmins permission
  - admins and members roles match useappmembers permission

  MatchHub:
  - appadminscope: allowMultipleAdmin
  - appusescope: allowAllRole
  - members role matches appmodule's appadmins permission
  - admins and members roles match useappmembers permission
  */
  static Future<void> initializeDefaultTeams() async {
    final String adminEmail = 'admin@matchmatter.com';
    final QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: adminEmail)
        .get();

    if (adminSnapshot.docs.isEmpty) {
      print('Default admin user does not exist. Cannot create default teams.');
      return;
    }

    final UserModel adminUser = UserModel.fromDocumentSnapshot(adminSnapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>);

    // Check if AppHub team already exists
    if (await getTeamData('apphubteam').catchError((_) => null) == null) {
      Team appHubTeam = Team(
        id: 'apphubteam',
        name: 'AppHub Team',
        description: 'Default team for AppHub',
        createdAt: Timestamp.now(),
        tags: ['default', 'apphub'],
        roles: {
          'admins': [adminUser.uid!],
          'members': [adminUser.uid!],
          'admins_radmin': [adminUser.uid!],
          'members_radmin': [adminUser.uid!],
        },
      );
      await appHubTeam.saveToFirestore();

      // Initialize AppHub app
      await AppHub.initializeAppHub();
    }

    // Check if MatchHub team already exists
    if (await getTeamData('matchhub').catchError((_) => null) == null) {
      Team matchHubTeam = Team(
        id: 'matchhub',
        name: 'MatchHub',
        description: 'Default team for MatchHub',
        createdAt: Timestamp.now(),
        tags: ['default', 'matchhub'],
        roles: {
          'admins': [adminUser.uid!],
          'members': [adminUser.uid!],
          'admins_radmin': [adminUser.uid!],
          'members_radmin': [adminUser.uid!],
        },
      );
      await matchHubTeam.saveToFirestore();

      // Update MatchHub permissions
      AppModel matchHub = AppModel(
        id: 'matchhub',
        name: 'MatchHub',
        ownerTeam: 'matchhub',
        appAdminScope: AppAdminScope.allowMultipleAdmin,
        appUseScope: AppUseScope.allowAllRole,
        permissions: {
          'appadmins': ['approve_app', 'reject_app', 'suspend_app', 'delete_app'],
          'useappadmins': ['add_app_to_role', 'stop_app', 'delete_app'],
          'appmembers': ['use_app_functionality'],
        },
        meta: {}, // Initialize with empty meta, can be filled as needed
      );

      // Match MatchHub members role with appadmins permission
      await matchHub.addRoleToApp('members', ['approve_app', 'reject_app', 'suspend_app', 'delete_app']);
      // Assign useappadmins to all {role}_radmin
      await matchHub.addRoleToApp('admins_radmin', ['add_app_to_role', 'stop_app', 'delete_app']);
      await matchHub.addRoleToApp('members_radmin', ['add_app_to_role', 'stop_app', 'delete_app']);
      
      await AppModel.addDefaultPermissions(matchHub);
    }
  }
}
