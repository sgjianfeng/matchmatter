import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/user.dart';

class Team {
  final String id;
  final String name;
  List<String> tags;
  late Map<String, List<UserModel>> roles;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Team({
    required this.id,
    required this.name,
    this.tags = const [],
    required Map<String, List<UserModel>> roles,
  }) {
    this.roles = roles.isNotEmpty ? roles : {
      'admins': [],
      'members': [],
    };
  }

  Future<void> addMember(UserModel user, {bool isAdmin = false}) async {
    DocumentReference teamRef = firestore.collection('teams').doc(id);
    bool updated = false;

    // Check if the user is already a member
    if (!roles['members']!.any((u) => u.uid == user.uid)) {
      roles['members']!.add(user);
      updated = true;
    }

    // Check if the user should also be an admin
    if (isAdmin && !roles['admins']!.any((u) => u.uid == user.uid)) {
      roles['admins']!.add(user);
      updated = true;
    }

    if (updated) {
      await teamRef.update({
        'members': roles['members']!.map((u) => u.uid).toList(),
        'admins': roles['admins']!.map((u) => u.uid).toList(),
      });
    }
  }

  @override
  String toString() {
    return 'Team: $name, ID: $id, Tags: $tags, Admins: ${roles['admins']!.length}, Members: ${roles['members']!.length}';
  }
}

class TeamDatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> updateTeamData(String teamId, Map<String, List<UserModel>> roles) async {
    try {
      await firestore.collection('teams').doc(teamId).set({
        'admins': roles['admins']!.map((user) => user.uid).toList(),
        'members': roles['members']!.map((user) => user.uid).toList(),
      });
    } catch (e) {
      print('Error updating team data: $e');
      throw Exception('Failed to update team data');
    }
  }

  Future<Team> getTeamData(String teamId) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await firestore.collection('teams').doc(teamId).get();

    if (!docSnapshot.exists) {
      throw Exception('Team does not exist');
    }

    List<UserModel> admins = (await Future.wait((docSnapshot.data()?['admins'] as List<dynamic>).map((uid) => UserDatabaseService(uid: uid).getUserData()))).cast<UserModel>();
    List<UserModel> members = (await Future.wait((docSnapshot.data()?['members'] as List<dynamic>).map((uid) => UserDatabaseService(uid: uid).getUserData()))).cast<UserModel>();

    return Team(id: teamId, name: docSnapshot.data()?['name'] ?? 'Unknown Team', tags: docSnapshot.data()?['tags'].cast<String>(), roles: {'admins': admins, 'members': members});
  }
}

