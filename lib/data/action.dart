import 'package:cloud_firestore/cloud_firestore.dart';

class Action {
  final String id; // unique id in service
  final String name;
  final String title;
  final String description;
  final List<String> permissions; // permission ids to allow access
  final List<String> tags; // tags of string
  final Map<String, dynamic> data;

  Action({
    required this.id,
    String? name,
    required this.title,
    required this.description,
    required this.permissions,
    required this.tags,
    required this.data,
  }) : name = name ?? id;

  factory Action.fromMap(Map<String, dynamic> data) {
    return Action(
      id: data['id'],
      name: data['name'],
      title: data['title'],
      description: data['description'],
      permissions: List<String>.from(data['permissions']),
      tags: List<String>.from(data['tags']),
      data: data['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'permissions': permissions,
      'tags': tags,
      'data': data,
    };
  }
}
