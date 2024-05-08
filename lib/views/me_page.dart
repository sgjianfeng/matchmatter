import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matchmatter/data/user.dart'; // 假设这是正确的路径

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // 如果没有用户登录, 跳转到登录页面
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Material(
        child: Center(
          child: CircularProgressIndicator(), // 显示加载中指示器
        ),
      );
    }

    return Material(
      child: Center(
        child: FutureBuilder<UserModel>(
          future: UserDatabaseService(uid: user.uid).getUserData(), // 确保传递uid
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // 数据加载时显示加载指示器
            }
            if (snapshot.hasError) {
              return Text('无法加载用户数据: ${snapshot.error}'); // 显示错误信息
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
                  userData?.name ?? '未设置名称', // 使用Null-aware操作符显示名称或默认文本
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? '未设置邮箱', // 显示邮箱或默认文本
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userData?.phoneNumber ?? '未设置手机号', // 显示电话号码或默认文本
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
                // 其他界面元素...
              ],
            );
          },
        ),
      ),
    );
  }
}
