import 'package:flutter/material.dart';
import 'package:sav_app/styles/colors.dart';

Widget customButton(
    {VoidCallback? tap,
    bool? status = false,
    String? text = 'Save',
    BuildContext? context}) {
  return GestureDetector(
    onTap: status == true ? null : tap,
    child: Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: status == false ? primaryColor : grey,
          borderRadius: BorderRadius.circular(16)),
      width: MediaQuery.of(context!).size.width,
      child: Text(
        status == false ? text! : 'Please wait...',
        style: TextStyle(color: white, fontSize: 18),
      ),
    ),
  );
}
