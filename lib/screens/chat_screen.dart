import 'dart:async';
import 'dart:io';
import 'package:chat_waves_app/constants.dart';
import 'package:chat_waves_app/widgets/chat_bubble.dart';
import 'package:chat_waves_app/widgets/chat_bubble_for_second_user.dart';
import 'package:chat_waves_app/widgets/chat_custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message_model.dart';
import 'package:path/path.dart' as p;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static String id = 'Chat Screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ScrollController scrollController = ScrollController();

  // Use XFile to store the image
  String? receiverName;
  String? receiverImage;
  String? senderName;
  String? senderImage;
  String? recipientUserId;
  String? chatId;

  StreamSubscription<DocumentSnapshot>? _senderDocSubscription;
  StreamSubscription<DocumentSnapshot>? _receiverDocSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    recipientUserId = ModalRoute.of(context)!.settings.arguments as String;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    chatId = createChatId(currentUserId, recipientUserId!);

    _senderDocSubscription = FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          senderName = snapshot.data()![kUserName];
          senderImage = snapshot.data()![kUserImage];
        });
      }
    });

    _receiverDocSubscription = FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(recipientUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          receiverName = snapshot.data()![kUserName];
          receiverImage = snapshot.data()![kUserImage];
        });
      }
    });
  }

  @override
  void dispose() {
    _senderDocSubscription?.cancel();
    _receiverDocSubscription?.cancel();
    super.dispose();
  }

  String createChatId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort();
    return userIds.join('_');
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImage(
      {required File file, required String chatId}) async {
    try {
      // Get a reference to the storage bucket
      final storageRef = FirebaseStorage.instance.ref('Chats/$chatId').child(
          '${DateTime.now().toIso8601String()}${p.extension(file.path)}');

      // Upload the file
      UploadTask uploadTask = storageRef.putFile(file);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() async {
        // Get the download URL
        return await storageRef.getDownloadURL();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return null;
    }
    return null;
  }

  // Pick image from gallery
  Future<File?> pickMedia() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      return File(file.path);
    }
    return null;
  }

  // Send message with image
  Future<void> sendMessageWithImage(
      String recipientUserId, String chatId) async {
    File? file = await pickMedia();
    if (file != null) {
      String? imageUrl = await uploadImage(file: file, chatId: chatId);
      if (imageUrl != null) {
        final message = MessageModel(
          senderId: FirebaseAuth.instance.currentUser!.uid,
          recipientId: recipientUserId,
          message: '',
          dateTime: Timestamp.now(),
          messageImage: imageUrl,
        );

        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add(message.toMap());
        setState(() {
          file = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy(kDateTime, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<MessageModel> messagesList = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            messagesList.add(MessageModel.fromJson(snapshot.data!.docs[i]));
          }
          return Scaffold(
            backgroundColor: HexColor(kPrimaryColor),
            appBar: AppBar(
              toolbarHeight: 65,
              elevation: 10,
              backgroundColor: HexColor(kPrimaryColor),
              title: Row(
                children: [
                  if (receiverImage != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(receiverImage!),
                      radius: 25,
                    )
                  else
                    CircleAvatar(
                      backgroundImage: AssetImage(kUserAvatar),
                      radius: 25,
                    ),
                  const SizedBox(width: 10),
                  receiverName != null
                      ? Text(
                          '$receiverName',
                          maxLines: 1,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        )
                      : CircularProgressIndicator(
                          color: HexColor(kSecondaryColor),
                        )
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      controller: scrollController,
                      itemBuilder: (context, index) {
                        final message = messagesList[index];
                        final isSender = message.senderId == currentUserId;

                        return isSender
                            ? ChatBubble(
                                messageModel: message,
                                senderUserId: currentUserId,
                                senderImage: senderImage,
                              )
                            : ChatBubbleForSecondUser(
                                messageModel: message,
                                recipientUserId: recipientUserId!,
                                recipientImage: receiverImage,
                              );
                      },
                      itemCount: messagesList.length,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ChatCustomTextField(
                      recipientUserId: recipientUserId!,
                      chatId: chatId!,
                      sendMessageWithImage: sendMessageWithImage,
                      pickImage: pickMedia, // Pass the pickImage function
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: HexColor(kSecondaryColor),
            ),
          );
        }
      },
    );
  }
}
