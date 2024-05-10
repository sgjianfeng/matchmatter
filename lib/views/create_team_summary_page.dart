import 'package:flutter/material.dart';
import 'package:matchmatter/data/contact.dart';
import 'package:matchmatter/theme.dart'; // 确保导入您的主题配置文件

class CreateTeamSummaryPage extends StatelessWidget {
  final String teamId;
  final String teamName;
  final String teamTag;
  final List<Contact> selectedContacts;

  const CreateTeamSummaryPage({
    Key? key,
    required this.teamId,
    required this.teamName,
    required this.teamTag,
    required this.selectedContacts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 使用Theme.of来获取当前主题

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Team Summary', style: theme.textTheme.headlineSmall),
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
              child: _buildSingleListTile(title: selectedContacts.first.name, subtitle: selectedContacts.first.email, theme: theme, leading: Icons.admin_panel_settings),
              backgroundColor: theme.colorScheme.surfaceVariant,
              context: context,
            ),
            _buildSection(
              title: 'Members',
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: selectedContacts.length,
                itemBuilder: (context, index) {
                  final contact = selectedContacts[index];
                  return _buildSingleListTile(title: contact.name, subtitle: contact.email, theme: theme, leading: Icons.person);
                },
                separatorBuilder: (context, index) => SizedBox(height: 1), // 减小间距
              ),
              backgroundColor: theme.colorScheme.surfaceVariant,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child, required Color backgroundColor, required BuildContext context}) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(6),
      padding: EdgeInsets.all(10),
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
      children: data.map((item) => _buildSingleListTile(title: item.key, subtitle: item.value, theme: theme)).toList(),
    );
  }

  ListTile _buildSingleListTile({required String title, required String subtitle, required ThemeData theme, IconData? leading}) {
    return ListTile(
      leading: leading != null ? Icon(leading) : null,
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0), // 调整垂直内间距为0
    );
  }
}
