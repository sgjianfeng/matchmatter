import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/service.dart';

class MatchMatterService extends Service {
  MatchMatterService({
    String id = 'matchmatterservice',
    String name = 'MatchMatterService',
    required String ownerTeamId,
    required String creatorId,
    required String description,
    List<String> tags = const [],
    Map<String, dynamic> data = const {},
  }) : super(
          id: id,
          type: 'service',
          status: 'active',
          ownerTeamScope: OwnerTeamScope.sole,
          ownerTeamId: ownerTeamId,
          creatorId: creatorId,
          createdAt: Timestamp.now(),
          description: description,
          tags: tags,
          permissions: _defaultPermissions,
          actions: [],
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
}
