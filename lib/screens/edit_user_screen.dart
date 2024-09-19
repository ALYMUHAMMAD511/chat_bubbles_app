import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_waves_app/constants.dart';
import 'package:chat_waves_app/widgets/custom_button.dart';
import 'package:chat_waves_app/widgets/custom_text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/helper_functions.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  static String id = 'Edit User Screen';

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  String? userImagePath;
  String? userImageUrl; // This will hold the URL of the image from Firestore
  String? userName;
  String? phoneNumber;
  String? bio;
  bool isUploading = false;

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      setState(() {
        userImageUrl =
            userDoc.data()?['imageUrl']; // Fetch image URL if available
        userName = userDoc.data()?['userName'];
        phoneNumber = userDoc.data()?['phoneNumber'];
        bio = userDoc.data()?['bio'];
      });
    }
  }

  // Function to pick an image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Update the image path with the picked image
      setState(() {
        userImagePath = pickedFile.path;
      });

      // Upload the image to Firestore storage and await it
      await uploadImage(File(userImagePath!), uid);
    }
  }

  // Upload image to Firestore storage
  Future<void> uploadImage(File imageFile, String uid) async {
    setState(() {
      isUploading = true; // Show loading indicator
    });

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('$uid.jpg'); // Use the UID for the image path

    try {
      final uploadTask = storageRef.putFile(imageFile);
      final imageUrl =
          await (await uploadTask).ref.getDownloadURL(); // Await the URL

      // Update the image URL in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'imageUrl': imageUrl, // Ensure the image URL is updated in Firestore
      });

      setState(() {
        userImageUrl =
            imageUrl; // Update the local state with the new image URL
        isUploading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      setState(() {
        isUploading = false;
      });
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
        kUserName: userName,
        kUserPhoneNumber: phoneNumber,
        kUserBio: bio,
        kUserImage: userImageUrl, // Update the userImage field
      });

      // ignore: use_build_context_synchronously
      showSnackBar(context, 'Profile Updated Successfully', Colors.green);
    } catch (error) {
      if (kDebugMode) {
        print('Error updating user: $error');
      }
      // ignore: use_build_context_synchronously
      showSnackBar(context, '$error', Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(kPrimaryColor),
      appBar: AppBar(
        backgroundColor: HexColor(kPrimaryColor),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            const SizedBox(
              height: 60,
            ),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // CircleAvatar with user image or default image
                  CircleAvatar(
                    backgroundColor: HexColor(kSecondaryColor),
                    radius: 60,
                    child: CircleAvatar(
                      radius: 58,
                      backgroundImage: userImageUrl != null
                          ? CachedNetworkImageProvider(
                              userImageUrl!) // Load image from network
                          : userImagePath != null
                              ? FileImage(File(userImagePath!))
                                  as ImageProvider // Load local image
                              : AssetImage(kUserAvatar),
                      // Fallback to default image,
                    ),
                  ),
                  // Edit button
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: HexColor(kSecondaryColor),
                        radius: 15,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            pickImage();
                          });
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomTextFormField(
                prefixIcon: Icons.person_3_sharp,
                hint: 'Username',
                onChanged: (data) {
                  userName = data;
                },
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomTextFormField(
                prefixIcon: Icons.phone_sharp,
                hint: 'Phone Number',
                onChanged: (data) {
                  phoneNumber = data;
                },
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomTextFormField(
                prefixIcon: Icons.warning,
                hint: 'Bio',
                onChanged: (data) {
                  bio = data;
                },
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomButton(
                text: 'Update Profile',
                onPressed: () {
                  updateUser();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
