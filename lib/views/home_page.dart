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
        return MaterialPageRoute(builder: (_) => TeamsPage());
      case '/matches':
        return MaterialPageRoute(builder: (_) => MatchesPage());
      case '/contacts':
        return MaterialPageRoute(builder: (_) => ContactsPage());
      case '/me':
        return MaterialPageRoute(builder: (_) => MePage());
      case '/teamDetail':
        final team = settings.arguments as Team;
        return MaterialPageRoute(builder: (_) => TeamPage(team: team));
      default:
        return MaterialPageRoute(builder: (_) => TeamsPage());
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

  void _selectTab(int index, BuildContext context) {
    if (index !=
        Provider.of<BottomNavigationProvider>(context, listen: false)
            .currentIndex) {
      Provider.of<BottomNavigationProvider>(context, listen: false)
          .setCurrentIndex(index);
      final routeNames = ['/teams', '/matches', '/contacts', '/me'];
      if (Provider.of<BottomNavigationProvider>(context, listen: false)
              .navigatorKey
              .currentState !=
          null) {
        Provider.of<BottomNavigationProvider>(context, listen: false)
            .navigatorKey
            .currentState!
            .pushNamedAndRemoveUntil(
                routeNames[index], ModalRoute.withName('/'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BottomNavigationProvider>(
      create: (_) => BottomNavigationProvider(),
      child: Consumer<BottomNavigationProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            body: Navigator(
              key: provider.navigatorKey,
              onGenerateRoute: _generateRoute,
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, provider),
          );
        },
      ),
    );
  }
}
