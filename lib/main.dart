import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:matchmatter/auth/sign_up_page.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/views/teams_page.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/bottom_navigation_provider.dart';
import 'theme.dart';
import 'auth/login_page.dart'; // 导入登录页面
import 'views/home_page.dart'; // 导入主页面

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => BottomNavigationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MatchMatter',
      theme: const MaterialTheme(whatsAppTextTheme).light(),
      initialRoute: '/', // 设置初始路由为 '/'
      routes: {
        '/': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              initialData: null, // 添加 initialData 参数
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // 如果用户已登录,导航到主页
                  return const HomePage(); // 使用导入的 HomePage 小部件
                } else if (snapshot.data == null) {
                  // 如果用户未登录,导航到登录页面
                  return LoginPage(); // 使用导入的 LoginPage 小部件
                } else {
                  // 处理其他情况,例如显示加载指示器
                  return const CircularProgressIndicator();
                }
              },
            ),
            '/signup': (context) => const SignUpPage(), // 添加 /signup 路由
            '/login': (context) => LoginPage(), // 添加 /login 路由
            '/teams': (context) => const TeamsPage(), // 添加 /teams 路由
      },
    );
  }
}
