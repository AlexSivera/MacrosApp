import 'dart:io';

import 'package:flutter/widgets.dart';

// Native build of legacyFileImage — reads a recipe photo saved the old way,
// as a file path into the app's own document storage.
Widget? legacyFileImage(String path) {
  final file = File(path);
  if (!file.existsSync()) return null;
  return Image.file(file, fit: BoxFit.cover);
}
