import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/data/action.dart';

// Enums for different scopes
enum OwnerTeamScope { sole, approved, all }
enum PermissionTeamScope { ownerTeam, approvedTeam, all }

// Class for Service
class Service {
  final String id; // unique id, small case, no space
  final String type; // service, default is service
  final String status; // active, default is active
  final String name;
  final OwnerTeamScope ownerTeamScope; // sole|approved|all, default is all
  final String ownerTeamId;
  final String creatorId;
  final Timestamp createdAt;
  final String description;
  final List<String> tags; // tags of string
  final List<String> approvedOwnerTeamIds; // approved owner team IDs for approved scope
  final List<Permission> permissions; // service permission model list
  final List<Action> actions; // service action model list
  final Map<String, dynamic> data;

  Service({
    required this.id,
    this.type = 'service',
    this.status = 'active',
    String? name,
    this.ownerTeamScope = OwnerTeamScope.all,
    required this.ownerTeamId,
    required this.creatorId,
    required this.createdAt,
    required this.description,
    required this.tags,
    this.approvedOwnerTeamIds = const [],
    required this.permissions,
    required this.actions,
    required this.data,
  }) : name = name ?? id;

  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Service(
      id: data['id'],
      type: data['type'],
      status: data['status'],
      name: data['name'] ?? data['id'],
      ownerTeamScope: OwnerTeamScope.values.firstWhere(
          (e) => e.toString() == 'OwnerTeamScope.${data['ownerTeamScope']}'),
      ownerTeamId: data['ownerTeamId'],
      creatorId: data['creatorId'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      description: data['description'],
      tags: List<String>.from(data['tags']),
      approvedOwnerTeamIds: data['approvedOwnerTeamIds'] != null
          ? List<String>.from(data['approvedOwnerTeamIds'])
          : [],
      permissions: (data['permissions'] as List<dynamic>)
          .map((e) => Permission.fromMap(e as Map<String, dynamic>))
          .toList(),
      actions: (data['actions'] as List<dynamic>)
          .map((e) => Action.fromMap(e as Map<String, dynamic>))
          .toList(),
      data: data['data'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type,
      'status': status,
      'name': name,
      'ownerTeamScope': ownerTeamScope.toString().split('.').last,
      'ownerTeamId': ownerTeamId,
      'creatorId': creatorId,
      'createdAt': createdAt,
      'description': description,
      'tags': tags,
      'approvedOwnerTeamIds': approvedOwnerTeamIds,
      'permissions': permissions.map((e) => e.toMap()).toList(),
      'actions': actions.map((e) => e.toMap()).toList(),
      'data': data,
    };
  }

  static Future<bool> canCreateService({
    required String id,
    required String ownerTeamId,
    required OwnerTeamScope ownerTeamScope,
    List<String>? approvedOwnerTeamIds,
  }) async {
    CollectionReference services = FirebaseFirestore.instance.collection('services');

    if (ownerTeamScope == OwnerTeamScope.sole) {
      QuerySnapshot existingServices = await services.where('id', isEqualTo: id).get();
      return existingServices.docs.isEmpty;
    } else if (ownerTeamScope == OwnerTeamScope.approved) {
      if (approvedOwnerTeamIds == null || !approvedOwnerTeamIds.contains(ownerTeamId)) {
        return false;
      }
      QuerySnapshot existingServices = await services
          .where('id', isEqualTo: id)
          .where('ownerTeamId', isEqualTo: ownerTeamId)
          .get();
      return existingServices.docs.isEmpty;
    } else if (ownerTeamScope == OwnerTeamScope.all) {
      QuerySnapshot existingServices = await services
          .where('id', isEqualTo: id)
          .where('ownerTeamId', isEqualTo: ownerTeamId)
          .get();
      return existingServices.docs.isEmpty;
    }
    return false;
  }

  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('services').doc(id).set(toFirestore());
  }

  static Future<Service?> getServiceData(String serviceId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('services').doc(serviceId).get();
    if (doc.exists) {
      return Service.fromFirestore(doc);
    }
    return null;
  }

  static Future<List<Service>> getAllServices() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('services').get();
    return querySnapshot.docs.map((doc) => Service.fromFirestore(doc)).toList();
  }
}

// Class for Permission
class Permission {
  final String id; // unique id in service, small case, no space
  final String name;
  final String description;
  final PermissionTeamScope teamScope; // ownerTeam|approvedTeam|all, default is all
  final List<String> approvedTeamIds; // if approvedTeam, should list in this field
  final List<String> tags; // tags of string
  final Map<String, dynamic> data;

  Permission({
    required this.id,
    String? name,
    required this.description,
    this.teamScope = PermissionTeamScope.all,
    required this.approvedTeamIds,
    required this.tags,
    required this.data,
  }) : name = name ?? id;

