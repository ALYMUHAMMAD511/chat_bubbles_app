import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';


String? userName;
String? phoneNumber;
String? bio;
String? email;
String? password;
String? message;
late final ScrollController scrollController;
var auth = FirebaseAuth.instance;

Future<void> loginUser() async {
  final UserCredential user = await auth.signInWithEmailAndPassword(
    email: email!,
    password: password!,
  );
  if (kDebugMode) {
    print(user.user!.email);
  }
}

dynamic logout(context) async {
  // Sign out of Firebase Authentication
  await auth.signOut();
  navigateAndFinish(context, const LoginScreen());
  showSnackBar(context, 'Logged Out Successfully', Colors.green);
}

void showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
    ),
  );
}

void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => widget,
    ),
        (Route<dynamic> route) => false);
