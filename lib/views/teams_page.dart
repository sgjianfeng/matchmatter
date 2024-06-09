import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // 导入 FontAwesome 图标包
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/views/new_team_page.dart';
import 'package:matchmatter/views/team_page.dart';
import 'dart:math';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  bool get wantKeepAlive => true;

  final Map<String, IconData> teamIcons = {
    'Team A': FontAwesomeIcons.footballBall,
    'Team B': FontAwesomeIcons.basketballBall,
    'Team C': FontAwesomeIcons.volleyballBall,
    'Team D': FontAwesomeIcons.hockeyPuck,
    'Team E': FontAwesomeIcons.baseballBall,
    'Team F': FontAwesomeIcons.flagCheckered,
    'Team G': FontAwesomeIcons.running,
    'Team H': FontAwesomeIcons.skiing,
    'Team I': FontAwesomeIcons.swimmer,
    'Team J': FontAwesomeIcons.tableTennis,
    'Team K': FontAwesomeIcons.dumbbell,
    'Team L': FontAwesomeIcons.golfBall,
    'Team M': FontAwesomeIcons.snowboarding,
    'Team N': FontAwesomeIcons.biking,
    'Team P': FontAwesomeIcons.horse,
    'Team R': FontAwesomeIcons.skating,
    'Team T': FontAwesomeIcons.water,
    // Add more team icons here
  };

  void _showNewTeamModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 60),
        child: NewTeamPage(),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  PopupMenuButton<String> _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Padding(
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.menu),
      ),
      offset: const Offset(0, 38),
      onSelected: (String value) {
        switch (value) {
          case 'NewTeam':
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

  Stream<List<Team>> _loadUserTeamsStream() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore.collection('teams').snapshots().asyncMap((snapshot) async {
      List<Team> userTeams = [];
      for (var doc in snapshot.docs) {
        var teamData = doc.data();
        var rolesData = Map<String, List<dynamic>>.from(teamData['roles'] ?? {});

        bool userInTeam = rolesData.entries.any((entry) => entry.value.contains(currentUser!.uid));
        if (userInTeam) {
          var team = Team(
            id: doc.id,
            name: teamData['name'] ?? 'Unknown Team',
            description: teamData['description'],
            createdAt: teamData['createdAt'] ?? Timestamp.now(),
            tags: List<String>.from(teamData['tags'] ?? []),
            roles: rolesData.map((key, value) => MapEntry(key, List<String>.from(value))),
          );
          userTeams.add(team);
        }
      }
      return userTeams;
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () {
              _showNewTeamModal(context);
            },
          ),
          _buildPopupMenu(context),
        ],
      ),
      body: StreamBuilder<List<Team>>(
        stream: _loadUserTeamsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load teams: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final teams = snapshot.data!;
            if (teams.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('You have not joined any teams yet.'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showNewTeamModal(context);
                      },
                      child: const Text('Create a Team'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to a page to join a team
                      },
                      child: const Text('Join a Team'),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  final latestMessage = 'This is a message for team ${team.name}';
                  final messageCount = (10 + index) % 100;
                  final teamMembers = Random().nextInt(11) + 10; // 10 到 20 之间的任意数字

                  IconData teamIcon;
                  if (team.id == 'team6702') {
                    teamIcon = FontAwesomeIcons.flagCheckered;
                  } else if (team.id == 'team6703') {
                    teamIcon = FontAwesomeIcons.footballBall;
                  } else {
                    teamIcon = teamIcons[team.name] ?? FontAwesomeIcons.battleNet;
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        '$teamMembers',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Row(
                      children: [
                        Icon(
                          teamIcon,
                          color: Colors.purpleAccent,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            team.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.tags.join(', '),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          team.description ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            latestMessage,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.message),
                        Text('$messageCount'),
                      ],
                    ),
                    onTap: () {
                      _navigateToTeamDetail(context, team);
                    },
                  );
                },
              );
            }
          } else {
            return const Center(child: Text('No teams found'));
          }
        },
      ),
    );
  }
}
