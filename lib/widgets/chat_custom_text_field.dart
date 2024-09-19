import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';

// ignore: must_be_immutable
class ChatCustomTextField extends StatefulWidget {
  final String recipientUserId;
  final String chatId;
  final Function(String, String)? sendMessageWithImage;

  const ChatCustomTextField({
    super.key,
    required this.recipientUserId,
    required this.chatId,
    this.sendMessageWithImage,
    required Future<void> Function() pickImage,
  });

  @override
  State<ChatCustomTextField> createState() => _ChatCustomTextFieldState();
}

class _ChatCustomTextFieldState extends State<ChatCustomTextField> {
  CollectionReference messages =
      FirebaseFirestore.instance.collection(kChatsCollection);

  TextEditingController textEditingController = TextEditingController();

  ScrollController scrollController = ScrollController();

  String? messageImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          messageImage = pickedFile.path; // Store the image path
        });
      }
    }
  }

  void sendMessage(String senderId, String recipientId, String message) async {
    if (message.isNotEmpty || messageImage != null) {
      // Create a map for the initial message
      Map<String, dynamic> messageData = {
        kMessage: message,
        kDateTime: DateTime.now(),
        kSenderId: senderId,
        kRecipientId: recipientId, // Add recipientId
        kMessageImage: null, // Initially no image
      };

      // Send the message to Firestore without the image first
      DocumentReference messageRef = await messages
          .doc(widget.chatId)
          .collection('messages')
          .add(messageData);

      // If there is an image, upload it and update the message with the image URL
      if (messageImage != null) {
        // Store the image path relative to the current user's directory
        String imagePathRelativeToUser =
            'messages/$senderId/images/${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Upload the image to Firebase Storage
        final storageRef =
            FirebaseStorage.instance.ref(imagePathRelativeToUser);
        final uploadTask = storageRef.putFile(File(messageImage!));

// After the image is uploaded, get the download URL
        await uploadTask.whenComplete(() async {
          final imageUrl = await storageRef.getDownloadURL();
          // Ensure the URL is not null and update Firestore
          await messageRef.update({kMessageImage: imageUrl});
        });
      }

      // Clear the text field and image
      textEditingController.clear();
      if (mounted) {
        setState(() {
          messageImage = null; // Clear the image path after sending
        });
      }

      // Scroll to the bottom of the chat
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser!.uid; // Get current user ID
    return TextField(
      textCapitalization: TextCapitalization.sentences,
      controller: textEditingController,
      cursorColor: HexColor(kSecondaryColor),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
      onSubmitted: (data) {
        sendMessage(currentUserId, widget.recipientUserId, data);
      },
      decoration: InputDecoration(
        hintText: 'Message',
        hintStyle: const TextStyle(
          color: Colors.white38,
          fontSize: 20,
        ),
        suffixIcon: Stack(
          alignment: Alignment.centerRight,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: IconButton(
                icon: Icon(Icons.photo_sharp, color: HexColor(kSecondaryColor)),
                onPressed: () {
                  pickImage();
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.send_sharp, color: HexColor(kSecondaryColor)),
              onPressed: () {
                sendMessage(currentUserId, widget.recipientUserId,
                    textEditingController.text);
              },
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: HexColor('#4D5C5F'),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            width: 2,
            color: HexColor('#4D5C5F'),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: HexColor(kSecondaryColor),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
