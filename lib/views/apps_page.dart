import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/views/apps_list.dart';
import 'package:matchmatter/views/app_widget_list_page.dart'; // Import AppWidgetListPage
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
  AppModel? selectedApp; // 新增变量，用于保存选中的应用

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
      rolesPermissions = await getUserRolePermissions(widget.teamId, currentUser.uid);
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
      _updateAppsForSelectedRoles();
    });
  }

  Future<void> _updateAppsForSelectedRoles() async {
    if (selectedRoles.isEmpty) {
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

    setState(() {
      apps = updatedApps.whereType<AppModel>().toList(); // Filter out null values
    });
  }

  void _showCustomMenu(BuildContext context) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          overlay.localToGlobal(Offset.zero),
          overlay.localToGlobal(overlay.size.bottomRight(Offset.zero)),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
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
        }),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings),
            title: Text('Role Settings'),
          ),
        ),
      ],
    );
  }

  void _onAppSelected(AppModel app) {
    setState(() {
      selectedApp = app;
    });
  }

  void _onBackToList() {
    setState(() {
      selectedApp = null;
    });
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
            if (selectedApp != null)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _onBackToList,
              ),
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
                : selectedApp != null
                    ? AppWidgetListPage(appId: selectedApp!.id, teamId: widget.teamId)
                    : showRoles
                        ? RolesList(roles: roles)
                        : AppsList(apps: apps, searchQuery: searchQuery, onAppSelected: _onAppSelected),
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
      IconButton(
        icon: const Icon(Icons.group),
        onPressed: () {
          _showCustomMenu(context);
        },
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
