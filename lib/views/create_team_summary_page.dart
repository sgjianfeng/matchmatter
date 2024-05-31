import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matchmatter/data/contact.dart';
import 'package:matchmatter/data/team.dart';
import 'package:matchmatter/data/user.dart';

class CreateTeamSummaryPage extends StatelessWidget {
  final String teamId;
  final String teamName;
  final String teamTag;
  final String? description;
  final List<Contact> selectedContacts;

  const CreateTeamSummaryPage({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.teamTag,
    this.description,
    required this.selectedContacts,
  });

  Future<void> _createTeamInFirestore(BuildContext context) async {
    try {
      List<String> memberIds = selectedContacts.map((contact) => contact.uid).toList();
      String adminId = selectedContacts.first.uid; // First contact is admin

      List<UserModel> members = await Future.wait(
        memberIds.map((id) => UserDatabaseService(uid: id).getUserData())
      );

      // Get admin user directly from adminId
      UserModel admin = await UserDatabaseService(uid: adminId).getUserData();

      // Create roles
      var roles = {
        'admins': [admin.uid!],
        'members': members.map((user) => user.uid!).toSet().toList(),
      };

      print('Roles before saving: $roles');

      Team newTeam = Team(
        id: teamId,
        name: teamName,
        description: description,
        createdAt: Timestamp.now(),
        tags: [teamTag],
        roles: roles,
      );

      await newTeam.saveToFirestore(admin.uid!);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Team successfully created!'),
        duration: Duration(seconds: 2),
      ));

      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print('Error creating team: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to create team.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Team Summary', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_rounded),
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
                if (description != null) MapEntry('Description', description!),
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
                leading: Icons.admin_panel_settings,
              ),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
                    leading: Icons.person,
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 1),
              ),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required Color backgroundColor,
    required BuildContext context,
  }) {
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
      children: data.map((item) => _buildSingleListTile(
        title: item.key,
        subtitle: item.value,
        theme: theme,
      )).toList(),
    );
  }

  ListTile _buildSingleListTile({
    required String title,
    required String subtitle,
    required ThemeData theme,
    IconData? leading,
  }) {
    return ListTile(
      leading: leading != null ? Icon(leading) : null,
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
    );
  }
}
