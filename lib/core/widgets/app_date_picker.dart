import 'package:flutter/material.dart';

// Every date picker in the app goes through here so the buttons read
// "Cancelar" / "Aceptar" — Material's Spanish default shouts "ACEPTAR" next
// to a sentence-case "Cancelar".
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    cancelText: 'Cancelar',
    confirmText: 'Aceptar',
  );
}
