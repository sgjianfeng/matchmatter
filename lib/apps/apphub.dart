/*
AppHub initialization:
- Create AppHub team: apphubteam
- Create AppHub app: apphub
  - ownerTeam: apphubteam
  - appAdminScope: onlyOwnerTeam
  - appUseScope: allowAllRole
  - Permissions: appadmins, appmembers, appuseadmins
    - appadmins: Includes operations for managing permissions and roles, enabling, pausing, deactivating, deleting, adding, and removing actions.
    - appmembers: Currently no specific actions for AppHub.
    - appuseadmins: Allows role admins to manage app usage, such as adding app permissions to roles.
  - AppHub appadmins permission matches apphubteam members role.
  - Every role's {role}_radmin role is granted apphub's appuseadmins permission.
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/team.dart';

class AppHub {
  static Future<void> initializeAppHub() async {
    // Create AppHub team if it does not exist
    const String appHubTeamId = 'apphubteam';
    Team? appHubTeam;
    try {
      appHubTeam = await Team.getTeamData(appHubTeamId);
    } catch (e) {
      appHubTeam = Team(
        id: appHubTeamId,
        name: 'AppHub Team',
        description: 'Default team for AppHub',
        createdAt: Timestamp.now(),
        tags: ['default', 'apphub'],
        roles: {
          'admins': [],
          'members': [],
          'admins_radmin': [],
          'members_radmin': [],
        },
      );
      await appHubTeam.saveToFirestore();
    }

    // Create AppHub app if it does not exist
    if (await AppModel.getAppData('apphub') == null) {
      AppModel appHub = AppModel(
        id: 'apphub',
        name: 'AppHub',
        ownerTeam: appHubTeamId,
        appAdminScope: AppAdminScope.onlyOwnerTeam,
        appUseScope: AppUseScope.allowAllRole,
        permissions: {
          'appadmins': ['approve_app', 'reject_app', 'suspend_app', 'delete_app', 'manage_permissions', 'add_action', 'remove_action'],
          'appmembers': [],
          'appuseadmins': ['add_app_permission_to_role', 'remove_app_permission_from_role'],
        },
        meta: {}, // Initialize with empty meta, can be filled as needed
      );

      // Match AppHub members role with appadmins permission
      await appHub.addRoleToApp('members', ['approve_app', 'reject_app', 'suspend_app', 'delete_app', 'manage_permissions', 'add_action', 'remove_action']);
      // Assign appuseadmins to all {role}_radmin
      await appHub.addRoleToApp('admins_radmin', ['add_app_permission_to_role', 'remove_app_permission_from_role']);
      await appHub.addRoleToApp('members_radmin', ['add_app_permission_to_role', 'remove_app_permission_from_role']);
      
      await AppModel.addDefaultPermissions(appHub);
    }
  }
}
