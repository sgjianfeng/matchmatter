import 'package:flutter/material.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final teams = [
      'WeChat for Mac 群聊',
      '武汉',
      '球场预定群组',
      '家庭群',
      '籍子(在职)',
      '龙泉驿',
      '武汉市体育局',
      '文体俱乐部',
      '17学年体育',
      'LIU QINGDONG 籍赛群',
    ];

    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Text('${index + 1}'),
          ),
          title: Text(teams[index]),
        );
      },
    );
  }
}



