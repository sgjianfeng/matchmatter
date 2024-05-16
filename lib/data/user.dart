import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory UserModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
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
}
