import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/app.dart';
import 'package:matchmatter/data/user.dart';

class MatchMatterApp extends AppModel {
  MatchMatterApp({
    required String super.creator,
    required super.ownerTeamId,
  }) : super(
          id: 'matchmatterapp',
          name: 'MatchMatterApp',
          appOwnerScope: AppOwnerScope.sole,
          appUserScope: AppUserScope.any,
          scopeData: {},
          permissions: [],
          createdAt: Timestamp.now(),
        );

  static Future<MatchMatterApp> createOrGet({
    required String creator,
    required String ownerTeamId,
  }) async {
    // Create or get the associated AppModel
    AppModel app = await AppModel.createOrGet(
      id: 'matchmatterapp',
      name: 'MatchMatterApp',
      appOwnerScope: AppOwnerScope.sole,
      appUserScope: AppUserScope.any,
      scopeData: {},
      ownerTeamId: ownerTeamId,
      creator: creator,
    );

    // Convert AppModel to MatchMatterApp
    MatchMatterApp matchMatterApp = MatchMatterApp.fromAppModel(app);

    return matchMatterApp;
  }

  // Factory method to create a MatchMatterApp from an AppModel
  factory MatchMatterApp.fromAppModel(AppModel app) {
    return MatchMatterApp(
      creator: app.creator ?? UserDatabaseService.getCurrentUserId(),
      ownerTeamId: app.ownerTeamId,
    )..permissions.addAll(app.permissions);
  }
}
