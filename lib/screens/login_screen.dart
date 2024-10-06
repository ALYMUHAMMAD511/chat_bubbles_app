// ignore_for_file: use_build_context_synchronously
import 'package:chat_waves_app/constants.dart';
import 'package:chat_waves_app/cubits/login_cubit/login_cubit.dart';
import 'package:chat_waves_app/screens/register_screen.dart';
import 'package:chat_waves_app/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../helper/helper_functions.dart';
import '../widgets/custom_text_form_field.dart';
import 'home_screen.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  static String id = 'Login Screen';
  bool isLoading = false;
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(kPrimaryColor),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state)
        {
          if (state is LoginLoadingState)
            {
              isLoading = true;
            }
          if(state is LoginSuccessState)
            {
              showSnackBar(
                  context, 'Logged in Successfully', Colors.green);
              Navigator.pushNamed(context, HomeScreen.id, arguments: email);
              isLoading = false;
            }
          else if(state is LoginFailureState)
          {
            showSnackBar(context, state.error, Colors.red);
          }
        },
        builder: (context, state) => ModalProgressHUD(
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
                    height: 250,
                    width: 325,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
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
                  height: 60,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {} on FirebaseAuthException catch (e) {
                            String errorMessage;
                            switch (e.code) {
                              case 'user-not-found':
                                errorMessage = 'User not Found';
                                break;
                              case 'wrong-password':
                                errorMessage = 'Wrong Password';
                                break;
                              case 'invalid-email':
                                errorMessage = 'Invalid Email';
                                break;
                              case 'user-disabled':
                                errorMessage = 'User has been disabled';
                                break;
                              case 'too-many-requests':
                                errorMessage =
                                'Too many attempts, please try again later';
                                break;
                              default:
                                errorMessage =
                                'An unexpected error occurred. Please try again later.';
                            }
                            showSnackBar(
                              context,
                              errorMessage,
                              Colors.red,
                            );
                          } catch (e) {
                            showSnackBar(
                              context,
                              'There was an Error, Try Again Later',
                              Colors.red,
                            );
                          } finally {

                          }
                        }
                      },
                      text: 'Login',
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
                        'Don\'t have an Account?',
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
                        Navigator.pushNamed(context, RegisterScreen.id);
                      },
                      child: Text(
                        'Register',
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
      ),
    );
  }

  IconData suffix = Icons.visibility_sharp;
  bool isPasswordShown = true;

  void changePasswordVisibility() {
    isPasswordShown = !isPasswordShown;
    suffix =
    isPasswordShown ? Icons.visibility_sharp : Icons.visibility_off_sharp;
  }
}
