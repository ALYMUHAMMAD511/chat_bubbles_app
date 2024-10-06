import 'package:chat_waves_app/cubits/login_cubit/login_cubit.dart';
import 'package:chat_waves_app/helper/push_notifications.dart';
import 'package:chat_waves_app/screens/chat_screen.dart';
import 'package:chat_waves_app/screens/edit_user_screen.dart';
import 'package:chat_waves_app/screens/login_screen.dart';
import 'package:chat_waves_app/screens/home_screen.dart';
import 'package:chat_waves_app/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotifications().initNotifications();
  runApp(const ChatBubblesApp());
}

class ChatBubblesApp extends StatelessWidget {
  const ChatBubblesApp({super.key});


  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: MaterialApp(
        routes: {
          LoginScreen.id: (context) => LoginScreen(),
          RegisterScreen.id: (context) => const RegisterScreen(),
          ChatScreen.id: (context) => const ChatScreen(),
          HomeScreen.id: (context) => HomeScreen(),
          EditUserScreen.id: (context) => const EditUserScreen(),
        },
        theme: ThemeData(
          colorScheme: Theme
              .of(context)
              .colorScheme
              .copyWith(
            primary: Colors.white,
          ),
          iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                iconColor: WidgetStateProperty.all<Color>(Colors.white),
              )),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: auth.currentUser != null ? 'Home Screen' : 'Login Screen',
      ),
    );
  }
}
