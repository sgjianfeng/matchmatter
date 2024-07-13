import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/team.dart';

class TeamProfilePage extends StatefulWidget {
  final String teamId;

  const TeamProfilePage({super.key, required this.teamId});

  @override
  _TeamProfilePageState createState() => _TeamProfilePageState();
}

class _TeamProfilePageState extends State<TeamProfilePage> {
  late Future<Team> _teamFuture;

  @override
  void initState() {
    super.initState();
    _teamFuture = _fetchTeam();
  }

  Future<Team> _fetchTeam() async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance.collection('teams').doc(widget.teamId).get();

    if (!docSnapshot.exists) {
      throw Exception('Team does not exist');
    }

    var data = docSnapshot.data()!;
    var rolesData = data['roles'] ?? {};

    return Team(
      id: widget.teamId,
      name: data['name'] ?? 'Unknown Team',
      description: data['description'] ?? 'No description available',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      tags: data['tags']?.cast<String>() ?? [],
      roles: rolesData.map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 不显示返回按钮
        title: const Text('Team Profile'),
      ),
      body: FutureBuilder<Team>(
        future: _teamFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load team: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final team = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team ID: ${team.id}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Team Name: ${team.name}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Description: ${team.description ?? 'No description available'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created At: ${team.createdAt.toDate()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tags: ${team.tags.join(', ')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No team found'));
          }
        },
      ),
    );
  }
}
