import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/views/new_team_page.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showNewTeamModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 60), // 根据需要调整此值
        child: NewTeamPage(),
      ),
      backgroundColor: Colors.transparent, // 设置背景透明以展现内部Padding效果
    );
  }

  PopupMenuButton<String> _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.add_circle_outline),
      onSelected: (String value) {
        switch (value) {
          case 'NewTeam':
            // 显示 NewTeamPage 页面
            _showNewTeamModal(context);

            // showModalBottomSheet(
            //   context: context,
            //   isScrollControlled: true,
            //   backgroundColor: Colors
            //       .transparent, // Ensures no background color for modal itself
            //   builder: (BuildContext context) {
            //     // Wrap with a container to manage padding
            //     return Container(
            //       padding: EdgeInsets.only(
            //           top: MediaQuery.of(context).size.height *
            //               2), // Adjust the top padding
            //       decoration: BoxDecoration(
            //         color:
            //             Colors.white, // Background color for the modal content
            //         borderRadius: BorderRadius.only(
            //           topLeft: Radius.circular(20.0),
            //           topRight: Radius.circular(20.0),
            //         ),
            //       ),
            //       child: const NewTeamPage(), // Your NewTeamPage widget
            //     );
            //   },
            // );
            break;
          case 'Scan':
            // 处理 Scan 选项，暂时留空
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
    return _firestore
        .collection('teams')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Team(
                id: doc.id,
                name: data['name'] ?? 'Unknown Team',
                tags: List<String>.from(data['tags'] ?? []),
                roles: {}, // 这里暂时不加载角色数据
              );
            }).toList());
  }

  void _navigateToTeamDetail(BuildContext context, Team team) {
    Navigator.of(context).pushNamed(
      '/teamDetail',
      arguments: team, // Pass the team data to the team detail page
    );
  }

  // void _navigateToTeamDetail(BuildContext context, Team team) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => TeamPage(team: team),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    //_resetNavigationState(); // 确保在页面构建时重置状态
    return Scaffold(
      //appBar: AppBar(title: Text('Teams')),
      appBar: AppBar(
        title: Text('Teams'),
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
                  subtitle: Text(team.tags.join(', ')), // 显示标签
                  trailing: Icon(Icons.arrow_forward_ios),
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
