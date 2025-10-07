import 'package:flutter/material.dart';
import 'package:practice/api_service.dart';
import 'package:practice/chat/chats.dart';
import 'package:practice/lang.dart';
import 'chatuser_model.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late Future<List<ChatUser>> _chatUsers;

  @override
  void initState() {
    super.initState();
    _chatUsers = ApiService.fetchChatUsers();
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      body: FutureBuilder<List<ChatUser>>(
        future: _chatUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading chats"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(localizations.translate('no_chats')));
          }

          List<ChatUser> users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              ChatUser user = users[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePhoto),
                  onBackgroundImageError: (_, __) => Icon(Icons.person),
                ),
                title: Text(user.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Matri ID: ${user.matriId}"),
                trailing: user.newMessage == '1'
                    ? Icon(Icons.circle, color: Colors.green, size: 10)
                    : null,
                onTap: () {
                  // Navigate to chat screen
                  setState(() {
                    users[index].newMessage = '0'; // Update UI immediately
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatScreen(
                            matriId: user.matriId,
                            profile: user.profilePhoto,
                            name: user.name)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
