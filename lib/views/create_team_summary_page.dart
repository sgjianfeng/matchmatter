import 'package:flutter/material.dart';
import 'package:matchmatter/data/contact.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Team Summary'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Team ID'),
            subtitle: Text(teamId),
          ),
          ListTile(
            title: Text('Team Name'),
            subtitle: Text(teamName),
          ),
          ListTile(
            title: Text('Team Tag'),
            subtitle: Text(teamTag),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedContacts.length,
              itemBuilder: (context, index) {
                // Assuming Contact class has 'name' and 'email' fields
                final contact = selectedContacts[index];
                return ListTile(
                  title: Text(contact.name),  // Displaying the contact's name
                  subtitle: Text(contact.email),  // Optionally displaying the email as a subtitle
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
