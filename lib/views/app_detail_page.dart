import 'package:flutter/material.dart';
import 'package:matchmatter/data/app.dart';

class AppDetailPage extends StatefulWidget {
  final AppModel app;

  const AppDetailPage({super.key, required this.app});

  @override
  _AppDetailPageState createState() => _AppDetailPageState();
}

class _AppDetailPageState extends State<AppDetailPage> {
  bool showAdmins = true;
  bool showPlayers = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 2, // Set the initial tab to "Apps"
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            widget.app.name.length > 10
                ? '${widget.app.name.substring(0, 10)}...'
                : widget.app.name,
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
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Handle search action
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Handle search action
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
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
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
              const Divider(),
              _buildAppInfoSection(),
              const SizedBox(height: 20),
              _buildActionsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.apps, color: Colors.blue),
                const SizedBox(width: 8.0),
                Text(
                  widget.app.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text('Owner: ${widget.app.ownerTeamId}'),
            const SizedBox(height: 4.0),
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                  'Roles: ${widget.app.permissions.map((perm) => perm.name).join(', ')}'),
            ),
            const SizedBox(height: 4.0),
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.lightGreenAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(widget.app.description ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    List<Widget> actions = [];
    if (showAdmins) {
      actions.add(
        _buildAdminAction(
          context,
          title: '发布团队打球活动 (Admins)',
        ),
      );
    }
    if (showPlayers) {
      actions.add(
        _buildPlayerAction(
          context,
          title: '参加团队打球活动 (Players)',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions,
    );
  }

  Widget _buildAdminAction(BuildContext context, {required String title}) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8.0),
                TextField(
                  decoration: const InputDecoration(
                    labelText: '地址',
                    labelStyle: TextStyle(fontSize: 14),
                  ),
                  style: const TextStyle(fontSize: 14),
                  controller: TextEditingController(text: '123 Court St'),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  decoration: const InputDecoration(
                    labelText: '场地',
                    labelStyle: TextStyle(fontSize: 14),
                  ),
                  style: const TextStyle(fontSize: 14),
                  controller: TextEditingController(text: 'Court 1'),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  decoration: const InputDecoration(
                    labelText: '时间',
                    labelStyle: TextStyle(fontSize: 14),
                  ),
                  style: const TextStyle(fontSize: 14),
                  controller: TextEditingController(text: '10:00 AM'),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle publish action
                  },
                  child: const Text('发布活动'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerAction(BuildContext context, {required String title}) {
    List<String> participants = ['Alice', 'Bob', 'Charlie'];

    return Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8.0),
                Text('地址: 123 Court St'),
                const SizedBox(height: 4.0),
                Text('场地: Court 1'),
                const SizedBox(height: 4.0),
                Text('时间: 10:00 AM'),
                const Divider(),
                const SizedBox(height: 8.0),
                Text('参加者:', style: const TextStyle(fontWeight: FontWeight.bold)),
                ...participants.map((participant) => Text(participant)).toList(),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle add to participant list action
                  },
                  child: const Text('加入活动'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
