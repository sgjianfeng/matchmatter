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
      title: '羽毛球打球活动',
      description: '羽毛球打球活动',
      time: '2023-06-01 18:00',
      venue: '羽毛球馆',
      court: 'Court 1',
      role: 'players',
      appName: 'BadmintonTeamEvents',
      action: '参加团队打球',
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
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
          const Divider(), // Ensure the divider is always displayed
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
              ],
            ),
            const SizedBox(height: 8),
            if (!isExpanded) ...[
              Text('时间: ${message.time}', maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('地点: ${message.venue}', maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('场地: ${message.court}', maxLines: 1, overflow: TextOverflow.ellipsis),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isExpanded = true;
                    });
                  },
                  child: const Text('显示更多'),
                ),
              ),
            ],
            if (isExpanded) ...[
              Text('描述: ${message.description}'),
              const SizedBox(height: 8),
              Text('时间: ${message.time}'),
              const SizedBox(height: 8),
              Text('地点: ${message.venue}'),
              const SizedBox(height: 8),
              Text('场地: ${message.court}'),
              const SizedBox(height: 8),
              Text('App: ${message.appName}'),
              const SizedBox(height: 8),
              Text('Action: ${message.action}'),
              const SizedBox(height: 8),
              Text('参加者:'),
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
                  child: const Text('参加'),
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
                  child: const Text('收起'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
