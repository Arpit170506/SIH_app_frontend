import 'package:flutter/material.dart';
import '../screen/login_screen.dart';

void logout(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Logout (लॉग आउट)'),
      content: const Text('Do you really want to logout? (क्या आप वाकई लॉग आउट करना चाहते हैं?)'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel (रद्द करें)'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text('Yes (हाँ)', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

// --- NEW REUSABLE DIALOG FUNCTION ---
void showSuccessDialog(BuildContext context, String title, String content, VoidCallback onOkPressed) {
  showDialog(
    context: context,
    // Prevent dismissing the dialog by tapping outside of it
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onOkPressed,
          child: const Text('OK (ठीक है)'),
        ),
      ],
    ),
  );
}


// This function can still be used for simple placeholders
void showPlaceholderDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: const Text('This feature is coming soon. (यह सुविधा जल्द ही आएगी।)'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK (ठीक है)'),
        ),
      ],
    ),
  );
}