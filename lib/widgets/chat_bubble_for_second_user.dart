import 'package:chat_waves_app/constants.dart';
import 'package:chat_waves_app/models/message_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart'; // Import Firestore

class ChatBubbleForSecondUser extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  ChatBubbleForSecondUser(
      {super.key,
      required this.messageModel,
      required this.recipientUserId,
      String? recipientImage});

  final MessageModel messageModel;
  final String recipientUserId; // Receive recipientUserId

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('EEE, M/d, h:mm a').format(messageModel.dateTime.toDate());
    return FutureBuilder<UserModel>(
      future: fetchUserModel(recipientUserId), // Fetch UserModel
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final recipient = snapshot.data!; // Get recipient UserModel

          return Row(
            mainAxisAlignment: MainAxisAlignment.start, // Align to the right
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                ),
                // Add padding to the right
                child: CircleAvatar(
                  radius: 28.0,
                  // Use recipient's image
                  backgroundImage: recipient.userImage != null
                      ? NetworkImage(recipient.userImage!)
                      : AssetImage(kUserAvatar),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 15,
                                  right: 15, // Align image to the right
                                ),
                                child: Image.network(
                                  snapshot.data!,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Padding(
                                padding: EdgeInsets.only(right: 16),
                                // Align error to the right
                                child: Text('Error loading image'),
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        );
                      },
                    ),
                  if (messageModel.message.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      // Align text to the right
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 16),
                        margin: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(32),
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          color: HexColor(kSecondaryColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start
                          ,
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
