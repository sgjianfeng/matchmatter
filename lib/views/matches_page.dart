import 'package:flutter/material.dart';

class Match {
  final String title;
  final String subtitle;
  final String description;
  final String venue;
  final String time;
  final String team;
  final String type;

  Match({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.venue,
    required this.time,
    required this.team,
    required this.type,
  });
}

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final List<Match> matches = List.generate(30, (index) {
    if (index % 3 == 0) {
      return Match(
          title: '羽毛球比赛 $index',
          subtitle: '羽毛球',
          description: '这是一个羽毛球比赛。',
          venue: '羽毛球馆',
          time: '2023-06-01 18:00',
          team: 'Team A vs Team B',
          type: '羽毛球');
    } else if (index % 3 == 1) {
      return Match(
          title: '足球比赛 $index',
          subtitle: '足球',
          description: '这是一个足球比赛。',
          venue: '足球场',
          time: '2023-06-01 20:00',
          team: 'Team C vs Team D',
          type: '足球');
    } else {
      return Match(
          title: '篮球比赛 $index',
          subtitle: '篮球',
          description: '这是一个篮球比赛。',
          venue: '篮球馆',
          time: '2023-06-01 19:00',
          team: 'Team E vs Team F',
          type: '篮球');
    }
  });

  List<String> selectedFilters = [];

  @override
  Widget build(BuildContext context) {
    List<Match> filteredMatches = selectedFilters.isEmpty
        ? matches
        : matches.where((match) => selectedFilters.contains(match.type)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matters'),
        actions: [
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
              return ['羽毛球', '足球', '篮球'].map((String filter) {
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
      body: ListView.builder(
        itemCount: filteredMatches.length,
        itemBuilder: (context, index) {
          final match = filteredMatches[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(match.subtitle, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 5),
                  Text(match.team, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 5),
                  Text(match.time, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 5),
                  Text(match.venue, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 5),
                  Text(match.description),
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
                        child: const Text('参加'),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String value) {
                          // Handle action selection
                        },
                        itemBuilder: (BuildContext context) {
                          return ['查看详情', '分享', '举报'].map((String action) {
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
        },
      ),
    );
  }
}
