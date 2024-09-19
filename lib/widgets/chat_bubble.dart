import 'package:chat_waves_app/models/message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';
import '../models/user_model.dart'; // Import UserModel

class ChatBubble extends StatelessWidget {
  final MessageModel messageModel;
  final String senderUserId;
  final String? senderImage; // Add senderImage parameter

  const ChatBubble({
    super.key,
    required this.messageModel,
    required this.senderUserId,
    this.senderImage,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEE, M/d, h:mm a').format(messageModel.dateTime.toDate());

    return FutureBuilder<UserModel>(
      future: fetchUserModel(senderUserId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final sender = snapshot.data!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align to the right
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                // Align text to the right
                children: [
                  if (messageModel.messageImage != null)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return FutureBuilder<String>(
                          future: FirebaseStorage.instance
                              .ref(messageModel.messageImage!)
                              .getDownloadURL(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              // Log the fetched URL for debugging purposes
                              if (kDebugMode) {
                                print('Fetched Image URL: ${snapshot.data}');
                              }

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 15,
                                  right: 15,
                                ),
                                child: Image.network(
                                  snapshot.data!, // Use the network image
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context, Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (BuildContext context, Object exception,
                                      StackTrace? stackTrace) {
                                    return const Padding(
                                      padding: EdgeInsets.only(right: 16),
                                      child: Text('Error loading image'),
                                    );
                                  },
                                ),
                              );
                            } else if (snapshot.hasError) {
                              // Log the error for debugging purposes
                              if (kDebugMode) {
                                print('Error fetching image: ${snapshot.error}');
                              }
                              return const Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Text('Error loading image'),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        );
                      },
                    ),
                  if (messageModel.message.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 16),
                        margin: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(32),
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          color: HexColor('#4D5C5F'),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          // Align text to the right
                          children: [
                            SelectableText(
                              messageModel.message,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                // Add padding to the right
                child: CircleAvatar(
                  radius: 28.0,
                  // Use sender's image
                  backgroundImage: sender.userImage != null
                      ? NetworkImage(sender.userImage!)
                      : AssetImage(kUserAvatar),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return const Text('Error loading user data');
        } else {
          return const SizedBox();
        }
      },
    );
  }

  // Function to fetch UserModel from Firestore
  Future<UserModel> fetchUserModel(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(userId)
        .get();
    return UserModel.fromJson(userDoc.data()!);
  }
}
