import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String textMessage;
  final textEditingControl = TextEditingController();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User loggedInUser; //previously known as FirebaseUser

  void getCurrentUser() {
    final user = _auth.currentUser;
    try {
      if (user != null) {
        loggedInUser = user;
        print(user.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _fireStore.collection('Messages').orderBy('Timestamp', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData != true) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data.docs.reversed;
                  List<MessageBubble> textWidgets = [];
                  for (var message in messages) {
                    final messageText = message.data()['text'];
                    final messageSender = message.data()['sender'];

                    final whoSent = loggedInUser.email;

                    final messageWidget = MessageBubble(
                        messageText, messageSender, whoSent == messageSender);
                    textWidgets.add(messageWidget);
                  }
                  return Expanded(
                    child: ListView(
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        children: textWidgets),
                  );
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingControl,
                      onChanged: (value) {
                        textMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textEditingControl.clear();
                      _fireStore.collection('Messages').add({
                        'sender': loggedInUser.email,
                        'text': textMessage,
                        'Timestamp': FieldValue.serverTimestamp(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String messageText;
  final String messageSender;
  final bool isMe;

  // void colorDecider() {
  //   if (isMe == true) {
  //     colour = Colors.lightBlueAccent;
  //   } else {
  //     colour = Colors.redAccent;
  //   }
  // }

  MessageBubble(this.messageText, this.messageSender, this.isMe);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text('$messageSender',
              style: TextStyle(
                fontSize: 11.0,
                color: Colors.black54,
              )),
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Material(
              color: isMe ? Colors.blueAccent : Colors.white,
              elevation: 5.0,
              borderRadius: isMe
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0),
                    )
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('$messageText',
                    style: TextStyle(
                        fontSize: 15.0,
                        color: isMe ? Colors.white : Colors.black)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
