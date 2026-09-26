import 'package:flutter/material.dart';

// The one way a numeric field shows its unit: label without the unit
// ("Altura"), unit as a suffix ("cm"). A suffix only shows while the label
// floats, so the label is pinned floating — otherwise an empty field reads
// "Altura" with no hint of whether it wants cm or m until you type.
InputDecoration unitInputDecoration({
  required String label,
  required String unit,
  String? hint,
  String? errorText,
}) {
  return InputDecoration(
    labelText: label,
    suffixText: unit,
    hintText: hint,
    errorText: errorText,
    errorMaxLines: 3,
    floatingLabelBehavior: FloatingLabelBehavior.always,
  );
}
