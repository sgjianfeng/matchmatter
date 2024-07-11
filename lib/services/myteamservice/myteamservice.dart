import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/action.dart';
import 'package:matchmatter/data/service.dart';

class MyTeamService extends Service {
  MyTeamService({
    String id = 'myteamservice',
    String name= 'MyTeamService',
    required String ownerTeamId,
    required String creatorId,
    required String description,
    List<String> tags = const [],
    Map<String, dynamic> data = const {},
  }) : super(
          id: id,
          type: 'service',
          status: 'active',
          ownerTeamScope: OwnerTeamScope.all,
          ownerTeamId: ownerTeamId,
          creatorId: creatorId,
          createdAt: Timestamp.now(),
          description: description,
          tags: tags,
          permissions: _defaultPermissions,
          actions: _defaultActions,
          data: data,
        );

  static final List<Permission> _defaultPermissions = [
    Permission(
      id: 'serviceadmins',
      name: 'Service Admins',
      description: 'Default permission for service admins',
      teamScope: PermissionTeamScope.ownerTeam,
      approvedTeamIds: [],
      tags: [],
      data: {},
    ),
    Permission(
      id: 'serviceusers',
      name: 'Service Users',
      description: 'Default permission for service users',
      teamScope: PermissionTeamScope.all,
      approvedTeamIds: [],
      tags: [],
      data: {},
    ),
  ];

  static final List<Action> _defaultActions = [
    Action(
      id: 'managemyroles',
      name: 'ManageMyRoles',
      title: 'Manage My Roles',
      description: 'Manage my roles in team',
      permissions: ['serviceusers'],
      tags: [],
      data: {},
    ),
    Action(
      id: 'manageteamroles',
      name: 'ManageTeamRoles',
      title: 'Manage Team Roles',
      description: 'Manage team roles',
      permissions: ['serviceadmins'],
      tags: [],
      data: {},
    ),
  ];
}
