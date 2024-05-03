import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // 如果用户已登录,导航到主页
            return const HomePage(); // 使用导入的 HomePage 小部件
          } else {
            // 如果用户未登录,导航到登录页面
            return const LoginPage(); // 使用导入的 LoginPage 小部件
          }
        },
      ),
    );
  }
}
