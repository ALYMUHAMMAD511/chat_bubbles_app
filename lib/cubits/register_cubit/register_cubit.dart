// ignore_for_file: body_might_complete_normally_catch_error

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants.dart';
import '../../helper/helper_functions.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitialState());

  var auth = FirebaseAuth.instance;
  String? userImagePath;
  IconData suffix = Icons.visibility_sharp;
  bool isPasswordShown = true;
  File? pickedImage;

  Future<void> registerUser({
    required String email,
    required String password,
  }) async {
    emit(RegisterLoadingState());
    try {
      // Register the user with email and password
      final UserCredential user = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if an image is selected and upload it
      if (pickedImage != null) {
        await uploadImage(File(userImagePath!));
      }

      // Create the user document in Firestore
      await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(user.user!.uid)
          .set({
        kUserName: userName,
        kUserEmail: user.user!.email,
        kUserId: user.user!.uid,
        kUserImage: userImagePath, // This will store the image URL if uploadImage succeeded
        kUserPhoneNumber: '',
        kUserBio: '',
      });

      emit(RegisterSuccessState());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(RegisterFailureState('weak-password'));


      } else if (e.code == 'email-already-in-use') {
        emit(RegisterFailureState('email-already-in-use'));

      }
    } catch (e) {
      emit(RegisterFailureState('There was an Error, Try Again Later'));
     }
  }

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        pickedImage = File(pickedFile.path);
        userImagePath = pickedFile.path; // Store the image path

        emit(RegisterPickImageSuccessState(imagePath: userImagePath!));
      } else {
        emit(RegisterPickImageFailureState('No image selected.'));
      }
    } catch (e) {
      emit(RegisterPickImageFailureState(e.toString()));
    }
  }

  Future<void> uploadImage(File imageFile) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      emit(RegisterImageUploadFailureState('User is not logged in.'));
      return;
    }

    // Create a reference to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('user_images').child('$uid.jpg');
    final uploadTask = storageRef.putFile(imageFile);

    // Wait for the upload to complete
    await uploadTask.whenComplete(() async {
      try {
        final downloadURL = await storageRef.getDownloadURL();

        // Check if the Firestore document exists before updating
        final userDocRef = FirebaseFirestore.instance.collection(kUsersCollection).doc(uid);
        final userDocSnapshot = await userDocRef.get();

        if (userDocSnapshot.exists) {
          // Update the Firestore document with the image URL
          await userDocRef.update({kUserImage: downloadURL});
          emit(RegisterImageUploadSuccessState(imageUrl: downloadURL));
        } else {
          // If the document doesn't exist, create it first
          await userDocRef.set({
            kUserId: uid,
            kUserEmail: FirebaseAuth.instance.currentUser?.email,
            kUserImage: downloadURL,
            // Add other user fields here as necessary
          });
          emit(RegisterImageUploadSuccessState(imageUrl: downloadURL));
        }
      } catch (e) {
        emit(RegisterImageUploadFailureState('Failed to update Firestore with image URL'));
      }
    }).catchError((error){
      emit(RegisterImageUploadFailureState('Image upload failed: $error'));
    });
  }


  void changePasswordVisibility() {
    isPasswordShown = !isPasswordShown;
    suffix =
    isPasswordShown ? Icons.visibility_sharp : Icons.visibility_off_sharp;
    emit(RegisterPasswordChangeVisibilitySuccessState());
  }
}