part of 'edit_user_cubit.dart';

@immutable
sealed class EditUserState {}

final class EditUserInitialState extends EditUserState {}

final class EditUserSuccessState extends EditUserState {}

final class EditUserFailureState extends EditUserState
{
  final String error;
  EditUserFailureState(this.error);
}

class EditUserPickImageSuccessState extends EditUserState {
  final String imagePath;
  EditUserPickImageSuccessState({required this.imagePath});
}

class EditUserPickImageFailureState extends EditUserState {
  final String error;
  EditUserPickImageFailureState(this.error);
}

class EditUserImageUploadingState extends EditUserState {}

class EditUserImageUploadSuccessState extends EditUserState {
  final String imageUrl;
  EditUserImageUploadSuccessState({required this.imageUrl});
}

class EditUserImageUploadFailureState extends EditUserState {
  final String error;
  EditUserImageUploadFailureState(this.error);
}

class EditUserStateChanged extends EditUserState {}