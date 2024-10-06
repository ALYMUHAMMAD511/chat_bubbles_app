// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:chat_waves_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../constants.dart';
import '../helper/helper_functions.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  static String id = 'Register Screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isLoading = false;

  GlobalKey<FormState> formKey = GlobalKey();

  IconData suffix = Icons.visibility_sharp;
  bool isPasswordShown = true;
  String? userImagePath;

  void changePasswordVisibility() {
    isPasswordShown = !isPasswordShown;
    suffix =
        isPasswordShown ? Icons.visibility_sharp : Icons.visibility_off_sharp;
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(kPrimaryColor),
      body: ModalProgressHUD(
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

                            },
                            icon: Icon(
                              Icons.add_photo_alternate,
                              size: 30,
                              color: HexColor(kSecondaryColor),
                            ),
                          )
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
                            child: Image.file(
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
                  suffixIcon: suffix,
                  isPassword: isPasswordShown,
                  suffixPressed: changePasswordVisibility,
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
                        isLoading = true;
                        setState(() {});
                        try {
                          showSnackBar(
                              context, 'Registered Successfully', Colors.green);
                          Navigator.pushNamed(context, HomeScreen.id,
                              arguments: email);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            showSnackBar(context, 'Weak password', Colors.red);
                          } else if (e.code == 'email-already-in-use') {
                            showSnackBar(
                                context, 'Email Already Exists', Colors.red);
                          }
                        } catch (e) {
                          showSnackBar(
                              context,
                              'There was an Error, Try Again Later',
                              Colors.red);
                        }
                        isLoading = false;
                        setState(() {});
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
      ),
    );
  }
}
