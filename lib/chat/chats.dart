import 'package:flutter/material.dart';
import 'package:buntsmatrimony/api_service.dart';
import 'package:buntsmatrimony/chat/chatuser_model.dart';
import 'package:buntsmatrimony/checkProfiles.dart';
import 'package:buntsmatrimony/lang.dart';

class ChatScreen extends StatefulWidget {
  final String matriId;
  final String profile;
  final String name;

  const ChatScreen({
    Key? key,
    required this.matriId,
    required this.profile,
    required this.name,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Messages> messages = []; // Store messages as a list of Messages objects
  final TextEditingController _messageController = TextEditingController();
  late String _reciverUserId;
  bool _sendLoading = false;
  bool chatLoad = true;
  final ScrollController _scrollController = ScrollController();
  Color appcolor = Color(0xFFea4a57);
  final MaxLimit _maxLimit = MaxLimit();

  @override
  void initState() {
    super.initState();
    _reciverUserId = widget.matriId;
    _loadMessages(); // Fetch old messages from API
  }

  Future<void> _loadMessages() async {
    try {
      List<Messages> fetchedMessages = await ApiService.fetchChats(context,
        widget.matriId,
      );
      setState(() {
        messages = fetchedMessages; // Assign the fetched list
        chatLoad = messages.isNotEmpty;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      });
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _sendLoading = true;
    });
    String messageResponce = await ApiService.initateChats(context,
      widget.matriId,
      _messageController.text.trim(),
    );
    if (messageResponce == "Y") {
      setState(() {
        messages.add(
          Messages(
            matri_id_by: _reciverUserId,
            message: _messageController.text.trim(),
            matri_id_to: _reciverUserId,
            id: "0",
          ),
        );

        _sendLoading = false;
      });
      _scrollToBottom();
      _messageController.clear();
    } else if (messageResponce == "Max") {
      MaxLimit maxLimit = MaxLimit();
      maxLimit.showSubscriptionDialog(context);
      setState(() {
        _sendLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: appcolor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () async {
            await _maxLimit.checkProfileView(widget.matriId, context);
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.profile),
                onBackgroundImageError:
                    (_, __) {}, // Avoids crash if image fails
              ),
              SizedBox(width: 10), // Space between image and text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${localizations.translate('matri_id')}: ${widget.matriId}',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: chatLoad
                        ? CircularProgressIndicator()
                        : Text(localizations.translate('no_message')),
                  )
                // Show loading until messages are loaded
                : ListView.builder(
                    controller: _scrollController,
                    reverse: false, // Show latest at the bottom
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      bool isMe = messages[index].matri_id_to == _reciverUserId;
                      return _buildChatBubble(messages[index].message, !isMe);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.grey[300] : Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(color: isMe ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    var localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: localizations.translate('type_message'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
          ),
          SizedBox(width: 10),
          _sendLoading
              ? CircularProgressIndicator()
              : IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }
}
