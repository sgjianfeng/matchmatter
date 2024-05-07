import 'package:flutter/material.dart';
import 'package:matchmatter/views/new_team_page.dart';
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
      child: Consumer<BottomNavigationProvider>(
        builder: (context, provider, child) {
          final List<Widget> pages = [
            const TeamsPage(),
            const MatchesPage(),
            const ContactsPage(),
            const MePage(),
          ];
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Match Matter',
                style: theme.textTheme.titleMedium,
              ),
              backgroundColor: theme.colorScheme.primaryContainer,
              elevation: 0,
              actions: <Widget>[
                if (provider.currentIndex ==
                    0) // Only show '+' icon on TeamsPage
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.white,
                    offset: const Offset(0, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onSelected: (String? newValue) {
                      if (newValue != null) {
                        switch (newValue) {
                          case 'NewTeam':
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(50.0)),
                              ),
                              builder: (context) => ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.95,
                                ),
                                child: const NewTeamPage(),
                              ),
                              // builder: (context) => const ClipRRect(
                              //   borderRadius: BorderRadius.vertical(
                              //       top: Radius.circular(50.0)),
                              //   child: NewTeamPage(),
                              // ),
                            );
                            // showModalBottomSheet(
                            //   context: context,
                            //   isScrollControlled: true,
                            //   builder: (context) => ConstrainedBox(
                            //     constraints: BoxConstraints(
                            //       maxHeight:
                            //           MediaQuery.of(context).size.height * 0.95,
                            //     ),
                            //     child: NewTeamPage(),
                            //   ),
                            // );

                            break;
                          case 'Scan':
                            print('Scan functionality to be implemented');
                            break;
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'NewTeam',
                        child: Text('New Team'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Scan',
                        child: Text('Scan'),
                      ),
                    ],
                  ),
              ],
            ),
            body: pages[provider.currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: provider.currentIndex,
              onTap: (index) {
                provider.setCurrentIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.group),
                  label: 'Teams',
                  activeIcon: const Icon(Icons.group, color: Colors.blue),
                  backgroundColor: Colors.grey.shade200,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.sports_soccer),
                  label: 'Matches',
                  activeIcon: const Icon(Icons.sports_soccer, color: Colors.blue),
                  backgroundColor: Colors.grey.shade200,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.contacts),
                  label: 'Contacts',
                  activeIcon: const Icon(Icons.contacts, color: Colors.blue),
                  backgroundColor: Colors.grey.shade200,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: 'Me',
                  activeIcon: const Icon(Icons.person, color: Colors.blue),
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
              unselectedItemColor: Colors.grey,
              selectedItemColor: Colors.blue,
              showUnselectedLabels: true,
            ),
          );
        },
      ),
    );
  }
}
