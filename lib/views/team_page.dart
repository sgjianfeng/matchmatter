import 'package:flutter/material.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/providers/bottom_navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:matchmatter/views/apps_page_demo1.dart';
import 'package:matchmatter/views/team_profile_page.dart';

class TeamPage extends StatefulWidget {
  final Team team;

  const TeamPage({super.key, required this.team});

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  late Future<Map<String, List<UserModel>>> rolesFuture;

  @override
  void initState() {
    super.initState();
    rolesFuture = _loadRoles();
  }

  Future<Map<String, List<UserModel>>> _loadRoles() async {
    return Team.getTeamRoles(widget.team.roles);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            widget.team.name,
            style: const TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.purple,
            tabs: [
              Tab(text: 'Messages'),
              Tab(text: 'Chats'),
              Tab(text: 'Apps'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, List<UserModel>>>(
          future: rolesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load roles: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return TabBarView(
                children: [
                  _buildMessagesTab(),
                  _buildChatsTab(),
                  AppsPage(teamId: widget.team.id, user: null),  // Pass teamId to AppsPage
                  TeamProfilePage(
                    team: widget.team,
                    roles: snapshot.data!,
                  ),
                ],
              );
            } else {
              return const Center(child: Text('No roles found'));
            }
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: Provider.of<BottomNavigationProvider>(context).currentIndex,
          onTap: (index) {
            Provider.of<BottomNavigationProvider>(context, listen: false).setCurrentIndex(index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Teams'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: 'Matches'),
            BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return ListView(
      children: [
        ListTile(title: Text('Messages for ${widget.team.name}')),
        // Add message-related content here
      ],
    );
  }

  Widget _buildChatsTab() {
    return ListView(
      children: [
        ListTile(title: Text('Chats for ${widget.team.name}')),
        // Add chat-related content here
      ],
    );
  }
}
