import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String? uid;
  final String name;
  final String phoneNumber;
  final String email;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel(
      uid: doc.id,
      name: doc.data()?['name'] ?? 'Unknown', // Provide a default value or handle null
      phoneNumber: doc.data()?['phoneNumber'] ?? 'No phone number', // Provide a default value or handle null
      email: doc.data()?['email'] ?? 'No email', // Provide a default value or handle null
      createdAt: doc['createdAt'],
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

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<UserModel> updateUserData(String name, String phoneNumber, String email) async {
    try {
      await _userCollection.doc(uid).set({
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      return await getUserData();
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  Future<UserModel> getUserData() async {
    final DocumentSnapshot<Object?> docSnapshot = await _userCollection.doc(uid).get();
    if (docSnapshot.exists) {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          docSnapshot as DocumentSnapshot<Map<String, dynamic>>;
      return UserModel.fromDocumentSnapshot(doc);
    } else {
      // Fallback in case the user data is not found in Firestore
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
            'createdAt': Timestamp.now(),
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
}
