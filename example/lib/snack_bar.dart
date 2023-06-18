import 'package:flutter/material.dart';

void showSnackbar({
  required BuildContext context,
  required String title,
  required String message,
}) {
  final snackBar = SnackBar(
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(message),
      ],
    ),
    margin: const EdgeInsets.only(bottom: 16, right: 8, left: 8),
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    behavior: SnackBarBehavior.floating,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
