import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchmatter/data/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // Create the new user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store new user's credentials
      User? newUser = result.user;

      // Save new user data to Firestore
      if (newUser != null) {
        await UserDatabaseService(uid: newUser.uid).updateUserData(
          newUser.displayName ?? 'Unknown',
          newUser.phoneNumber ?? 'No phone number',
          newUser.email ?? 'No email',
        );
      }

      // Initialize the default admin user
      bool isAdminCreated = await UserDatabaseService.initializeDefaultAdmin();

      // Log back in as the new user if admin was created
      if (isAdminCreated && newUser != null) {
        await _auth.signOut();
        UserCredential newUserCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return newUserCredential.user;
      } else {
        return newUser;
      }
    } catch (e) {
      print('Error signing up: $e');
      throw e;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error signing in: $e');
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }
}
