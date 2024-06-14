import 'package:flutter/material.dart';

class Message {
  final String title;
  final String description;
  final String time;
  final String venue;
  final String court;
  final String role;
  final String appName;
  final String action;
  final List<String> participants;

  Message({
    required this.title,
    required this.description,
    required this.time,
    required this.venue,
    required this.court,
    required this.role,
    required this.appName,
    required this.action,
    required this.participants,
  });
}

class TeamMessagesPage extends StatefulWidget {
  const TeamMessagesPage({super.key});

  @override
  _TeamMessagesPageState createState() => _TeamMessagesPageState();
}

class _TeamMessagesPageState extends State<TeamMessagesPage> {
  String searchQuery = '';
  bool showRoles = false;
  bool showAdmins = true;
  bool showPlayers = true;
  bool showSearchBox = false;

  final List<Message> messages = [
    Message(
      title: 'Badminton Event',
      description: 'Badminton playing event',
      time: '2023-06-01 18:00',
      venue: 'Badminton Court',
      court: 'Court 1',
      role: 'players',
      appName: 'BadmintonTeamEvents',
      action: 'Join the team event',
      participants: ['Alice', 'Bob', 'Charlie'],
    ),
    // Add more messages here
  ];

  @override
  Widget build(BuildContext context) {
    final filteredMessages = messages.where((message) {
      final query = searchQuery.toLowerCase();
      final titleMatch = message.title.toLowerCase().contains(query);
      final descriptionMatch = message.description.toLowerCase().contains(query);
      final roleMatch = (showAdmins && message.role == 'admins') ||
          (showPlayers && message.role == 'players');
      return (titleMatch || descriptionMatch) && roleMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            if (showSearchBox)
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            if (!showSearchBox) const Spacer(),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  showSearchBox = !showSearchBox;
                  if (!showSearchBox) {
                    searchQuery = '';
                  }
                });
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.group),
              onSelected: (String value) {
                setState(() {
                  if (value == 'admins') {
                    showAdmins = !showAdmins;
                  } else if (value == 'players') {
                    showPlayers = !showPlayers;
                  }
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                CheckedPopupMenuItem<String>(
                  value: 'admins',
                  checked: showAdmins,
                  child: const Text('Admins'),
                ),
                CheckedPopupMenuItem<String>(
                  value: 'players',
                  checked: showPlayers,
                  child: const Text('Players'),
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          if (showSearchBox) const Divider(),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredMessages.length,
              itemBuilder: (context, index) {
                final message = filteredMessages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: MessageCard(message: message),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MessageCard extends StatefulWidget {
  final Message message;

  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  _MessageCardState createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.message, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${message.title} (${message.role})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    // Handle navigation to a new page
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!isExpanded) ...[
              Text('Time: ${message.time}', maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('Venue: ${message.venue}', maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('Court: ${message.court}', maxLines: 1, overflow: TextOverflow.ellipsis),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isExpanded = true;
                    });
                  },
                  child: const Text('Show More'),
                ),
              ),
            ],
            if (isExpanded) ...[
              Text('Description: ${message.description}'),
              const SizedBox(height: 8),
              Text('Time: ${message.time}'),
              const SizedBox(height: 8),
              Text('Venue: ${message.venue}'),
              const SizedBox(height: 8),
              Text('Court: ${message.court}'),
              const SizedBox(height: 8),
              Text('App: ${message.appName}'),
              const SizedBox(height: 8),
              Text('Action: ${message.action}'),
              const SizedBox(height: 8),
              Text('Participants:'),
              ...message.participants.map((participant) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(participant),
              )).toList(),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle participate action
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                  child: const Text('Join'),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isExpanded = false;
                    });
                  },
                  child: const Text('Show Less'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
