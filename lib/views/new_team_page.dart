import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matchmatter/data/contact.dart';
import 'package:matchmatter/data/user.dart';
import 'package:matchmatter/views/create_team_summary_page.dart';

class NewTeamPage extends StatefulWidget {
  const NewTeamPage({super.key});

  @override
  _NewTeamPageState createState() => _NewTeamPageState();
}

class _NewTeamPageState extends State<NewTeamPage> {
  List<Contact> contacts = []; // Example contacts

  final TextEditingController _teamIdController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamTagController = TextEditingController();

  List<bool> selectedContacts =
      List.generate(5, (index) => false); // Tracks selection
  bool _isSearching = false; // Tracks if the search is active
  final TextEditingController _searchController = TextEditingController();
  List<Contact> filteredContacts = [];

  @override
  void initState() {
    super.initState();
    filteredContacts =
        contacts; // Set the filteredContacts to all contacts initially
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      UserDatabaseService(uid: user.uid).getUserData().then((userData) {
        setState(() {
          for (int i = 0; i < 10; i++) {
            // 假设添加10次相同的用户数据进行测试
            contacts.add(Contact(
                uid: user.uid, name: userData.name, email: user.email ?? ''));
            selectedContacts.add(i == 0); // 默认选中第一个（当前用户）
          }
          filteredContacts = contacts; // 更新filteredContacts列表
        });
      }).catchError((error) {
        print("Failed to load user data: $error");
      });
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        filteredContacts = contacts;
      } else {
        _searchController.clear();
        filteredContacts =
            contacts; // Reset to all contacts when search is toggled off
      }
    });
  }

  void _filterContacts(String searchTerm) {
    List<Contact> results = [];
    if (searchTerm.isEmpty) {
      results = contacts;
    } else {
      results = contacts
          .where((contact) =>
              contact.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
              contact.email.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredContacts = results;
    });
  }

  Future<bool> checkTeamIdUnique(String teamId) async {
    // 这里应该有一些逻辑来检查团队ID是否唯一
    // 返回 true 如果唯一，false 如果已经存在
    return true; // 暂时返回 true，你需要根据你的数据库实现这个功能
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
            onPressed: () async {
              if (_teamIdController.text.isEmpty ||
                  _teamNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all the required fields.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // 检查 Team ID 是否唯一
              bool isUnique = await checkTeamIdUnique(_teamIdController.text);
              if (!isUnique) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Team ID is already taken. Please choose another one.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // 如果 Team ID 唯一，导航到创建团队总结页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTeamSummaryPage(
                    teamId: _teamIdController.text,
                    teamName: _teamNameController.text,
                    teamTag: _teamTagController.text,
                    selectedContacts: contacts
                        .asMap()
                        .entries
                        .where((entry) => selectedContacts[entry.key])
                        .map((entry) => entry.value)
                        .toList(),
                  ),
                ),
              );
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
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 10.0), // Adjusted padding
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _teamNameController,
                      decoration: const InputDecoration(
                        labelText: 'Team Name',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 10.0), // Adjusted padding
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _teamTagController,
                      decoration: const InputDecoration(
                        labelText: 'Team Tag',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 10.0), // Adjusted padding
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    //const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Contacts',
                  border: const OutlineInputBorder(),
                  suffixIcon: _isSearching && _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _toggleSearch();
                            //_searchController.clear();
                            //_filterContacts(''); // 重新过滤联系人列表，显示所有联系人
                          },
                        )
                      : const Icon(Icons.search), // 当没有输入时显示搜索图标
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                ),
                onChanged: _filterContacts,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                var contact = filteredContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(contact.name[0]), // 显示用户名的第一个字母
                  ),
                  title: Text(contact.name),
                  subtitle: Text(contact.email),
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
