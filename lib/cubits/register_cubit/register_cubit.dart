import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';
import '../../helper/helper_functions.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState>
{
  RegisterCubit() : super(RegisterInitialState());

  var auth = FirebaseAuth.instance;
  String? userImagePath;

  Future<void> registerUser() async
  {
    final UserCredential user = await auth.createUserWithEmailAndPassword(
      email: email!,
      password: password!,
    );
      debugPrint(user.user!.email);

    // Create the user document in Firestore
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(user.user!.uid)
        .set({
      kUserName: userName,
      kUserEmail: user.user!.email,
      kUserId: user.user!.uid,
      kUserImage: userImagePath,
      kUserPhoneNumber: '',
      kUserBio: '',
    });
  }



  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
        userImagePath = pickedFile.path;
      // Upload the image to Firestore storage
      await uploadImage(File(userImagePath!));
    }
  }

  Future<void> uploadImage(File imageFile) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final storageRef =
    FirebaseStorage.instance.ref().child('user_images').child('$uid.jpg');
    final uploadTask = storageRef.putFile(imageFile);

    // Wait for the upload to complete
    await uploadTask.whenComplete(() async {
      final downloadURL = await storageRef.getDownloadURL();
      // Update the user's image in Firestore
      await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(uid)
          .update({kUserImage: downloadURL});
    });
  }

}
