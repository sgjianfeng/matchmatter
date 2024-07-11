import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String name;
  final String? phoneNumber;
  final String email;
  final Timestamp? createdAt;

  UserModel({
    required this.uid,
    this.name = 'Unknown',
    this.phoneNumber = 'No phone number',
    this.email = 'No email',
    this.createdAt,
  });

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return UserModel(
      uid: doc.id,
      name: data?['name'] ?? 'Unknown',
      phoneNumber: data?['phoneNumber'] ?? 'No phone number',
      email: data?['email'] ?? 'No email',
      createdAt: data?['createdAt'],
    );
  }

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? 'Unknown',
      phoneNumber: user.phoneNumber ?? 'No phone number',
      email: user.email ?? 'No email',
      createdAt: Timestamp.now(),
    );
  }
}

class UserDatabaseService {
  final String? uid;

  UserDatabaseService({this.uid});

  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

  Future<UserModel> updateUserData(String name, String phoneNumber, String email) async {
    try {
      await _userCollection.doc(uid).set({
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
      }, SetOptions(merge: true)); // Merge to avoid overwriting existing fields

      return await getUserData();
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  Future<UserModel> getUserData() async {
    try {
      final docSnapshot = await _userCollection.doc(uid).get();
      if (docSnapshot.exists) {
        final doc = docSnapshot as DocumentSnapshot<Map<String, dynamic>>;
        return UserModel.fromDocumentSnapshot(doc);
      } else {
        // Fallback in case the user data is not found in Firestore
        return _getFallbackUserData();
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      throw Exception('Failed to retrieve user data');
    }
  }

  Future<void> setTeamId(String teamId) async {
    try {
      await _userCollection.doc(uid).set({
        'teamId': teamId,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error setting teamId: $e');
      throw Exception('Failed to set teamId');
    }
  }

  Future<String?> getTeamId() async {
    try {
      final docSnapshot = await _userCollection.doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['teamId'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting teamId: $e');
      throw Exception('Failed to get teamId');
    }
  }

  Future<void> setServiceId(String serviceId) async {
    try {
      await _userCollection.doc(uid).set({
        'serviceId': serviceId,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error setting serviceId: $e');
      throw Exception('Failed to set serviceId');
    }
  }

  Future<String?> getServiceId() async {
    try {
      final docSnapshot = await _userCollection.doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return data['serviceId'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting serviceId: $e');
      throw Exception('Failed to get serviceId');
    }
  }

  UserModel _getFallbackUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    } else {
      return UserModel(
        uid: '',
        name: 'Unknown',
        phoneNumber: 'No phone number',
        email: 'No email',
        createdAt: Timestamp.now(),
      );
    }
  }

  static Future<bool> initializeDefaultAdmin() async {
    const String adminEmail = 'admin@matchmatter.com';
    const String adminPassword = 'MatchMatter2024';

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: adminEmail)
            .get();

        if (snapshot.docs.isEmpty) {
          // Sign out current user
          await FirebaseAuth.instance.signOut();

          // Create default admin user if not exists
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: adminEmail, password: adminPassword);

          await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
            'name': 'MatchMatterAdmin',
            'phoneNumber': '1234567890',
            'email': adminEmail,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('Default admin user created.');

          // Return true indicating admin was created
          return true;
        } else {
          print('Default admin user already exists。');
          return false;
        }
      } catch (e) {
        print('Error checking/creating default admin user: $e');
        return false;
      }
    } else {
      print('No user logged in, skipping admin initialization。');
      return false;
    }
  }

  static String getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('No user is currently logged in');
    }
  }

  // Function to get user roles in a team
  static Future<List<String>> getUserRolesInTeam(String teamId, String userId) async {
    try {
      // Get the team document
      DocumentSnapshot teamSnapshot = await FirebaseFirestore.instance.collection('teams').doc(teamId).get();
      if (!teamSnapshot.exists) {
        throw Exception('Team does not exist');
      }

      // Get the roles data
      Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;
      Map<String, List<dynamic>> roles = Map<String, List<dynamic>>.from(teamData['roles']);

      // Find user roles
      List<String> userRoles = [];
      roles.forEach((role, userIds) {
        if (userIds.contains(userId)) {
          userRoles.add(role);
        }
      });

      return userRoles;
    } catch (e) {
      print('Error getting user roles in team: $e');
      throw Exception('Failed to get user roles in team');
    }
  }

  // Function to get user services in a team
  static Future<Map<String, List<String>>> getUserServicesInTeam(String teamId, String userId) async {
    try {
      List<String> userRoles = await getUserRolesInTeam(teamId, userId);
      Map<String, List<String>> roleServices = {};

      for (String roleId in userRoles) {
        QuerySnapshot roleServicesSnapshot = await FirebaseFirestore.instance
            .collection('roleservicepermissions')
            .where('teamId', isEqualTo: teamId)
            .where('roleId', isEqualTo: roleId)
            .get();

        for (var doc in roleServicesSnapshot.docs) {
          String serviceId = doc['serviceId'];
          if (!roleServices.containsKey(roleId)) {
            roleServices[roleId] = [];
          }
          roleServices[roleId]!.add(serviceId); // 这里的 serviceId 已经是 combinedId
        }
      }

      return roleServices;
    } catch (e) {
      print('Error getting user services in team: $e');
      throw Exception('Failed to get user services in team');
    }
  }
}
