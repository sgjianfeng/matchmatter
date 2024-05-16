import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/user.dart';

class Team {
  final String id;
  final String name;
  final String? description;
  final Timestamp createdAt;
  List<String> tags;
  late Map<String, List<String>> roles;

  Team({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.tags = const [],
    required Map<String, List<String>> roles,
  }) {
    this.roles = roles.isNotEmpty
        ? roles
        : {
            'admins': [],
            'members': [],
          };
  }

  Future<void> addMember(UserModel user, {bool isAdmin = false}) async {
    bool updated = false;

    // Check if the user is already a member
    if (!roles['members']!.contains(user.uid)) {
      roles['members']!.add(user.uid!);
      updated = true;
    }

    // Check if the user should also be an admin
    if (isAdmin && !roles['admins']!.contains(user.uid)) {
      roles['admins']!.add(user.uid!);
      updated = true;
    }

    if (updated) {
      await updateRolesInFirestore();
    }
  }

  Future<void> updateRolesInFirestore() async {
    DocumentReference teamRef = FirebaseFirestore.instance.collection('teams').doc(id);
    await teamRef.update({
      'roles.admins': roles['admins'],
      'roles.members': roles['members'],
    });
  }

  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('teams').doc(id).set({
      'id': id,
      'name': name,
      'description': description,
      'tags': tags,
      'roles': {
        'admins': roles['admins'],
        'members': roles['members'],
      },
      'createdAt': createdAt,
    });
  }

  @override
  String toString() {
    return 'Team: $name, ID: $id, Description: $description, Created At: $createdAt, Tags: $tags, Admins: ${roles['admins']!.length}, Members: ${roles['members']!.length}';
  }

  static Future<Team> getTeamData(String teamId) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance.collection('teams').doc(teamId).get();

    if (!docSnapshot.exists) {
      throw Exception('Team does not exist');
    }

    var data = docSnapshot.data()!;
    var rolesData = data['roles'] ?? {};

    List<String> admins = rolesData.containsKey('admins')
        ? List<String>.from(rolesData['admins'])
        : [];
    List<String> members = rolesData.containsKey('members')
        ? List<String>.from(rolesData['members'])
        : [];

    return Team(
      id: teamId,
      name: data['name'] ?? 'Unknown Team',
      description: data['description'] ?? 'No description available',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      tags: data['tags']?.cast<String>() ?? [],
      roles: {'admins': admins, 'members': members},
    );
  }

  static Future<Map<String, List<UserModel>>> getTeamRoles(Map<String, List<String>> roles) async {
    List<UserModel> admins = await Future.wait(roles['admins']!.map((uid) => UserDatabaseService(uid: uid).getUserData()));
    List<UserModel> members = await Future.wait(roles['members']!.map((uid) => UserDatabaseService(uid: uid).getUserData()));
    return {'admins': admins, 'members': members};
  }
}
