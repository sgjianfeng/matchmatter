import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String name;
  final String phoneNumber;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel(
      uid: doc.id,
      name: doc['name'],
      phoneNumber: doc['phoneNumber'],
      createdAt: doc['createdAt'],
    );
  }
}

class UserDatabaseService {
  final String? uid;

  UserDatabaseService({this.uid});

  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<UserModel> updateUserData(String name, String phoneNumber) async {
    await _userCollection.doc(uid).set({
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.now(),
    });

    return _getUserData();
  }

  Future<UserModel> _getUserData() async {
  final DocumentSnapshot<Object?> docSnapshot = await _userCollection.doc(uid).get();
  final DocumentSnapshot<Map<String, dynamic>> doc = docSnapshot as DocumentSnapshot<Map<String, dynamic>>;

  return UserModel.fromDocumentSnapshot(doc);
}

}
