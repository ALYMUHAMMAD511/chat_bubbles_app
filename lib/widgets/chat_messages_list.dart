import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'chat_bubble.dart';
import 'chat_bubble_for_second_user.dart';

class ChatMessagesList extends StatelessWidget {
  final List<MessageModel> messages;
  final String currentUserId;
  final String recipientUserId;

  const ChatMessagesList({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.recipientUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCurrentUser = message.senderId == currentUserId;

        if (isCurrentUser) {
          return ChatBubble(
            messageModel: message,
            senderUserId: currentUserId,
          );
        } else {
          return ChatBubbleForSecondUser(
            messageModel: message,
            recipientUserId: recipientUserId,
          );
        }
      },
    );
  }
}