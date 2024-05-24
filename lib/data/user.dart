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
      return UserModel(
        uid: '', 
        name: 'Unknown', 
        phoneNumber: 'No phone number', 
        email: 'No email', 
        createdAt: Timestamp.now(),
      );
    }
  }

  static Future<void> initializeDefaultAdmin() async {
    final String adminEmail = 'admin@matchmatter.com';
    final String adminPassword = 'MatchMatter2024';
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: adminEmail)
        .get();

    if (snapshot.docs.isEmpty) {
      // Create default admin user if not exists
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: adminEmail, password: adminPassword);

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
          'name': 'MatchMatterAdmin',
          'phoneNumber': '1234567890',
          'email': adminEmail,
          'createdAt': Timestamp.now(),
        });
        print('Default admin user created.');
      } catch (e) {
        print('Error creating default admin user: $e');
      }
    } else {
      print('Default admin user already exists.');
    }
  }
}
