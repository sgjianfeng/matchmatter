import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/user.dart';

class MyTeamApp extends AppModel {
  MyTeamApp({
    required String super.creator,
    required super.ownerTeamId,
  }) : super(
          id: 'myteamapp',
          name: 'MyTeamApp',
          appOwnerScope: AppOwnerScope.any,
          appUserScope: AppUserScope.ownerteam,
          scopeData: {},
          permissions: [],
          createdAt: Timestamp.now(),
        );

  static Future<MyTeamApp> createOrGet({
    required String creator,
    required String ownerTeamId,
  }) async {
    // Create or get the associated AppModel
    AppModel app = await AppModel.createOrGet(
      id: 'myteamapp',
      name: 'MyTeamApp',
      appOwnerScope: AppOwnerScope.any,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeamId: ownerTeamId,
      creator: creator,
    );

    // Convert AppModel to MyTeamApp
    MyTeamApp myTeamApp = MyTeamApp.fromAppModel(app);

    // Add default admin role permission if not already added
    await myTeamApp.addDefaultAdminRolePermission();

    return myTeamApp;
  }

  // Factory method to create a MyTeamApp from an AppModel
  factory MyTeamApp.fromAppModel(AppModel app) {
    return MyTeamApp(
      creator: app.creator ?? UserDatabaseService.getCurrentUserId(),
      ownerTeamId: app.ownerTeamId,
    )..permissions.addAll(app.permissions);
  }

  Future<void> addDefaultAdminRolePermission() async {
    // Check if the admin role permission is already added
    bool hasAdminRolePermission = permissions.any((perm) => perm.id == 'adminrole');
    if (!hasAdminRolePermission) {
      permissions.add(
        Permission(
          id: 'adminrole',
          name: 'AdminRole',
          appId: id,
          teamScope: PermissionTeamScope.ownerteam,
          roleScope: PermissionRoleScope.anyrole,
          userScope: PermissionUserScope.anyuser,
          data: {},
        ),
      );
      await saveToFirestore();
    }
  }
}
