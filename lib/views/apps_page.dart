import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/views/apps_list.dart';
import 'package:matchmatter/views/roles_list.dart';

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
  bool showSearchBar = false;
  List<AppModel> apps = [];
  List<RoleModel> roles = [];
  List<RolePermissions> rolesPermissions = [];
  bool isLoading = true;
  late UserModel currentUser;
  Set<String> selectedRoles = {};

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
      rolesPermissions = await getUserPermissionsInTeam(widget.teamId, currentUser.uid);
      final apps = await _mapAppPermissions(rolesPermissions);
      final roles = _mapRolePermissions(rolesPermissions);

      setState(() {
        this.apps = apps;
        this.roles = roles;
        selectedRoles.addAll(roles.map((role) => role.id));
        isLoading = false;
      });

      // Print roles to check if they are fetched correctly
      print('User roles: ${roles.map((role) => role.name).toList()}');
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<AppModel>> _mapAppPermissions(List<RolePermissions> rolesPermissions) async {
    Set<String> appIds = rolesPermissions.map((rolePerm) => rolePerm.appId).toSet();
    List<AppModel> apps = [];

    for (String appId in appIds) {
      AppModel? app = await AppModel.getAppData(appId, widget.teamId);
      if (app != null) {
        apps.add(app);
      }
    }

    return apps;
  }

  List<RoleModel> _mapRolePermissions(List<RolePermissions> rolesPermissions) {
    Set<String> roleIds = rolesPermissions.map((rolePerm) => rolePerm.roleId).toSet();
    return roleIds.map((roleId) {
      return RoleModel(
        id: roleId,
        name: roleId,
        teamId: widget.teamId,
        data: {}, // Adjust this as per your data
      );
    }).toList();
  }

  void _onRoleSelected(String roleId) {
    setState(() {
      if (selectedRoles.contains(roleId)) {
        selectedRoles.remove(roleId);
      } else {
        selectedRoles.add(roleId);
      }
      _updateAppsList();
    });
  }

  void _updateAppsList() async {
    if (selectedRoles.isEmpty) {
      // If no roles are selected, clear the app list
      setState(() {
        apps = [];
      });
      return;
    }

    Set<String> selectedAppIds = rolesPermissions
        .where((rolePerm) => selectedRoles.contains(rolePerm.roleId))
        .map((rolePerm) => rolePerm.appId)
        .toSet();

    List<AppModel?> updatedApps = await Future.wait(
      selectedAppIds.map((appId) => AppModel.getAppData(appId, widget.teamId)),
    );

    // Filter out null values
    List<AppModel> nonNullUpdatedApps = updatedApps.where((app) => app != null).cast<AppModel>().toList();

    setState(() {
      apps = nonNullUpdatedApps;
    });
  }

  List<PopupMenuEntry<String>> _buildRolesMenuItems() {
    return [
      ...roles.map((role) {
        return PopupMenuItem<String>(
          value: role.id,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Row(
                children: [
                  Checkbox(
                    value: selectedRoles.contains(role.id),
                    onChanged: (bool? checked) {
                      setState(() {
                        _onRoleSelected(role.id);
                      });
                    },
                  ),
                  Text(role.name),
                ],
              );
            },
          ),
        );
      }).toList(),
      const PopupMenuDivider(),
      const PopupMenuItem<String>(
        value: 'settings',
        child: ListTile(
          leading: Icon(Icons.settings),
          title: Text('Role Settings'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Spacer(),
            ..._buildAppBarActions(context),
          ],
        ),
      ),
      body: Column(
        children: [
          Divider(thickness: 1.0, color: Colors.grey.withOpacity(0.5), height: 1.0),
          if (showSearchBar) _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : showRoles ? RolesList(roles: roles) : AppsList(apps: apps, searchQuery: searchQuery),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          setState(() {
            showSearchBar = !showSearchBar;
          });
        },
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.group),
        onSelected: (String result) {
          if (result == 'settings') {
            // Navigate to settings page
          }
        },
        itemBuilder: (BuildContext context) => _buildRolesMenuItems(),
      ),
    ];
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
    );
  }
}
