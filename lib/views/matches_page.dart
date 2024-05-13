import 'package:flutter/material.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = [
      {
        'team1': '武汉队',
        'team2': '上海队',
        'date': '2023-05-15',
        'time': '19:00',
        'location': '武汉体育场',
      },
      {
        'team1': '北京队',
        'team2': '广州队',
        'date': '2023-05-20',
        'time': '16:00',
        'location': '北京工人体育场',
      },
      {
        'team1': '深圳队',
        'team2': '重庆队',
        'date': '2023-05-25',
        'time': '20:30',
        'location': '深圳体育中心',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return ListTile(
            title: Text('${match['team1']} vs ${match['team2']}'),
            subtitle: Text(
              '${match['date']} ${match['time']} | ${match['location']}',
            ),
          );
        },
      ),
    );
  }
}
