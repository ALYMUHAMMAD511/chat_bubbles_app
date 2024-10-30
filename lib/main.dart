import 'package:chat_waves_app/cubits/edit_user_cubit/edit_user_cubit.dart';
import 'package:chat_waves_app/cubits/login_cubit/login_cubit.dart';
import 'package:chat_waves_app/cubits/logout_cubit/logout_cubit.dart';
import 'package:chat_waves_app/cubits/register_cubit/register_cubit.dart';
import 'package:chat_waves_app/screens/chat_screen.dart';
import 'package:chat_waves_app/screens/edit_user_screen.dart';
import 'package:chat_waves_app/screens/login_screen.dart';
import 'package:chat_waves_app/screens/home_screen.dart';
import 'package:chat_waves_app/screens/register_screen.dart';
import 'package:chat_waves_app/simple_bloc_observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/chat_cubit/chat_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = SimpleBlocObserver();
  runApp(const ChatBubblesApp());
}

class ChatBubblesApp extends StatelessWidget {
  const ChatBubblesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => RegisterCubit()),
        BlocProvider(create: (context) => LogoutCubit()),
        BlocProvider(create: (context) => EditUserCubit()..loadUserData()),
      ],
      child: MaterialApp(
        routes: {
          LoginScreen.id: (context) => LoginScreen(),
          RegisterScreen.id: (context) => RegisterScreen(),
          HomeScreen.id: (context) => HomeScreen(),
          EditUserScreen.id: (context) => EditUserScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == ChatScreen.id) {
            final recipientUserId = settings.arguments as String;
            final currentUserId = auth.currentUser!.uid;

            return MaterialPageRoute(
              builder: (context) {
                return BlocProvider(
                  create: (context) => ChatCubit()..getSenderUserData(currentUserId)..getRecipientUserData(recipientUserId)..initializeChat(currentUserId, recipientUserId),
                  child: ChatScreen(recipientUserId: recipientUserId),
                );
              },
            );
          }
          return null;
        },
        theme: ThemeData(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Colors.white,
          ),
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              iconColor: WidgetStateProperty.all<Color>(Colors.white),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: auth.currentUser != null ? HomeScreen.id : LoginScreen.id,
      ),
    );
  }
}