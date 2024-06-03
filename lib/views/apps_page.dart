import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';

class AppsPage extends StatefulWidget {
  final String teamId;
  final UserModel? user;

  const AppsPage({super.key, required this.teamId, this.user});

  @override
  _AppsPageState createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  String searchQuery = '';
  bool showRoles = false;
  List<AppModel> apps = [];
  List<RoleModel> roles = [];
  bool isLoading = true;
  late UserModel currentUser;

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
      await _fetchData();
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
      await _fetchData();
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle user not logged in
    }
  }

  Future<void> _fetchData() async {
  try {
    UserPermissionsResult userPermissionsResult = await getUserPermissionsInTeam(widget.teamId, currentUser.uid);

    setState(() {
      apps = userPermissionsResult.appsPermissions.map((appPerm) {
        return AppModel(
          id: appPerm.appId,
          name: appPerm.appName,
          appOwnerScope: AppOwnerScope.sole, // Adjust this as per your data
          appUserScope: AppUserScope.ownerteam, // Adjust this as per your data
          scopeData: {}, // Adjust this as per your data
          ownerTeamId: widget.teamId,
          permissions: appPerm.permissions.map((permName) {
            return Permission(
              id: permName,
              name: permName,
              appId: appPerm.appId,
              data: {}, // Adjust this as per your data
            );
          }).toList(),
          creator: currentUser.uid,
          createdAt: Timestamp.now(),
          description: '', // Adjust this as per your data
        );
      }).toList();
      roles = userPermissionsResult.rolesPermissions.map((rolePerm) {
        return RoleModel(
          id: rolePerm.roleId,
          name: rolePerm.roleName,
          teamId: widget.teamId,
          data: {}, // Adjust this as per your data
        );
      }).toList();
      isLoading = false;
    });
  } catch (error) {
    print('Error fetching data: $error');
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final filteredApps = apps.where((app) {
      final query = searchQuery.toLowerCase();
      final appMatch = app.name.toLowerCase().contains(query);
      final permissionMatch = app.permissions.any((permission) =>
          permission.name.toLowerCase().contains(query) || 
          permission.data.toString().toLowerCase().contains(query));
      return appMatch || permissionMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.apps),
            onPressed: () {
              setState(() {
                showRoles = false;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              setState(() {
                showRoles = true;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Search',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: showRoles ? _buildRolesList() : _buildAppsList(filteredApps),
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppDetailPage(app: app)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('${app.name} (${app.id})'),
                  ),
                  ...app.permissions.map((permission) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(permission.name),
                        subtitle: Text(permission.data.toString()),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRolesList() {
    final joinedRoles = roles.where((role) {
      return true;
    }).toList();

    final notJoinedRoles = roles.where((role) {
      return false;
    }).toList();

    return ListView(
      children: [
        _buildRoleSection('Joined Roles', joinedRoles, true),
        _buildRoleSection('Not Joined Roles', notJoinedRoles, false),
      ],
    );
  }

  Widget _buildRoleSection(String title, List<RoleModel> roleList, bool isJoined) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        ...roleList.map((role) {
          final isAdmin = isJoined && role.data['apps']?.any((app) => app['roles']?.contains('adminrole')) ?? false;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(role.name),
                    trailing: isAdmin ? const Icon(Icons.admin_panel_settings) : null,
                  ),
                  if (role.data['apps'] != null)
                    ...role.data['apps'].map<Widget>((app) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (app['actions'] != null)
                              ...app['actions'].map<Widget>((action) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(action['name'], style: const TextStyle(fontStyle: FontStyle.italic)),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                        child: Text(action['description']),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class AppDetailPage extends StatelessWidget {
  final AppModel app;

  const AppDetailPage({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${app.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Description: ${app.description}'),
            const SizedBox(height: 10),
            Text('Permissions:'),
            ...app.permissions.map((permission) {
              return ListTile(
                title: Text(permission.name),
                subtitle: Text(permission.data.toString()),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
