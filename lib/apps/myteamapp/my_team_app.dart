import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/app.dart';

class MyTeamApp extends AppModel {
  MyTeamApp({
    required String creator,
    required OwnerTeamModel ownerTeam,
  }) : super(
          id: 'myteamapp',
          name: 'MyTeamApp',
          appownerscope: AppOwnerScope.any,
          appuserscope: AppUserScope.ownerteam,
          scopeData: {},
          ownerTeam: ownerTeam,
          permissions: [], // Initialize with an empty list of permissions
          creator: creator,
          createdAt: Timestamp.now(),
        );

  static Future<MyTeamApp> createOrGet({
    required String creator,
    required OwnerTeamModel ownerTeam,
  }) async {
    AppModel app = await AppModel.createOrGet(
      id: 'myteamapp',
      name: 'MyTeamApp',
      appOwnerScope: AppOwnerScope.any,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeam: ownerTeam,
      creator: creator,
    );

    MyTeamApp myTeamApp = MyTeamApp.fromAppModel(app);

    // Add default adminrole permission to MyTeamApp
    await myTeamApp.addDefaultAdminRolePermission();

    return myTeamApp;
  }

  // Factory method to create a MyTeamApp from an AppModel
  factory MyTeamApp.fromAppModel(AppModel app) {
    return MyTeamApp(
      creator: app.creator,
      ownerTeam: app.ownerTeam,
    );
  }

  Future<void> addDefaultAdminRolePermission() async {
    permissions.add(
      Permission(
        id: 'adminrole',
        name: 'AdminRole',
        appId: id,
        actions: [],
        teamScope: PermissionTeamScope.ownerteam,
        roleScope: PermissionRoleScope.anyrole,
        userScope: PermissionUserScope.anyuser,
        data: {},
      ),
    );
    await saveToFirestore();
  }
}
