import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bottom_navigation_provider.dart';
import '../views/contacts_page.dart';
import '../views/matches_page.dart';
import '../views/me_page.dart';
import '../views/teams_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => BottomNavigationProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Match Matter',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          backgroundColor: theme.colorScheme.inversePrimary,
        ),
        body: Consumer<BottomNavigationProvider>(
          builder: (context, provider, child) {
            final List<Widget> _pages = [
              const TeamsPage(),
              const MatchesPage(),
              const ContactsPage(),
              const MePage(),
            ];
            return _pages[provider.currentIndex];
          },
        ),
        bottomNavigationBar: Consumer<BottomNavigationProvider>(
          builder: (context, provider, child) {
            return BottomNavigationBar(
              currentIndex: provider.currentIndex,
              onTap: (index) {
                provider.setCurrentIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.group),
                  label: '球队',
                  activeIcon: const Icon(Icons.group, color: Colors.blue),
                  backgroundColor: Colors.grey.shade200,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.sports_soccer),
                  label: '比赛',
                  activeIcon:
                      const Icon(Icons.sports_soccer, color: Colors.blue),
                  backgroundColor: Colors.grey.shade200,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.contacts),
                  label: '联系人',
                  activeIcon: const Icon(Icons.contacts, color: Colors.blue),
                  backgroundColor: Colors.grey.shade200,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: '我的',
                  activeIcon: const Icon(Icons.person, color: Colors.blue),
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
              unselectedItemColor: Colors.grey,
              selectedItemColor: Colors.blue,
              showUnselectedLabels: true,
            );
          },
        ),
      ),
    );
  }
}
