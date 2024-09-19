import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class MessageModel {
  final String senderId; // Sender ID
  final String recipientId; // Receiver ID
  final String message;
  final Timestamp dateTime;
  String? messageImage; // Store the image URL here

  MessageModel({
    required this.senderId,
    required this.recipientId,
    required this.message,
    required this.dateTime,
    this.messageImage,
  });

  factory MessageModel.fromJson(json) {
    return MessageModel(
      message: json[kMessage],
      dateTime: json[kDateTime],
      senderId: json[kSenderId],
      recipientId: json[kRecipientId],
      messageImage:
          json[kMessageImage], // Retrieve the image URL from Firestore
    );
  }

  // Add a method to convert MessageModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      kMessage: message,
      kDateTime: dateTime,
      kSenderId: senderId,
      kRecipientId: recipientId,
      kMessageImage: messageImage, // Store the image URL in Firestore
    };
  }
}
