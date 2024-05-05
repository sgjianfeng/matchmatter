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

  factory UserModel.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
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
    try {
      await _userCollection.doc(uid).set({
        'name': name,
        'phoneNumber': phoneNumber,
        'createdAt': Timestamp.now(),
      });

      return await getUserData();
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  Future<UserModel> getUserData() async {
    final DocumentSnapshot<Object?> docSnapshot =
        await _userCollection.doc(uid).get();
    if (docSnapshot.exists) {
      // 确保文档存在
      final DocumentSnapshot<Map<String, dynamic>> doc =
          docSnapshot as DocumentSnapshot<Map<String, dynamic>>;
      return UserModel.fromDocumentSnapshot(doc);
    } else {
      // 处理文档不存在的情况，例如抛出错误或返回空用户
      //throw Exception('Document does not exist.');
      // 返回一个空的 UserModel
      return UserModel(
          uid: '', name: '', phoneNumber: '', createdAt: Timestamp.now());
    }
  }
}
