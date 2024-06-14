import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/views/app_detail_page.dart';

class AppsPage extends StatefulWidget {
  final String teamId;
  final UserModel? user;

  const AppsPage({super.key, required this.teamId, this.user});

  @override
  _AppsPageState createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  String searchQuery = '';
  bool showAdmins = true;
  bool showPlayers = true;
  bool showOrganisers = true;
  bool isLoading = true;
  late UserModel currentUser;

  final List<AppModel> badmintonApps = [
    AppModel(
      id: '1',
      name: 'BadmintonTeamEvents',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: 'self team',
      permissions: [
        Permission(id: 'admins', name: 'admins', appId: '1', data: {}),
        Permission(id: 'players', name: 'players', appId: '1', data: {})
      ],
      creator: 'creator_id',
      createdAt: Timestamp.now(),
      description: 'This app allows organizing and participating in badminton team events. Click to learn more details.',
    ),
    AppModel(
      id: '2',
      name: 'BadmintonCourts',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: 'sportmatter team',
      permissions: [
        Permission(id: 'admins', name: 'admins', appId: '2', data: {}),
        Permission(id: 'players', name: 'players', appId: '2', data: {})
      ],
      creator: 'creator_id',
      createdAt: Timestamp.now(),
      description: 'This app manages team courts. You can publish court transfers and provide courts for sportmatter events.',
    ),
    AppModel(
      id: '3',
      name: 'BadmintonMatches',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: 'sportmatter team',
      permissions: [
        Permission(id: 'admins', name: 'admins', appId: '3', data: {}),
        Permission(id: 'players', name: 'players', appId: '3', data: {})
      ],
      creator: 'creator_id',
      createdAt: Timestamp.now(),
      description: 'This app organizes team matches. You can participate in various badminton matches and invite more people to join.',
    ),
  ];

  final List<AppModel> soccerApps = [
    AppModel(
      id: '4',
      name: 'SoccerTeamEvents',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: 'soccer team',
      permissions: [
        Permission(id: 'admins', name: 'admins', appId: '4', data: {}),
        Permission(id: 'players', name: 'players', appId: '4', data: {})
      ],
      creator: 'creator_id',
      createdAt: Timestamp.now(),
      description: 'This app allows organizing and participating in soccer team events. Click to learn more details.',
    ),
    AppModel(
      id: '5',
      name: 'SoccerCourts',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: 'sportmatter team',
      permissions: [
        Permission(id: 'admins', name: 'admins', appId: '5', data: {}),
        Permission(id: 'players', name: 'players', appId: '5', data: {})
      ],
      creator: 'creator_id',
      createdAt: Timestamp.now(),
      description: 'This app manages team courts. You can publish court transfers and provide courts for sportmatter events.',
    ),
    AppModel(
      id: '6',
      name: 'SoccerMatches',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: 'sportmatter team',
      permissions: [
        Permission(id: 'admins', name: 'admins', appId: '6', data: {}),
        Permission(id: 'players', name: 'players', appId: '6', data: {})
      ],
      creator: 'creator_id',
      createdAt: Timestamp.now(),
      description: 'This app organizes team matches. You can participate in various soccer matches and invite more people to join.',
    ),
  ];

