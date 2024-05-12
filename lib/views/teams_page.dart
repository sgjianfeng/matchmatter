import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/team.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  Stream<List<Team>> _loadTeamsStream() {
    return _firestore
        .collection('teams')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Team(
                id: doc.id,
                name: data['name'] ?? 'Unknown Team',
                tags: List<String>.from(data['tags'] ?? []),
                roles: {}, // 这里暂时不加载角色数据
              );
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Teams')),
      body: StreamBuilder<List<Team>>(
        stream: _loadTeamsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load teams'));
          } else if (snapshot.hasData) {
            final teams = snapshot.data!;
            return ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(team.name),
                  subtitle: Text(team.tags.join(', ')), // 显示标签
                );
              },
            );
          } else {
            return const Center(child: Text('No teams found'));
          }
        },
      ),
    );
  }
}
