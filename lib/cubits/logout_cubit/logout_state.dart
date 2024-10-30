part of 'logout_cubit.dart';

abstract class LogoutState {}

final class LogoutInitialState extends LogoutState {}

final class LogoutSuccessState extends LogoutState {}

final class LogoutFailureState extends LogoutState {
  final String error;

  LogoutFailureState(this.error);
}