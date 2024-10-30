import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutInitialState());

  var auth = FirebaseAuth.instance;

  dynamic logout(context) async
  {
    try
    {
      await auth.signOut();
      emit(LogoutSuccessState());
    } on FirebaseAuthException catch (e)
    {
      emit(LogoutFailureState(e.toString()));
    }
  }
}