  factory Permission.fromMap(Map<String, dynamic> data) {
    return Permission(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      teamScope: PermissionTeamScope.values.firstWhere(
          (e) => e.toString() == 'PermissionTeamScope.${data['teamScope']}'),
      approvedTeamIds: List<String>.from(data['approvedTeamIds']),
      tags: List<String>.from(data['tags']),
      data: data['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teamScope': teamScope.toString().split('.').last,
      'approvedTeamIds': approvedTeamIds,
      'tags': tags,
      'data': data,
    };
  }
}

// Default permissions
final Permission serviceAdminsPermission = Permission(
  id: 'serviceadmins',
  name: 'Service Admins',
  description: 'default permission for service admins',
  teamScope: PermissionTeamScope.ownerTeam,
  approvedTeamIds: [],
  tags: [],
  data: {},
);

final Permission serviceUsersPermission = Permission(
  id: 'serviceusers',
  name: 'Service Users',
  description: 'default permission for service users',
  teamScope: PermissionTeamScope.all,
  approvedTeamIds: [],
  tags: [],
  data: {},
);

// Function to add default permissions to a service
Future<void> addDefaultPermissions(Service service) async {
  service.permissions.addAll([
    serviceAdminsPermission,
    serviceUsersPermission,
  ]);
  await service.saveToFirestore();
}

// Function to add role permissions
Future<void> addRolePermissions({
  required String teamId,
  required String roleId,
  required String serviceId,
  required String permissionId,
  required String approverId,
  required Map<String, dynamic> status,
}) async {
  CollectionReference roleServicePermissions = FirebaseFirestore.instance.collection('roleservicepermissions');

  QuerySnapshot existingPermissions = await roleServicePermissions
      .where('teamId', isEqualTo: teamId)
      .where('roleId', isEqualTo: roleId)
      .where('serviceId', isEqualTo: serviceId)
      .where('permissionId', isEqualTo: permissionId)
      .get();

  if (existingPermissions.docs.isNotEmpty) {
    // Update existing document
    DocumentReference docRef = existingPermissions.docs.first.reference;
    await docRef.update({
      'approverId': approverId,
      'status': status,
      'joinedAt': Timestamp.now(), // Update join time
    });
  } else {
    // Add new document
    await roleServicePermissions.add({
      'teamId': teamId,
      'roleId': roleId,
      'serviceId': serviceId,
      'permissionId': permissionId,
      'joinedAt': Timestamp.now(),
      'approverId': approverId,
      'status': status,
    });
  }
}

// 获取用户在服务中的权限
Future<Map<String, List<Permission>>> getUserPermissionsInService({
  required String userId,
  required String teamId,
  required String serviceId,
}) async {
  try {
    List<String> userRoles = await UserDatabaseService.getUserRolesInTeam(teamId, userId);
    Map<String, List<Permission>> rolePermissions = {};

    for (String roleId in userRoles) {
      QuerySnapshot rolePermissionsSnapshot = await FirebaseFirestore.instance
          .collection('roleservicepermissions')
          .where('teamId', isEqualTo: teamId)
          .where('roleId', isEqualTo: roleId)
          .where('serviceId', isEqualTo: serviceId)
          .get();

      for (var doc in rolePermissionsSnapshot.docs) {
        String permissionId = doc['permissionId'];
        DocumentSnapshot permissionDoc = await FirebaseFirestore.instance.collection('permissions').doc(permissionId).get();
        if (permissionDoc.exists) {
          Permission permission = Permission.fromMap(permissionDoc.data() as Map<String, dynamic>);
          if (!rolePermissions.containsKey(roleId)) {
            rolePermissions[roleId] = [];
          }
          rolePermissions[roleId]!.add(permission);
        }
      }
    }

    return rolePermissions;
  } catch (e) {
    print('Error getting user permissions in service: $e');
    throw Exception('Failed to get user permissions in service');
  }
}

// 获取用户在服务中的操作
Future<Map<String, List<Action>>> getUserActionsInService({
  required String userId,
  required String teamId,
  required String serviceId,
}) async {
  try {
    List<String> userRoles = await UserDatabaseService.getUserRolesInTeam(teamId, userId);
    Map<String, List<Action>> roleActions = {};

    for (String roleId in userRoles) {
      QuerySnapshot rolePermissionsSnapshot = await FirebaseFirestore.instance
          .collection('roleservicepermissions')
          .where('teamId', isEqualTo: teamId)
          .where('roleId', isEqualTo: roleId)
          .where('serviceId', isEqualTo: serviceId)
          .get();

      for (var doc in rolePermissionsSnapshot.docs) {
        String permissionId = doc['permissionId'];

        // 获取服务中的操作
        Service? service = await Service.getServiceData(serviceId);
        if (service != null) {
          for (var action in service.actions) {
            if (action.permissions.contains(permissionId)) {
              if (!roleActions.containsKey(roleId)) {
                roleActions[roleId] = [];
              }
              if (!roleActions[roleId]!.contains(action)) {
                roleActions[roleId]!.add(action);
              }
            }
          }
        }
      }
    }

    return roleActions;
  } catch (e) {
    print('Error getting user actions in service: $e');
    throw Exception('Failed to get user actions in service');
  }
}
