import 'package:flutter/material.dart';

class NewTeamPage extends StatefulWidget {
  const NewTeamPage({super.key});

  @override
  _NewTeamPageState createState() => _NewTeamPageState();
}

class _NewTeamPageState extends State<NewTeamPage> {
  List<String> contacts = [
    "Account- Siew Leen",
    "Agnes",
    "Alvin Capital Land",
    "fion ang prudential",
    "Angela"
  ]; // Example contacts
  List<bool> selectedContacts =
      List.generate(5, (index) => false); // Tracks selection

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('New Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              // Handle 'Next' action
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.9, // Adjust the fraction as needed
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                child: Text(contacts[index][0]), // Display the first letter
              ),
              title: Text(contacts[index]),
              trailing: Checkbox(
                value: selectedContacts[index],
                onChanged: (bool? value) {
                  setState(() {
                    selectedContacts[index] = value!;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
