import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_waves_app/constants.dart';
import 'package:chat_waves_app/cubits/edit_user_cubit/edit_user_cubit.dart';
import 'package:chat_waves_app/helper/helper_functions.dart';
import 'package:chat_waves_app/widgets/custom_button.dart';
import 'package:chat_waves_app/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';


// ignore: must_be_immutable
class EditUserScreen extends StatelessWidget {

  EditUserScreen({super.key});

  static String id = 'Edit User Screen';
  String? userImagePath;
  String? userImageUrl;
  String? userName;
  String? phoneNumber;
  String? bio;


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditUserCubit, EditUserState>(
      listener: (context, state) {
       if (state is EditUserSuccessState)
        {
          showSnackBar(context, 'User Updated Successfully', Colors.green);
        }
        else if (state is EditUserFailureState)
        {
          showSnackBar(context, state.error, Colors.red);
        }
      },
      builder: (context, state) {
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
                          backgroundImage: BlocProvider.of<EditUserCubit>(context).userImageUrl != null
                              ? CachedNetworkImageProvider(
                              BlocProvider.of<EditUserCubit>(context).userImageUrl!) // Load image from network
                              : BlocProvider.of<EditUserCubit>(context).userImagePath != null
                              ? FileImage(File(BlocProvider.of<EditUserCubit>(context).userImagePath!))
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
                              BlocProvider.of<EditUserCubit>(context).pickImage();
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
                    initialValue: BlocProvider.of<EditUserCubit>(context).userName,
                    hint: 'Username',
                    onChanged: (data) {
                      BlocProvider.of<EditUserCubit>(context).userNameChange(data);
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
                    initialValue: BlocProvider.of<EditUserCubit>(context).phoneNumber,
                    hint: 'Phone Number',
                    onChanged: (data) {
                      BlocProvider.of<EditUserCubit>(context).phoneNumberChange(data);
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
                    initialValue: BlocProvider.of<EditUserCubit>(context).bio,
                    hint: 'Bio',
                    onChanged: (data) {
                      BlocProvider.of<EditUserCubit>(context).bioChange(data);
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
                      BlocProvider.of<EditUserCubit>(context).updateUser();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
