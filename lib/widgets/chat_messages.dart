import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final userAuth = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No message found'),
            );
          }

          if (chatSnapshots.hasError) {
            return const Center(
              child: Text('Something went wrong!'),
            );
          }

          final loadedMessage = chatSnapshots.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedMessage.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadedMessage[index].data();
              final nextMessage = index + 1 < loadedMessage.length ? loadedMessage[index+1].data() : null;
              
              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId = nextMessage == null ? null : nextMessage['userId'];
              final nextUserIsSame = currentMessageUserId == nextMessageUserId;

              if(nextUserIsSame){
                return MessageBubble.next(message: chatMessage['text'], isMe: userAuth!.uid == currentMessageUserId);
              }

              return MessageBubble.first(userImage: chatMessage['userImage'], username: chatMessage['username'], message: chatMessage['text'], isMe: userAuth!.uid == currentMessageUserId);
            },
          );
        });
  }
}
