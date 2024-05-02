import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/bottom_navigation_provider.dart';
import 'views/contacts_page.dart';
import 'views/home_page.dart';
import 'views/matches_page.dart';
import 'views/me_page.dart';
import 'views/teams_page.dart';

class Routes {
  static const String home = '/';
  static const String teams = '/teams';
  static const String matches = '/matches';
  static const String contacts = '/contacts';
  static const String me = '/me';

  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    teams: (context) => const TeamsPage(),
    matches: (context) => const MatchesPage(),
    contacts: (context) => const ContactsPage(),
    me: (context) => const MePage(),
  };

  static void navigateToPage(BuildContext context, String routeName) {
    final bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context, listen: false);
    bottomNavigationProvider.setCurrentIndex(Routes.getIndexFromRouteName(routeName));
    Navigator.pushNamed(context, routeName);
  }

  static int getIndexFromRouteName(String routeName) {
    switch (routeName) {
      case home:
        return 0;
      case teams:
        return 1;
      case matches:
        return 2;
      case contacts:
        return 3;
      case me:
        return 4;
      default:
        return 0;
    }
  }
}
