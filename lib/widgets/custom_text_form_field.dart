import 'package:chat_waves_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatelessWidget {
  CustomTextFormField(
      {super.key,
      required this.hint,
      required this.onChanged,
      this.isPassword = false,
      required this.prefixIcon,
      this.suffixIcon,
      this.suffixPressed,
      this.initialValue});

  final IconData prefixIcon;
  IconData? suffixIcon;
  final String hint;
  String? initialValue;
  bool? isPassword;
  Function(String)? onChanged;
  VoidCallback? suffixPressed;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      cursorColor: HexColor(kSecondaryColor),
      validator: (data) {
        if (data!.isEmpty) {
          return 'This Field is Required';
        }
        return null;
      },
      onChanged: onChanged,
      obscureText: isPassword!,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(25),
        fillColor: Colors.white,
        focusColor: Colors.white,
        prefixIcon: Icon(
          prefixIcon,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            suffixIcon,
            color: HexColor('#49454F'),
          ),
          onPressed: suffixPressed,
        ),
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: HexColor('#FF5A00'),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        filled: true,
      ),
    );
  }
}
