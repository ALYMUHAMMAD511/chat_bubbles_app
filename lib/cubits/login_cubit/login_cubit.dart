import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../helper/helper_functions.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitialState());

  var auth = FirebaseAuth.instance;

  Future<void> loginUser({required String email, required String password, context}) async
  {
    emit(LoginLoadingState());
    try
    {
      final UserCredential user = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(LoginSuccessState());
    }
    on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'User not Found';
          emit(LoginFailureState(errorMessage));
          break;
        case 'wrong-password':
          errorMessage = 'Wrong Password';
          emit(LoginFailureState(errorMessage));
          break;
        case 'invalid-email':
          errorMessage = 'Invalid Email';
          emit(LoginFailureState(errorMessage));
          break;
        case 'user-disabled':
          errorMessage = 'User has been disabled';
          emit(LoginFailureState(errorMessage));
          break;
        case 'too-many-requests':
          errorMessage =
          'Too many attempts, please try again later';
          emit(LoginFailureState(errorMessage));
          break;
        default:
          errorMessage =
          'An unexpected error occurred. Please try again later.';
          emit(LoginFailureState(errorMessage));

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
    }
  }
}
