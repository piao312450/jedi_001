
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<String?> loadSingleImage() async {
  print('123');
  ImagePicker _picker = ImagePicker();
  XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxHeight: 800, maxWidth: 600);
  if (image == null) return null;
  // Image.file(File(images.path)).
  return image.path;
}