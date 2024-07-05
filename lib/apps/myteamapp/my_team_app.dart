import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/user.dart';

class MyTeamApp extends AppModel {
  MyTeamApp({
    required String creator,
    required String ownerTeamId,
  }) : super(
          id: 'myteamapp',
          name: 'MyTeamApp',
          appOwnerScope: AppOwnerScope.any,
          appUserScope: AppUserScope.ownerteam,
          scopeData: {},
          permissions: [],
          createdAt: Timestamp.now(),
          ownerTeamId: ownerTeamId,
          creator: creator,
          appWidgetList: [], // Initialize as empty list
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

    // Check if the appWidgetList is empty and add default widgets if necessary
    if (myTeamApp.appWidgetList.isEmpty) {
      myTeamApp.appWidgetList = _defaultWidgets();
      await myTeamApp.saveToFirestore();
    }

    return myTeamApp;
  }

  // Factory method to create a MyTeamApp from an AppModel
  factory MyTeamApp.fromAppModel(AppModel app) {
    return MyTeamApp(
      creator: app.creator ?? UserDatabaseService.getCurrentUserId(),
      ownerTeamId: app.ownerTeamId,
    )..permissions.addAll(app.permissions);
  }

  @override
  List<AppWidget> getAppWidgetList() {
    return appWidgetList;
  }

  // Method to define default widgets
  static List<AppWidget> _defaultWidgets() {
    return [
      AppWidget(
        name: 'myroles',
        title: 'My Roles',
        permissions: ['appusers'],
        description: 'My roles in team',
      ),
      AppWidget(
        name: 'teamroles',
        title: 'Team Roles',
        permissions: ['appadmins'],
        description: 'Manage team roles',
      ),
    ];
  }
}
