import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/service.dart';


// Class for MyTeamService
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
          widgets: _defaultWidgets,
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
      teamScope: PermissionTeamScope.ownerTeam, //only able to assign to owner team roles
      approvedTeamIds: [],
      tags: [],
      data: {},
    ),
  ];

  static final List<ServiceWidget> _defaultWidgets = [
    ServiceWidget(
      id: 'myroles',
      name: 'myroles',
      title: 'My Roles',
      description: 'My roles in team',
      permissions: ['serviceusers'],
      tags: [],
      data: {},
    ),
    ServiceWidget(
      id: 'teamroles',
      name: 'teamroles',
      title: 'Team Roles',
      description: 'Manage team roles',
      permissions: ['serviceadmins'],
      tags: [],
      data: {},
    ),
  ];
}
