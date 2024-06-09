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

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final List<Match> matches = List.generate(30, (index) {
    if (index == 0) {
      return Match(
        title: '羽毛球积分挑战赛',
        subtitle: '羽毛球',
        description: '这是一个羽毛球积分挑战赛。',
        venue: '羽毛球馆',
        time: '2023-06-01 18:00',
        team: '组织团队：Badminton Busters',
        type: '羽毛球',
        sponsor: '',
        participants: ['Alice', 'Bob', 'Charlie'],
      );
    } else if (index == 1) {
      return Match(
        title: ' Bugis猫抓烤肉杯羽毛球赛',
        subtitle: '羽毛球',
        description: '这是bugis地区羽毛球公开赛，采用淘汰赛方式。',
        venue: 'Bugis 羽毛球馆',
        time: '2023-06-02 10:00',
        team: '组织团队：猫抓烤肉',
        type: '羽毛球',
        sponsor: '赞助：猫抓烤肉',
        participants: ['Team X', 'Team Y', 'Team Z'],
      );
    } else if (index % 3 == 1) {
      return Match(
        title: '足球比赛 $index',
        subtitle: '足球',
        description: '这是一个足球比赛。',
        venue: '足球场',
        time: '2023-06-01 20:00',
        team: '组织团队：Football Heroes',
        type: '足球',
        sponsor: '',
      );
    } else {
      return Match(
        title: '篮球比赛 $index',
        subtitle: '篮球',
        description: '这是一个篮球比赛。',
        venue: '篮球馆',
        time: '2023-06-01 19:00',
        team: '组织团队：Basketball Stars',
        type: '篮球',
        sponsor: '',
      );
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
      body: Column(
        children: [
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '这里是比赛，活动的发布平台！',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredMatches.length,
              itemBuilder: (context, index) {
                final match = filteredMatches[index];
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
                          match.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(match.subtitle, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 5),
                        Text(match.team, style: TextStyle(color: Colors.grey[600])),
                        if (match.sponsor.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(match.sponsor, style: TextStyle(color: Colors.grey[600])),
                        ],
                        const SizedBox(height: 5),
                        Text(match.time, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 5),
                        Text(match.venue, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 5),
                        Text(match.description),
                        if (index == 0 || index == 1) ...[
                          const SizedBox(height: 10),
                          const Text('报名参加团队:', style: TextStyle(fontWeight: FontWeight.bold)),
                          for (int i = 0; i < match.participants.length; i++)
                            Text(match.participants[i]),
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
          ),
        ],
      ),
    );
  }
}
