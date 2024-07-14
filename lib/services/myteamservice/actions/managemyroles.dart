import 'package:flutter/material.dart';
import 'package:matchmatter/views/service_action_component.dart';
import 'package:matchmatter/data/service.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageMyRoles extends ServiceActionComponent {
  ManageMyRoles({required String serviceId, required String actionId}) : super(serviceId: serviceId, actionId: actionId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getCurrentTeamId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load team ID: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          String teamId = snapshot.data!;
          return RoleManagementWidget(teamId: teamId);
        } else {
          return Center(child: Text('No team ID found'));
        }
      },
    );
  }

  Future<String?> _getCurrentTeamId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      UserDatabaseService userService = UserDatabaseService(uid: currentUser.uid);
      return await userService.getTeamId();
    }
    return null;
  }
}

class RoleManagementWidget extends StatefulWidget {
  final String teamId;

  RoleManagementWidget({required this.teamId});

  @override
  _RoleManagementWidgetState createState() => _RoleManagementWidgetState();
}

class _RoleManagementWidgetState extends State<RoleManagementWidget> {
  late Future<Team> _teamFuture;
  late Future<List<RoleModel>> _userRolesFuture;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _teamFuture = Team.getTeamData(widget.teamId);
    _userRolesFuture = currentUser != null
        ? Team.getTeamData(widget.teamId).then((team) => team.getUserRoles(currentUser!.uid))
        : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Team>(
      future: _teamFuture,
      builder: (context, teamSnapshot) {
        if (teamSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (teamSnapshot.hasError) {
          return Center(child: Text('Failed to load team data: ${teamSnapshot.error}'));
        } else if (teamSnapshot.hasData) {
          Team team = teamSnapshot.data!;
          return FutureBuilder<List<RoleModel>>(
            future: _userRolesFuture,
            builder: (context, userRolesSnapshot) {
              if (userRolesSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (userRolesSnapshot.hasError) {
                return Center(child: Text('Failed to load user roles: ${userRolesSnapshot.error}'));
              } else if (userRolesSnapshot.hasData) {
                List<RoleModel> userRoles = userRolesSnapshot.data!;
                return ListView.builder(
                  itemCount: team.roles.length,
                  itemBuilder: (context, index) {
                    RoleModel role = team.roles[index];
                    bool isUserInRole = userRoles.any((userRole) => userRole.id == role.id);
                    bool isRoleAdmin = role.creatorId == currentUser?.uid; // Assuming role.creatorId is the admin indicator
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role.name, style: Theme.of(context).textTheme.labelLarge),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text('Actions: ${role.data['actions'] ?? ''}', style: Theme.of(context).textTheme.labelMedium),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (isUserInRole)
                                      Text('Joined', style: TextStyle(color: Colors.grey)),
                                    if (isUserInRole)
                                      IconButton(
                                        icon: Icon(Icons.exit_to_app, color: Colors.blue),
                                        onPressed: () => _leaveRole(role),
                                      ),
                                    if (isRoleAdmin)
                                      SizedBox(width: 8),
                                    if (isRoleAdmin)
                                      Text('Admin', style: TextStyle(color: Colors.grey)),
                                    if (isRoleAdmin)
                                      IconButton(
                                        icon: Icon(Icons.exit_to_app, color: Colors.blue),
                                        onPressed: () => _leaveRole(role),
                                      ),
                                  ],
                                ),
                                if (!isUserInRole && !isRoleAdmin)
                                  GestureDetector(
                                    onTap: () => _joinRole(role),
                                    child: Text('Join Now', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(child: Text('No roles found'));
              }
            },
          );
        } else {
          return Center(child: Text('No team data found'));
        }
      },
    );
  }

  Future<void> _joinRole(RoleModel role) async {
    if (currentUser != null) {
      Team team = await Team.getTeamData(widget.teamId);
      UserModel user = UserModel.fromFirebaseUser(currentUser!);
      await team.addMember(user, roleId: role.id, approverId: currentUser!.uid);
      setState(() {
        _userRolesFuture = team.getUserRoles(currentUser!.uid);
      });
    }
  }

  Future<void> _leaveRole(RoleModel role) async {
    if (currentUser != null) {
      QuerySnapshot userRolesSnapshot = await FirebaseFirestore.instance
          .collection('userroles')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('roleId', isEqualTo: role.id)
          .where('teamId', isEqualTo: widget.teamId)
          .get();

      for (var doc in userRolesSnapshot.docs) {
        await doc.reference.delete();
      }
      setState(() {
        _userRolesFuture = Team.getTeamData(widget.teamId).then((team) => team.getUserRoles(currentUser!.uid));
      });
    }
  }
}
