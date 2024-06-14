import 'package:flutter/material.dart';

class Match {
  final String title;
  final String subtitle;
  final String description;
  final String venue;
  final String time;
  final String team;
  final String type;
  final String sponsor;
  final List<String> participants;

  Match({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.venue,
    required this.time,
    required this.team,
    required this.type,
    required this.sponsor,
    this.participants = const [],
  });
}

class VenueRental {
  final String title;
  final String description;
  final String venue;
  final String time;
  final String team;
  final String price;
  final String deadline;

  VenueRental({
    required this.title,
    required this.description,
    required this.venue,
    required this.time,
    required this.team,
    required this.price,
    required this.deadline,
  });
}

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final List<dynamic> items = List.generate(30, (index) {
    if (index == 0) {
      return Match(
        title: 'Bukit Batok East CC Soccer Match',
        subtitle: 'Soccer',
        description: 'This is a soccer match.',
        venue: 'Bukit Batok East',
        time: '2023-06-01 18:00',
        team: 'Organizing Team: Bukit Batok East CC',
        type: 'Soccer',
        sponsor: 'Sponsor: Meow Barbecue',
        participants: ['Alice', 'Bob', 'Charlie'],
      );
    } else if (index == 1) {
      return Match(
        title: 'Badminton Points Challenge',
        subtitle: 'Badminton',
        description: 'This is a badminton points challenge.',
        venue: 'Badminton Hall',
        time: '2023-06-01 18:00',
        team: 'Organizing Team: Badminton Busters',
        type: 'Badminton',
        sponsor: '',
        participants: ['Alice', 'Bob', 'Charlie'],
      );
    } else if (index % 3 == 1) {
      return Match(
        title: 'Bugis Meow Barbecue Cup Badminton Tournament',
        subtitle: 'Badminton',
        description: 'This is an open badminton tournament in Bugis, played in a knockout format.',
        venue: 'Bugis Badminton Hall',
        time: '2023-06-02 10:00',
        team: 'Organizing Team: Meow Barbecue',
        type: 'Badminton',
        sponsor: 'Sponsor: Meow Barbecue',
        participants: ['Team X', 'Team Y', 'Team Z'],
      );
    } else {
      return Match(
        title: 'Basketball Match $index',
        subtitle: 'Basketball',
        description: 'This is a basketball match.',
        venue: 'Basketball Hall',
        time: '2023-06-01 19:00',
        team: 'Organizing Team: Basketball Stars',
        type: 'Basketball',
        sponsor: '',
      );
    }
  });

  List<String> selectedFilters = [];

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredItems = selectedFilters.isEmpty
        ? items
        : items.where((item) {
            if (item is Match) {
              return selectedFilters.contains(item.type);
            } else if (item is VenueRental) {
              return selectedFilters.contains('Venue Rental');
            }
            return false;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                if (selectedFilters.contains(value)) {
                  selectedFilters.remove(value);
                } else {
                  selectedFilters.add(value);
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return ['Badminton', 'Soccer', 'Basketball', 'Venue Rental'].map((String filter) {
                return CheckedPopupMenuItem<String>(
                  value: filter,
                  checked: selectedFilters.contains(filter),
                  child: Text(filter),
                );
              }).toList();
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'This is the platform for publishing matches and activities!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                if (item is Match) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                    ),
                    elevation: 2,
                    color: Colors.grey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(item.subtitle, style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 5),
                          Text(item.team, style: TextStyle(color: Colors.grey[600])),
                          if (item.sponsor.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(item.sponsor, style: TextStyle(color: Colors.grey[600])),
                          ],
                          const SizedBox(height: 5),
                          Text(item.time, style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 5),
                          Text(item.venue, style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 5),
                          Text(item.description),
                          if (index == 0 || index == 1) ...[
                            const SizedBox(height: 10),
                            const Text('Participants:', style: TextStyle(fontWeight: FontWeight.bold)),
                            for (int i = 0; i < item.participants.length; i++)
                              Text(item.participants[i]),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle participate button press
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                                child: const Text('Participate'),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (String value) {
                                  // Handle action selection
                                },
                                itemBuilder: (BuildContext context) {
                                  return ['View Details', 'Share', 'Report'].map((String action) {
                                    return PopupMenuItem<String>(
                                      value: action,
                                      child: Text(action),
                                    );
                                  }).toList();
                                },
                                icon: const Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (item is VenueRental) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                    ),
                    elevation: 2,
                    color: Colors.grey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(item.team, style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 5),
                          Text(item.time, style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 5),
                          Text(item.venue, style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 5),
                          Text('Price: ${item.price}', style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 5),
                          Text('Deadline: ${item.deadline}', style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 5),
                          Text(item.description),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle participate button press
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                                child: const Text('Contact'),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (String value) {
                                  // Handle action selection
                                },
                                itemBuilder: (BuildContext context) {
                                  return ['View Details', 'Share', 'Report'].map((String action) {
                                    return PopupMenuItem<String>(
                                      value: action,
                                      child: Text(action),
                                    );
                                  }).toList();
                                },
                                icon: const Icon(Icons.more_vert),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
