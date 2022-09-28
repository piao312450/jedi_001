import 'package:flutter/material.dart';

Widget myCheckBox(bool isChecked) {
  double r = 35;
  if(isChecked) {
    return Container(
      width: r,
      height: r,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle
      ),
      child: const Icon(Icons.check),
    );
  } else {
    return Container(
      width: r,
      height: r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
            color: Colors.white,
      border: Border.all(color: Colors.grey, width: 2)),
    );
  }
}