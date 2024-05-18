import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/user.dart';

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

  Future<void> addMember(UserModel user, {String role = 'members'}) async {
    if (!roles.containsKey(role)) {
      roles[role] = [];
    }

    // Check if user is already in the role
    if (!roles[role]!.contains(user.uid)) {
      roles[role]!.add(user.uid!);
      await updateRolesInFirestore();
    }
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
}
