import 'package:flutter/material.dart';

extension BH on DateTime {
  String get dateInString {
    return "$year${month < 10 ? 0 : ''}$month${day < 10 ? 0 : ''}$day";
  }
}
