import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_waves_app/constants.dart';
import 'package:chat_waves_app/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cubits/chat_cubit/chat_cubit.dart';
import '../models/user_model.dart'; // Import Firestore

class ChatBubbleForSecondUser extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  ChatBubbleForSecondUser({super.key,
    required this.messageModel,
    required this.recipientUserId,
    String? recipientImage});

  final MessageModel messageModel;
  final String recipientUserId; // Receive recipientUserId

  @override
  Widget build(BuildContext context) {
    final formattedDate =
    DateFormat('EEE, M/d, h:mm a').format(messageModel.dateTime.toDate());
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: _getUserImage(context),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery
                    .of(context)
                    .size
                    .width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 15, horizontal: 16),
              margin: const EdgeInsets.symmetric(
                vertical: 13,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(32),
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                color: HexColor(kSecondaryColor),
              ),
              child: (messageModel.messageImage != null &&
                  messageModel.messageImage!.isNotEmpty) ?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    messageModel.messageImage!, // Display the image
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                          'Error loading image'); // Display an error message if loading fails
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }

  ImageProvider _getUserImage(BuildContext context) {
    final chatCubit = BlocProvider.of<ChatCubit>(context);

    if (chatCubit.senderUserImageUrl != null) {
      return CachedNetworkImageProvider(chatCubit.senderUserImageUrl!);
    } else if (chatCubit.senderUserImagePath != null) {
      return FileImage(File(chatCubit.senderUserImagePath!));
    } else {
      return AssetImage(kUserAvatar);
    }
  }

  Future<UserModel> fetchUserModel(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(userId)
        .get();
    return UserModel.fromJson(userDoc.data()!);
  }
}