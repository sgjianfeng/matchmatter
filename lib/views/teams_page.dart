import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/views/new_team_page.dart';
import 'package:matchmatter/views/team_page.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  bool get wantKeepAlive => true;

  void _showNewTeamModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 60), // Adjust this value as needed
        child: NewTeamPage(),
      ),
      backgroundColor: Colors.transparent, // Set background transparent to show the padding effect
    );
  }

  PopupMenuButton<String> _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Padding(
        padding: EdgeInsets.only(right: 20), // Set the left padding to adjust the position
        child: Icon(Icons.menu),
      ),
      offset: const Offset(0, 38), // Adjust the offset to move the menu downwards
      onSelected: (String value) {
        switch (value) {
          case 'NewTeam':
            // Show NewTeamPage
            _showNewTeamModal(context);
            break;
          case 'Scan':
            // Handle Scan option, currently empty
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'NewTeam',
          child: Text('New Team'),
        ),
        const PopupMenuItem<String>(
          value: 'Scan',
          child: Text('Scan'),
        ),
      ],
    );
  }

  Stream<List<Team>> _loadTeamsStream() {
    return _firestore.collection('teams').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Team(
          id: doc.id,
          name: data['name'] ?? 'Unknown Team',
          description: data['description'], // Optional description
          createdAt: data['createdAt'] ?? Timestamp.now(),
          tags: List<String>.from(data['tags'] ?? []),
          roles: {}, // Not loading roles data here
        );
      }).toList();
    });
  }

  void _navigateToTeamDetail(BuildContext context, Team team) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TeamPage(team: team),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        actions: <Widget>[
          _buildPopupMenu(context),
        ],
      ),
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
                  subtitle: Text(team.tags.join(', ')), // Display tags
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _navigateToTeamDetail(context, team);
                  },
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
