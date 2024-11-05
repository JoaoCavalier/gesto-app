import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

showSnackBar(
    {required BuildContext context, required String text, bool isErro = true}) {
  SnackBar snackBar = SnackBar(
    content: Text(text),
    backgroundColor: (isErro) ? Colors.red : Colors.green,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
    duration: const Duration(seconds: 3),
    action: SnackBarAction(
        label: "",
        textColor: Colors.white,
        onPressed: () {}),
        showCloseIcon: true,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
