import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bottom_navigation_provider.dart';
import '../views/contacts_page.dart';
import '../views/matches_page.dart';
import '../views/me_page.dart';
import '../views/teams_page.dart';
import '../views/team_page.dart';
import '../data/team.dart'; // Assuming you have a Team data class

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/teams':
        return MaterialPageRoute(builder: (_) => const TeamsPage());
      case '/matches':
        return MaterialPageRoute(builder: (_) => const MatchesPage());
      case '/contacts':
        return MaterialPageRoute(builder: (_) => const ContactsPage());
      case '/me':
        return MaterialPageRoute(builder: (_) => const MePage());
      case '/teamDetail':
        final team = settings.arguments as Team;
        return MaterialPageRoute(builder: (_) => TeamPage(team: team));
      default:
        return MaterialPageRoute(builder: (_) => const TeamsPage());
    }
  }

  BottomNavigationBar _buildBottomNavigationBar(
      BuildContext context, BottomNavigationProvider provider) {
    return BottomNavigationBar(
      currentIndex: provider.currentIndex,
      onTap: (index) => _selectTab(index, context),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Teams'),
        BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer), label: 'Matches'),
        BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
      ],
      backgroundColor: Colors.grey.shade200,
      unselectedItemColor: Colors.black,
      selectedItemColor: Colors.blue,
      showUnselectedLabels: true,
      elevation: 8.0,
    );
  }

  // void _selectTab(int index, BuildContext context) {
  //   if (index !=
  //       Provider.of<BottomNavigationProvider>(context, listen: false)
  //           .currentIndex) {
  //     Provider.of<BottomNavigationProvider>(context, listen: false)
  //         .setCurrentIndex(index);
  //     final routeNames = ['/teams', '/matches', '/contacts', '/me'];
  //     if (Provider.of<BottomNavigationProvider>(context, listen: false)
  //             .navigatorKey
  //             .currentState !=
  //         null) {
  //       Provider.of<BottomNavigationProvider>(context, listen: false)
  //           .navigatorKey
  //           .currentState!
  //           .pushNamedAndRemoveUntil(
  //               routeNames[index], ModalRoute.withName('/'));
  //     }
  //   }
  // }

  // void _selectTab(int index, BuildContext context) {
  //   if (index !=
  //       Provider.of<BottomNavigationProvider>(context, listen: false)
  //           .currentIndex) {
  //     Provider.of<BottomNavigationProvider>(context, listen: false)
  //         .setCurrentIndex(index);
  //     final routeNames = ['/teams', '/matches', '/contacts', '/me'];
  //     // Check if the selected tab is Teams
  //     if (index == 0) {
  //       // If selected tab is Teams, pop all routes in its Navigator stack
  //       Provider.of<BottomNavigationProvider>(context, listen: false)
  //           .navigatorKeys[index]
  //           .currentState!
  //           .popUntil((route) => route.isFirst);
  //     } else {
  //       // For other tabs, navigate to the respective route
  //       Provider.of<BottomNavigationProvider>(context, listen: false)
  //           .navigatorKeys[index]
  //           .currentState!
  //           .pushNamedAndRemoveUntil(
  //               routeNames[index], ModalRoute.withName('/'));
  //     }
  //   }
  // }
  void _selectTab(int index, BuildContext context) {
    var provider =
        Provider.of<BottomNavigationProvider>(context, listen: false);
    if (index != provider.currentIndex) {
      provider.setCurrentIndex(index);
      final routeNames = ['/teams', '/matches', '/contacts', '/me'];

      if (index == 0) {
        // Do not pop to the first route for 'Teams' tab to preserve state
        // Navigation state is automatically preserved due to separate Navigator for each tab
      } else {
        // For other tabs, continue to reset navigation state as before
        provider.navigatorKeys[index].currentState!.pushNamedAndRemoveUntil(
            routeNames[index], ModalRoute.withName('/'));
      }
    }
  }

  Widget _buildNavigatorForTab(int index, BottomNavigationProvider provider) {
    return Offstage(
      offstage: provider.currentIndex != index,
      child: Navigator(
        key: provider.navigatorKeys[index],
        onGenerateRoute: (settings) => _generateRoute(settings),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BottomNavigationProvider>(
      create: (_) => BottomNavigationProvider(),
      child: Consumer<BottomNavigationProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            body: Stack(
              children: [
                _buildNavigatorForTab(0, provider),
                _buildNavigatorForTab(1, provider),
                _buildNavigatorForTab(2, provider),
                _buildNavigatorForTab(3, provider),
              ],
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, provider),
          );
        },
      ),
    );
  }
}
