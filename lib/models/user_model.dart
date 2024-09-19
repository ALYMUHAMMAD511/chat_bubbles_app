import 'package:chat_waves_app/constants.dart';

class UserModel {
  final String userName;
  final String userEmail;
  final String userId;
  String? userImage;
  String? userPhoneNumber;
  String? userBio;

  UserModel(
      {required this.userName,
      required this.userEmail,
      required this.userId,
      this.userImage,
      this.userPhoneNumber,
      this.userBio});

  factory UserModel.fromJson(json) {
    return UserModel(
      userName: json[kUserName],
      userEmail: json[kUserEmail],
      userId: json[kUserId],
      userImage: json[kUserImage],
      userPhoneNumber: json[kUserPhoneNumber],
      userBio: json[kUserBio],
    );
  }
}
