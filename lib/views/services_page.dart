import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/service.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/data/action.dart' as mm;
import 'package:matchmatter/views/service_action_page.dart';
import 'package:matchmatter/views/services_list.dart';
import 'package:matchmatter/views/service_action_list_page.dart';
import 'package:matchmatter/views/services_appbar.dart';
import 'package:matchmatter/views/roles_list.dart';

class ServicesPage extends StatefulWidget {
  final String teamId;
  final UserModel? user;

  const ServicesPage({super.key, required this.teamId, this.user});

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String searchQuery = '';
  bool showRoles = false;
  bool showSearchBar = false;
  List<Service> services = [];
  List<RoleModel> roles = [];
  bool isLoading = true;
  late UserModel currentUser;
  Set<String> selectedRoles = {};
  Service? selectedService;
  mm.Action? selectedAction;
  List<String> selectedRolesForAction = [];
  GlobalKey _menuKey = GlobalKey();

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
    }
  }

  Future<void> _fetchData() async {
    try {
      final userRoles = await UserDatabaseService.getUserRolesInTeam(widget.teamId, currentUser.uid);
      final userServices = await UserDatabaseService.getUserServicesInTeam(widget.teamId, currentUser.uid);

      final services = await _mapUserServices(userServices);
      final roles = _mapUserRoles(userRoles);

      setState(() {
        this.services = services;
        this.roles = roles;
        selectedRoles.addAll(roles.map((role) => role.id));
        isLoading = false;
      });

      print('User roles: ${roles.map((role) => role.name).toList()}');
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Service>> _mapUserServices(Map<String, List<String>> userServices) async {
    Set<String> serviceIds = userServices.values.expand((ids) => ids).toSet();
    List<Service> services = [];

    for (String serviceId in serviceIds) {
      Service? service = await Service.getServiceData(serviceId);
      if (service != null) {
        services.add(service);
      }
    }

    return services;
  }

  List<RoleModel> _mapUserRoles(List<String> userRoles) {
    return userRoles.map((roleId) {
      return RoleModel(
        id: roleId,
        name: roleId,
        teamId: widget.teamId,
        data: {},
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
      _updateServicesForSelectedRoles();
    });
  }

  Future<void> _updateServicesForSelectedRoles() async {
    if (selectedRoles.isEmpty) {
      setState(() {
        services = [];
      });
      return;
    }

    final userServices = await UserDatabaseService.getUserServicesInTeam(widget.teamId, currentUser.uid);
    Set<String> selectedServiceIds = userServices.entries
        .where((entry) => selectedRoles.contains(entry.key))
        .expand((entry) => entry.value)
        .toSet();

    List<Service?> updatedServices = await Future.wait(
      selectedServiceIds.map((serviceId) => Service.getServiceData(serviceId)),
    );

    setState(() {
      services = updatedServices.whereType<Service>().toList();
    });
  }

  void _showCustomMenu(BuildContext context) async {
    final RenderBox renderBox = _menuKey.currentContext?.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height * 2,
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

  void _onServiceSelected(Service service) {
    setState(() {
      selectedService = service;
      selectedAction = null;
    });
  }

  void _onActionSelected(mm.Action action, List<String> roleIds) {
    setState(() {
      selectedAction = action;
      selectedRolesForAction = roleIds;
    });
  }

  void _onBackToList() {
    setState(() {
      if (selectedAction != null) {
        selectedAction = null;
      } else {
        selectedService = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ServicesAppBar(
        title: selectedAction != null
            ? selectedAction!.title
            : selectedService != null
                ? selectedService!.name
                : '',
        showBackButton: selectedService != null,
        onBackButtonPressed: _onBackToList,
        onSearchIconPressed: () {
          setState(() {
            showSearchBar = !showSearchBar;
          });
        },
        onGroupIconPressed: () {
          _showCustomMenu(context);
        },
        menuKey: _menuKey,
      ),
      body: Column(
        children: [
          Divider(thickness: 1.0, color: Colors.grey.withOpacity(0.5), height: 1.0),
          if (showSearchBar) _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedService != null
                    ? selectedAction != null
                        ? ServiceActionPage(service: selectedService!, action: selectedAction!, teamId: widget.teamId, roles: selectedRolesForAction)
                        : ServiceActionListPage(service: selectedService!, teamId: widget.teamId, onActionSelected: (action, roleIds) {
                            _onActionSelected(action, roleIds);
                          })
                    : showRoles
                        ? RolesList(roles: roles)
                        : ServicesList(services: services, searchQuery: searchQuery, onServiceSelected: _onServiceSelected),
          ),
        ],
      ),
    );
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
