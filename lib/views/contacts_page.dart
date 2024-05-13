import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟一些联系人数据
    final contacts = [
      {
        'name': '张三',
        'avatar': 'assets/avatars/avatar1.png',
        'phone': '13812345678',
      },
      {
        'name': '李四',
        'avatar': 'assets/avatars/avatar2.png',
        'phone': '13987654321',
      },
      {
        'name': '王五',
        'avatar': 'assets/avatars/avatar3.png',
        'phone': '13567890123',
      },
      // 添加更多联系人...
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(contact['avatar']!),
            ),
            title: Text(contact['name']!),
            subtitle: Text(contact['phone']!),
            trailing: IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                // 处理拨打电话的逻辑
              },
            ),
          );
        },
      ),
    );
  }
}
