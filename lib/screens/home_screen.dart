import 'dart:io';

import 'package:chat_waves_app/constants.dart';
import 'package:chat_waves_app/cubits/logout_cubit/logout_cubit.dart';
import 'package:chat_waves_app/helper/helper_functions.dart';
import 'package:chat_waves_app/models/user_model.dart';
import 'package:chat_waves_app/screens/chat_screen.dart';
import 'package:chat_waves_app/screens/edit_user_screen.dart';
import 'package:chat_waves_app/widgets/custom_circle_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'login_screen.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static String id = 'Home Screen';

  CollectionReference users =
  FirebaseFirestore.instance.collection(kUsersCollection);

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccessState) {
            Navigator.pushReplacementNamed(context, LoginScreen.id);
            showSnackBar(context, 'Logged Out Successfully', Colors.green);
          }
          else if (state is LogoutFailureState) {
            showSnackBar(context, state.error, Colors.red);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: HexColor(kPrimaryColor),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CustomCircleIconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            EditUserScreen.id,
                          );
                        },
                        icon: Icons.edit_sharp,
                      ),
                    ),
                    Image.asset(
                      kAppLogo,
                      width: 230,
                      height: 170,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CustomCircleIconButton(
                        onPressed: () {
                          BlocProvider.of<LogoutCubit>(context).logout(context);
                        },
                        icon: Icons.logout,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'Friends',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: users.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<UserModel> usersList = [];
                        for (int i = 0; i < snapshot.data!.docs.length; i++) {
                          final user = UserModel.fromJson(
                              snapshot.data!.docs[i]);
                          // Skip the current user
                          if (user.userId != currentUserId) {
                            usersList.add(user);
                          }
                        }
                        return ListView.separated(
                          itemCount: usersList.length,
                          itemBuilder: (context, index) {
                            final userId = usersList[index].userId;
                            final chatId = createChatId(currentUserId, userId);
                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(chatId)
                                  .collection('messages')
                                  .orderBy(kDateTime, descending: true)
                                  .limit(1)
                                  .snapshots(),
                              builder: (context, messageSnapshot) {
                                if (messageSnapshot.hasData) {
                                  final lastMessage = messageSnapshot
                                      .data!.docs.isNotEmpty
                                      ? messageSnapshot.data!.docs.first.get(
                                      kMessage)
                                      : 'Tap Here to Start a Conversation';
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        ChatScreen.id,
                                        arguments: usersList[index].userId,
                                      );
                                    },
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                        usersList[index].userImage != null
                                            ?
                                          usersList[index].userImage!.startsWith('http')
                                          ?
                                          NetworkImage(
                                            usersList[index].userImage!)
                                        : FileImage(File(usersList[index].userImage!))
                                            : AssetImage(kUserAvatar),
                                        radius: 28,
                                      ),
                                      title: Text(
                                        usersList[index].userName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                        ),
                                      ),
                                      subtitle: Text(
                                        lastMessage.toString(),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 17,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: HexColor(
                                          kSecondaryColor),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                          separatorBuilder: (context, index) =>
                          const Divider(
                            indent: 16,
                            endIndent: 16,
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
                  ),
                ),
              ],
            ),
          );
        },
    );
  }

  // Create a chat ID by sorting the two user IDs to maintain uniqueness
  String createChatId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort(); // Sort alphabetically to ensure consistency
    return userIds.join('_');
  }
}
