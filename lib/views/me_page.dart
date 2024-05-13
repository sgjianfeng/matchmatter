import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matchmatter/data/user.dart'; // assume this is the correct path

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // If no user logged in, navigate to login page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Material(
        child: Center(
          child: CircularProgressIndicator(), // display loading indicator
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Me'),
      ),
      body: Center(
        child: FutureBuilder<UserModel>(
          future: UserDatabaseService(uid: user.uid).getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // display loading indicator
            }
            if (snapshot.hasError) {
              return Text('Failed to load user data: ${snapshot.error}');
            }
            final userData = snapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/avatars/avatar4.png'),
                ),
                const SizedBox(height: 16),
                Text(
                  userData?.name ??
                      '未设置名称', // use null-aware operator to display name or default text
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? '未设置邮箱', // display email or default text
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userData?.phoneNumber ??
                      '未设置手机号', // display phone number or default text
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 240, 159, 154),
                  ),
                  child: const Text('退出登录'),
                ),
                // other UI elements...
              ],
            );
          },
        ),
      ),
    );
  }
}
