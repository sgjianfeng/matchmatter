import 'package:flutter/material.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/views/team_profile_page.dart';
import 'package:provider/provider.dart';
import '../providers/bottom_navigation_provider.dart';

class TeamPage extends StatefulWidget {
  final Team team;

  const TeamPage({Key? key, required this.team}) : super(key: key);

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
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
        body: TabBarView(
          children: [
            _buildMessagesTab(),
            _buildChatsTab(),
            _buildAppsTab(),
            //_buildProfileTab(context), // Pass context here
            TeamProfilePage(team: widget.team), // Include the profile widget
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex:
              Provider.of<BottomNavigationProvider>(context).currentIndex,
          onTap: (index) {
            Provider.of<BottomNavigationProvider>(context, listen: false)
                .setCurrentIndex(index);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Teams'),
            BottomNavigationBarItem(
                icon: Icon(Icons.sports_soccer), label: 'Matches'),
            BottomNavigationBarItem(
                icon: Icon(Icons.contacts), label: 'Contacts'),
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

  Widget _buildAppsTab() {
    return const Center(child: Text('Apps content goes here'));
  }

  Widget _buildProfileTab(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('Profile for ${widget.team.name}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamProfilePage(team: widget.team),
              ),
            );
          },
        ),
        // Add other profile-related content here
      ],
    );
  }
}
