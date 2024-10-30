import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_waves_app/constants.dart';
import 'package:chat_waves_app/widgets/chat_messages_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:io';
import '../../cubits/chat_cubit/chat_cubit.dart';
import '../../widgets/chat_custom_text_field.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.recipientUserId});

  final String recipientUserId;
  static String id = 'Chat Screen';

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: HexColor(kPrimaryColor),
      appBar: AppBar(
        toolbarHeight: 65,
        elevation: 10,
        backgroundColor: HexColor(kPrimaryColor),
        title: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatLoadedState) {
              return Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        BlocProvider.of<ChatCubit>(context).userImageUrl != null
                            ? CachedNetworkImageProvider(
                                BlocProvider.of<ChatCubit>(context)
                                    .userImageUrl!) // Load image from network
                            : BlocProvider.of<ChatCubit>(context)
                                        .userImagePath !=
                                    null
                                ? FileImage(
                                    File(BlocProvider.of<ChatCubit>(context)
                                        .userImagePath!),
                                  ) as ImageProvider // Load local image
                                : AssetImage(kUserAvatar),
                    // Fallback to default image,
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${BlocProvider.of<ChatCubit>(context).userName}',
                    maxLines: 1,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              );
            } else if (state is ChatLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: HexColor(kSecondaryColor),
                  color: Colors.white,
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state is ChatLoadedState) {
                return Expanded(
                  child: ChatMessagesList(
                    messages: state.messages,
                    currentUserId: currentUserId,
                    recipientUserId: recipientUserId,
                  ),
                );
              } else if (state is ChatLoadingState) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: HexColor(kSecondaryColor),
                    color: Colors.white,
                  ),
                );
              } else {
                return const Center(
                  child: Text(
                    'No Messages to Show',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ChatCustomTextField(
              recipientUserId: recipientUserId,
              chatId: BlocProvider.of<ChatCubit>(context).chatId!,
              pickImage: () async {
                final cubit = BlocProvider.of<ChatCubit>(context);
                final imageFile = await cubit.pickImage();
                if (imageFile != null) {
                  cubit.sendMessage('', imageFile: imageFile);
                }
              },
              sendMessageWithImage: (message, imagePath) {
                final imageFile = File(imagePath);
                BlocProvider.of<ChatCubit>(context)
                    .sendMessage(message, imageFile: imageFile);
              },
            ),
          ),
        ],
      ),
    );
  }
}
