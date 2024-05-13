import 'package:flutter/material.dart';
import 'package:matchmatter/data/team.dart';
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(widget.team.name, style: TextStyle(color: Colors.black)),
          iconTheme: IconThemeData(color: Colors.black),
          bottom: TabBar(
            labelColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.purple,
            tabs: [
              Tab(text: 'Chat'),
              Tab(text: 'Details'),
              Tab(text: 'Apps'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChatTab(), // Chat tab
            _buildDetailsTab(), // Details tab
            _buildAppsTab(), // Apps tab
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex:
              Provider.of<BottomNavigationProvider>(context).currentIndex,
          onTap: (index) {
            Provider.of<BottomNavigationProvider>(context, listen: false)
                .setCurrentIndex(index);
          },
          items: [
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

  Widget _buildChatTab() {
    return ListView(
      children: [
        ListTile(title: Text('Meeting details for ${widget.team.name}')),
        ...widget.team.tags.map((tag) => ListTile(title: Text(tag))).toList(),
        _buildMessageComposer(),
      ],
    );
  }

  Widget _buildMessageComposer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      children: [
        ListTile(title: Text('Team ID: ${widget.team.id}')),
        ListTile(
            title:
                Text('Members: ${widget.team.roles['members']?.join(', ')}')),
        ListTile(
            title: Text('Admins: ${widget.team.roles['admins']?.join(', ')}')),
      ],
    );
  }

  Widget _buildAppsTab() {
    return Center(child: Text('Apps content goes here'));
  }
}
