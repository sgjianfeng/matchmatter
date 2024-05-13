import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:matchmatter/data/contact.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';
// 确保导入您的主题配置文件

class CreateTeamSummaryPage extends StatelessWidget {
  final String teamId;
  final String teamName;
  final String teamTag;
  final List<Contact> selectedContacts;

  const CreateTeamSummaryPage({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.teamTag,
    required this.selectedContacts,
  });

  // 在 CreateTeamSummaryPage 类中添加一个新的方法
  void _createTeamInFirestore(BuildContext context) async {
    try {
      List<String> memberIds =
          selectedContacts.map((contact) => contact.uid).toList();
      List<String> adminIds = [selectedContacts.first.uid]; // 假设第一个联系人是管理员

      // 异步获取所有成员的完整用户数据
      List<UserModel> members = await Future.wait(
          memberIds.map((id) => UserDatabaseService(uid: id).getUserData()));

      // 创建团队实例
      Team newTeam = Team(
        id: teamId,
        name: teamName,
        tags: [teamTag],
        roles: {
          'admins':
              members.where((user) => adminIds.contains(user.uid)).toList(),
          'members': members,
        },
      );

      // 存储到 Firestore
      await FirebaseFirestore.instance.collection('teams').doc(newTeam.id).set({
        'name': newTeam.name,
        'tags': newTeam.tags,
        'admins': newTeam.roles['admins']!.map((user) => user.uid).toList(),
        'members': newTeam.roles['members']!.map((user) => user.uid).toList(),
      });

      // 可选：展示成功消息或处理其他逻辑
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Team successfully created!'),
        duration: Duration(seconds: 2),
      ));

      // 延迟后导航回团队列表
      await Future.delayed(const Duration(seconds: 1));
      //Navigator.pop(context); // 导航回团队列表页
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      // 处理错误
      if (kDebugMode) {
        print('Error creating team: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to create team.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 使用Theme.of来获取当前主题

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Create Team Summary', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(
                Icons.done_rounded), // Replace with your desired icon
            onPressed: () {
              _createTeamInFirestore(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Team Information',
              child: _buildListTiles(theme, [
                MapEntry('Team ID', teamId),
                MapEntry('Team Name', teamName),
                MapEntry('Team Tag', teamTag),
              ]),
              backgroundColor: theme.colorScheme.primaryContainer,
              context: context,
            ),
            _buildSection(
              title: 'Admins',
              child: _buildSingleListTile(
                  title: selectedContacts.first.name,
                  subtitle: selectedContacts.first.email,
                  theme: theme,
                  leading: Icons.admin_panel_settings),
              backgroundColor: theme.colorScheme.surfaceVariant,
              context: context,
            ),
            _buildSection(
              title: 'Members',
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedContacts.length,
                itemBuilder: (context, index) {
                  final contact = selectedContacts[index];
                  return _buildSingleListTile(
                      title: contact.name,
                      subtitle: contact.email,
                      theme: theme,
                      leading: Icons.person);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 1), // 减小间距
              ),
              backgroundColor: theme.colorScheme.surfaceVariant,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required Widget child,
      required Color backgroundColor,
      required BuildContext context}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          child,
        ],
      ),
    );
  }

  Widget _buildListTiles(ThemeData theme, List<MapEntry<String, String>> data) {
    return Column(
      children: data
          .map((item) => _buildSingleListTile(
              title: item.key, subtitle: item.value, theme: theme))
          .toList(),
    );
  }

  ListTile _buildSingleListTile(
      {required String title,
      required String subtitle,
      required ThemeData theme,
      IconData? leading}) {
    return ListTile(
      leading: leading != null ? Icon(leading) : null,
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 0), // 调整垂直内间距为0
    );
  }
}
