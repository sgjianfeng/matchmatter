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

  final TextEditingController _teamIdController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamTagController = TextEditingController();

  List<bool> selectedContacts = List.generate(5, (index) => false); // Tracks selection
  bool _isSearching = false; // Tracks if the search is active
  final TextEditingController _searchController = TextEditingController();

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear(); // Clear search when closing
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('New Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              // Handle 'Next' action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '添加团队信息',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _teamIdController,
                      decoration: const InputDecoration(
                        labelText: 'Team ID',
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjusted padding
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _teamNameController,
                      decoration: const InputDecoration(
                        labelText: 'Team Name',
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjusted padding
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _teamTagController,
                      decoration: const InputDecoration(
                        labelText: 'Team Tag',
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjusted padding
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    //const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Contacts',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjusted padding
                ),
                onChanged: (value) {
                  // Implement your search logic here
                },
              ),
            ),
          Expanded(
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
        ],
      ),
    );
  }
}
