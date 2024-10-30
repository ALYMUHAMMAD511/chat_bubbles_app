import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../../models/message_model.dart';
import '../../models/user_model.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitialState());

  final FirebaseFirestore fire = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  Stream<QuerySnapshot>? messageStream;
  String? chatId;
  UserModel? recipient;
  final ImagePicker _picker = ImagePicker();// Image picker instance
  String? userImageUrl;
  String? userImagePath;
  String? userName;
  String? senderUserImageUrl;
  String? senderUserImagePath;
  String? senderUserName;

  // Initialize chat by loading messages and user data
  void initializeChat(String currentUserId, String recipientUserId) async {
    chatId = createChatId(currentUserId, recipientUserId);
    getRecipientUserData(recipientUserId);
    getMessages(recipientUserId);
  }

  // Fetch recipient details
  void getRecipientUserData(String recipientUserId) async {
    try {
      emit(ChatLoadingState());
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientUserId)
          .get();

      if (userDoc.exists) {
        userImageUrl = userDoc.data()?['imageUrl'];
        userImagePath = userDoc.data()?['userImage'];
        userName = userDoc.data()?['userName'];

        messageStream = fire
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('dateTime', descending: true)
            .snapshots();

        messageStream!.listen((snapshot) {
          final messages = snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
          emit(ChatLoadedState(messages));
        });
      }
    } catch (e) {
      emit(ChatErrorState(error: e.toString()));
    }
  }

  void getSenderUserData(String currentUserId) async {
    try {
      emit(ChatLoadingState());
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        senderUserImageUrl = userDoc.data()?['imageUrl'];
        senderUserImagePath = userDoc.data()?['userImage'];
        senderUserName = userDoc.data()?['userName'];

        messageStream = fire
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('dateTime', descending: true)
            .snapshots();

        messageStream!.listen((snapshot) {
          final messages = snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
          emit(ChatLoadedState(messages));
        });
      }
    } catch (e) {
      emit(ChatErrorState(error: e.toString()));
    }
  }

  // Fetch messages from Firestore and listen for updates
  void getMessages(String recipientUserId) async {
    emit(ChatLoadingState());
    try {
      messageStream = fire
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('dateTime', descending: true)
          .snapshots();

      messageStream!.listen((snapshot) {
        final messages = snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        emit(ChatLoadedState(messages));
      });
    } catch (e) {
      emit(ChatErrorState(error: e.toString()));
    }
  }

  // Send a message with optional text and image
  Future<void> sendMessage(String messageText, {File? imageFile}) async {
    emit(ChatSendingState());
    try {
      final currentUserId = auth.currentUser!.uid;
      final recipientId = chatId!.split('_').firstWhere((id) => id != currentUserId);

      String? imageUrl;
      if (imageFile != null) {
        // Relative path for storage reference (make sure it's correct)
        final storageRef = storage
            .ref()
            .child('Chats/$chatId/${DateTime.now().toIso8601String()}${p.extension(imageFile.path)}');

        // Upload the file
        await storageRef.putFile(imageFile);

        // Get the download URL after uploading
        imageUrl = await storageRef.getDownloadURL();
      }

      final newMessage = MessageModel(
        senderId: currentUserId,
        recipientId: recipientId,
        message: messageText,
        dateTime: Timestamp.now(),
        messageImage: imageUrl, // Save the image URL in Firestore
      );

      // Save the message in Firestore
      await fire.collection('chats').doc(chatId).collection('messages').add(newMessage.toMap());

      emit(ChatSentState());
    } catch (e) {
      emit(ChatErrorState(error: e.toString()));
    }
  }

  // Pick an image from the gallery
  Future<File?> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      emit(ChatErrorState(error: 'Failed to pick image: $e'));
    }
    return null;
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile) async {
    try {
      // Use a relative path here, not a full URL
      final storageRef = storage.ref().child('Chats/$chatId/${DateTime.now().toIso8601String()}${p.extension(imageFile.path)}');

      // Upload the file
      final uploadTask = await storageRef.putFile(imageFile);

      // Get the download URL (this will be the full URL that you can store in Firestore)
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      emit(ChatErrorState(error: 'Error fetching image: $e'));
      throw Exception('Failed to upload image');
    }
  }



  // Utility to create chatId from two user IDs
  String createChatId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort();
    return userIds.join('_');
  }
}