import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants.dart';

part 'edit_user_state.dart';

class EditUserCubit extends Cubit<EditUserState> {
  EditUserCubit() : super(EditUserInitialState());

  String? userImagePath;
  String? userImageUrl;
  String? userName;
  String? phoneNumber;
  String? bio;


  // Load user data from Firestore
  Future<void> loadUserData() async {
    // Indicate loading
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        userImageUrl = userDoc.data()?['imageUrl'];
        userName = userDoc.data()?['userName'];
        phoneNumber = userDoc.data()?['phoneNumber'];
        bio = userDoc.data()?['bio'];
      }
      emit(EditUserSuccessState()); // Indicate success
    } catch (e) {
      emit(EditUserFailureState(e.toString())); // Emit failure state
    }
  }

  // Function to pick an image
  Future<void> pickImage() async {// Indicate loading
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      userImagePath = pickedFile.path;
      emit(EditUserPickImageSuccessState(imagePath: userImagePath!));
      await uploadImage(File(userImagePath!), uid);
    } else {
      emit(EditUserPickImageFailureState('No image selected'));
    }
  }

  // Upload image to Firestore storage
  Future<void> uploadImage(File imageFile, String uid) async {
    emit(EditUserImageUploadingState()); // Indicate uploading
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('$uid.jpg');

    try {
      final uploadTask = storageRef.putFile(imageFile);
      final imageUrl = await (await uploadTask).ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'imageUrl': imageUrl});
      userImageUrl = imageUrl;
      emit(EditUserImageUploadSuccessState(imageUrl: imageUrl));
    } catch (e) {
      emit(EditUserImageUploadFailureState(e.toString()));
    }
  }

  // Function to update user data in Firestore
  Future<void> updateUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(uid)
          .update({
        kUserName: userName ?? '', // Handle null values
        kUserPhoneNumber: phoneNumber ?? '',
        kUserBio: bio ?? '',
        kUserImage: userImageUrl ?? '',
      }).then((value) {
        if (kDebugMode) {
          print('User Updated');
        }});
      emit(EditUserSuccessState());
    } catch (error) {
      if (kDebugMode) {
        print("Error updating user: $error");
      } // Log the error for debugging
      emit(EditUserFailureState(error.toString()));
    }
  }

  void userNameChange(String? value) {
    userName = value;
    emit(EditUserStateChanged()); // Emit a new state to trigger UI update
  }

  void phoneNumberChange(String? value) {
    phoneNumber = value;
    emit(EditUserStateChanged());
  }

  void bioChange(String? value) {
    bio = value;
    emit(EditUserStateChanged());
  }

}