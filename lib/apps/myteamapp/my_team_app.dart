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
    // Create or get the associated AppModel
    AppModel app = await AppModel.createOrGet(
      id: 'myteamapp',
      name: 'MyTeamApp',
      appOwnerScope: AppOwnerScope.any,
      appUserScope: AppUserScope.ownerteam,
      scopeData: {},
      ownerTeam: ownerTeam,
      creator: creator,
    );

    // Convert AppModel to MyTeamApp
    MyTeamApp myTeamApp = MyTeamApp.fromAppModel(app);

    // Add default adminrole permission to MyTeamApp if not already added
    await myTeamApp.addDefaultAdminRolePermission();

    return myTeamApp;
  }

  // Factory method to create a MyTeamApp from an AppModel
  factory MyTeamApp.fromAppModel(AppModel app) {
    return MyTeamApp(
      creator: app.creator,
      ownerTeam: app.ownerTeam,
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

  @override
  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('myteamapps').doc(id).set(toFirestore());
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'appownerscope': appownerscope.toString().split('.').last,
      'appuserscope': appuserscope.toString().split('.').last,
      'scopeData': scopeData,
      'ownerTeam': ownerTeam.toMap(),
      'permissions': permissions.map((e) => e.toMap()).toList(),
      'creator': creator,
      'createdAt': createdAt,
    };
  }
}
