// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:chat_waves_app/cubits/register_cubit/register_cubit.dart';
import 'package:chat_waves_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../constants.dart';
import '../helper/helper_functions.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';

// ignore: must_be_immutable
class RegisterScreen extends StatelessWidget {
  RegisterScreen({
    super.key,
  });

  static String id = 'Register Screen';
  bool isLoading = false;
  GlobalKey<FormState> formKey = GlobalKey();
  String? userImagePath;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(kPrimaryColor),
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterLoadingState) {
            isLoading = true;
          } else if (state is RegisterSuccessState) {
            Navigator.pushNamed(context, HomeScreen.id);
            showSnackBar(context, 'User Registered Successfully', Colors.green);
            isLoading = false;
          } else if (state is RegisterFailureState) {
            showSnackBar(context, state.error, Colors.red);
            isLoading = false;
          } else if (state is RegisterPickImageSuccessState) {
            userImagePath = state.imagePath; // Update with the image path
          } else if (state is RegisterPickImageFailureState) {
            showSnackBar(context, state.error, Colors.red);
          }
        },
        builder: (context, state)
        {
          return ModalProgressHUD(
            progressIndicator: CircularProgressIndicator(
              backgroundColor: HexColor(kSecondaryColor),
            ),
            inAsyncCall: isLoading,
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  Center(
                    child: Image.asset(
                      kAppLogo,
                      height: 115,
                      width: 300,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        fontSize: 32,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  userImagePath == null
                      ? Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: HexColor(kSecondaryColor),
                          radius: 60,
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.asset(kUserAvatar),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            BlocProvider.of<RegisterCubit>(context).pickImage();
                          },
                          icon: Icon(
                            Icons.add_photo_alternate,
                            size: 30,
                            color: HexColor(kSecondaryColor),
                          ),
                        ),
                      ],
                    ),
                  )
                      : Center(
                    child: CircleAvatar(
                      backgroundColor: HexColor(kSecondaryColor),
                      radius: 60,
                      child: CircleAvatar(
                        radius: 58,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          // Show either local file or Firebase URL
                          child: userImagePath!.startsWith('http')
                              ? Image.network(
                            userImagePath!,
                            width: 116,
                            height: 116,
                            fit: BoxFit.cover,
                          )
                              : Image.file(
                            File(userImagePath!),
                            width: 116,
                            height: 116,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
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
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomTextFormField(
                      prefixIcon: Icons.alternate_email_sharp,
                      hint: 'Email',
                      onChanged: (data) {
                        email = data;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomTextFormField(
                      prefixIcon: Icons.lock,
                      suffixIcon: BlocProvider.of<RegisterCubit>(context).suffix,
                      isPassword: BlocProvider.of<RegisterCubit>(context).isPasswordShown,
                      suffixPressed: BlocProvider.of<RegisterCubit>(context).changePasswordVisibility,
                      hint: 'Password',
                      onChanged: (data) {
                        password = data;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            BlocProvider.of<RegisterCubit>(context)
                                .registerUser(
                              email: email!,
                              password: password!,
                            );
                          }
                        },
                        text: 'Register',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Already have an Account?',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: HexColor(kSecondaryColor),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
