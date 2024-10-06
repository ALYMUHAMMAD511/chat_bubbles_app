import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../helper/helper_functions.dart';
import '../../screens/login_screen.dart';
part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutInitialState());

  var auth = FirebaseAuth.instance;

  dynamic logout(context) async
  {
    emit(LogoutLoadingState());
    try
    {
      await auth.signOut();
      emit(LogoutSuccessState());
      navigateAndFinish(context, LoginScreen());
      showSnackBar(context, 'Logged Out Successfully', Colors.green);
    } on Exception catch (e)
    {
      emit(LogoutFailureState(e.toString()));
      showSnackBar(context, e.toString(), Colors.red);
    }
  }
}