  final List<AppModel> bukitBatokEastCcApps = [
    AppModel(
      id: '7',
      name: 'SoccerMatches',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: 'sportmatter team',
      permissions: [
        Permission(id: 'organisers', name: 'organisers', appId: '7', data: {})
      ],
      creator: 'creator_id',
      createdAt: Timestamp.now(),
      description: 'This app organizes soccer matches. Teams can participate, and organizers can invite teams or individuals to join.',
    ),
    AppModel(
      id: '8',
      name: 'SoccerCourts',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: 'sportmatter team',
      permissions: [
        Permission(id: 'organiser', name: 'organiser', appId: '8', data: {})
      ],
      creator: 'creator_id',
      createdAt: Timestamp.now(),
      description: 'This app allows organizers to collaborate with court providers for match venues and court transfers.',
    ),
    AppModel(
      id: '9',
      name: 'MatchSponsors',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: 'sportmatter team',
      permissions: [
        Permission(id: 'organiser', name: 'organiser', appId: '9', data: {})
      ],
      creator: 'creator_id',
      createdAt: Timestamp.now(),
      description: 'This app allows match organizers to negotiate with sponsors to fund matches and achieve commercial value.',
    ),
    AppModel(
      id: '10',
      name: 'MatchMediaSupporter',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: 'sportmatter team',
      permissions: [
        Permission(id: 'organiser', name: 'organiser', appId: '10', data: {})
      ],
      creator: 'creator_id',
      createdAt: Timestamp.now(),
      description: 'This app allows match organizers to collaborate with media service providers for match production and publication.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    if (widget.user == null) {
      await _fetchCurrentUser();
    } else {
      currentUser = widget.user!;
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCurrentUser() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      currentUser = UserModel.fromDocumentSnapshot(userDoc);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      // Handle user not logged in
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<AppModel> apps = widget.teamId == 'bukitbatokeastcc' 
        ? bukitBatokEastCcApps 
        : widget.teamId == 'team6703' 
            ? soccerApps 
            : badmintonApps;

    final filteredApps = apps.where((app) {
      final query = searchQuery.toLowerCase();
      final appMatch = app.name.toLowerCase().contains(query);
      final permissionMatch = app.permissions.any((permission) =>
          permission.name.toLowerCase().contains(query) || 
          permission.data.toString().toLowerCase().contains(query));
      final roleMatch = (showAdmins && app.permissions.any((perm) => perm.id == 'admins')) ||
                        (showPlayers && app.permissions.any((perm) => perm.id == 'players')) ||
                        (showOrganisers && app.permissions.any((perm) => perm.id == 'organisers' || perm.id == 'organiser'));
      return (appMatch || permissionMatch) && roleMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: Container(), // Hide the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AppsSearchDelegate(apps, searchQuery, (query) {
                  setState(() {
                    searchQuery = query;
                  });
                }),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.group),
            onSelected: (String value) {
              if (value == 'settings') {
                // Navigate to role settings page
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              CheckedPopupMenuItem<String>(
                value: 'admins',
                checked: showAdmins,
                child: const Text('Admins'),
                onTap: () {
                  setState(() {
                    showAdmins = !showAdmins;
                  });
                },
              ),
              CheckedPopupMenuItem<String>(
                value: 'players',
                checked: showPlayers,
                child: const Text('Players'),
                onTap: () {
                  setState(() {
                    showPlayers = !showPlayers;
                  });
                },
              ),
              CheckedPopupMenuItem<String>(
                value: 'organisers',
                checked: showOrganisers,
                child: const Text('Organisers'),
                onTap: () {
                  setState(() {
                    showOrganisers = !showOrganisers;
                  });
                },
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Role Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(thickness: 1.0, color: Colors.grey.withOpacity(0.5), height: 1.0),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildAppsList(filteredApps),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsList(List<AppModel> apps) {
    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        List<String> filteredRoles = [];
        if (showAdmins) filteredRoles.addAll(app.permissions.where((perm) => perm.id == 'admins').map((perm) => perm.name));
        if (showPlayers) filteredRoles.addAll(app.permissions.where((perm) => perm.id == 'players').map((perm) => perm.name));
        if (showOrganisers) filteredRoles.addAll(app.permissions.where((perm) => perm.id == 'organisers' || perm.id == 'organiser').map((perm) => perm.name));

        return Padding(
          padding: EdgeInsets.only(
              top: index == 0 ? 4.0 : 8.0, bottom: 8.0, left: 8.0, right: 8.0),
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppDetailPage(app: app)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.apps, color: Colors.blue),
                        const SizedBox(width: 8.0),
                        Text(
                          app.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text('Owner: ${app.ownerTeamId}'),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text('Roles: ${filteredRoles.join(', ')}'),
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.lightGreenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(app.description ?? ''),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppsSearchDelegate extends SearchDelegate<String> {
  final List<AppModel> apps;
  final String currentQuery;
  final ValueChanged<String> onQueryUpdate;

  AppsSearchDelegate(this.apps, this.currentQuery, this.onQueryUpdate) {
    query = currentQuery;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onQueryUpdate(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = apps.where((app) {
      final appMatch = app.name.toLowerCase().contains(query.toLowerCase());
      final permissionMatch = app.permissions.any((permission) =>
          permission.name.toLowerCase().contains(query.toLowerCase()) || 
          permission.data.toString().toLowerCase().contains(query.toLowerCase()));
      return appMatch || permissionMatch;
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final app = results[index];
        return ListTile(
          title: Text(app.name),
          subtitle: Text(app.description ?? ''),
          onTap: () {
            close(context, app.name);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppDetailPage(app: app)),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
