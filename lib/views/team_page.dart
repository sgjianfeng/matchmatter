import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/providers/bottom_navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:matchmatter/views/services_page.dart';
import 'package:matchmatter/views/team_profile_page.dart';
import 'package:matchmatter/views/team_messages_page.dart'; // Import the TeamMessagesPage

class TeamPage extends StatefulWidget {
  final Team team;

  const TeamPage({super.key, required this.team});

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {

  @override
  void initState() {
    super.initState();
    _setCurrentTeamId();
  }

  Future<void> _setCurrentTeamId() async {
    await UserDatabaseService(uid: FirebaseAuth.instance.currentUser?.uid).setTeamId(widget.team.id);
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
              Tab(text: 'Services'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const TeamMessagesPage(),  // Use the TeamMessagesPage here
            _buildChatsTab(),
            ServicesPage(teamId: widget.team.id, user: null),  // Pass teamId to ServicesPage
            TeamProfilePage(
              teamId: widget.team.id,
            ),
          ],
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

  Widget _buildChatsTab() {
    return ListView(
      children: [
        ListTile(title: Text('Chats for ${widget.team.name}')),
        // Add chat-related content here
      ],
    );
  }
}
