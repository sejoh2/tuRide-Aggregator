import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final Widget? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.obscureText,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade600),
            borderRadius: BorderRadius.circular(15),
          ),

          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}
