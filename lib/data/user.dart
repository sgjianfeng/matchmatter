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
      createdAt: Timestamp.now(), // Assuming the creation date is now
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
          print('Default admin user already exists.');
          return false;
        }
      } catch (e) {
        print('Error checking/creating default admin user: $e');
        return false;
      }
    } else {
      print('No user logged in, skipping admin initialization.');
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
}
