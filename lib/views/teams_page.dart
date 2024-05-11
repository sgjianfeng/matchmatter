import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<String>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    _teamsFuture = _loadTeams();
  }

  Future<List<String>> _loadTeams() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('teams').get();
      return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print('Error loading teams: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teams'),
      ),
      body: FutureBuilder<List<String>>(
        future: _teamsFuture,
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
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(teams[index]),
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
