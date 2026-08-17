import 'package:flutter/widgets.dart';

// Web build of legacyFileImage — dart:io doesn't exist here, and no web row
// can have imagePath set in the first place (see recipes_table.dart), so
// this path is unreachable in practice; it exists only so the conditional
// export compiles.
Widget? legacyFileImage(String path) => null;
