part of 'register_cubit.dart';

sealed class RegisterState {}

final class RegisterInitialState extends RegisterState {}

final class RegisterLoadingState extends RegisterState {}

final class RegisterSuccessState extends RegisterState {}

final class RegisterFailureState extends RegisterState
{
  final String error;
  RegisterFailureState(this.error);
}

final class RegisterPasswordChangeVisibilitySuccessState extends RegisterState {}

class RegisterPickImageSuccessState extends RegisterState {
  final String imagePath;
  RegisterPickImageSuccessState({required this.imagePath});
}

class RegisterPickImageFailureState extends RegisterState {
  final String error;
  RegisterPickImageFailureState(this.error);
}

class RegisterImageUploadingState extends RegisterState {}

class RegisterImageUploadSuccessState extends RegisterState {
  final String imageUrl;
  RegisterImageUploadSuccessState({required this.imageUrl});
}

class RegisterImageUploadFailureState extends RegisterState {
  final String error;
  RegisterImageUploadFailureState(this.error);
}