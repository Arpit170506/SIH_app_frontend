import 'package:flutter/material.dart';
import '../screen/login_screen.dart';

// ======= Enhanced Helper Methods =======
void logout(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('लॉग आउट (Logout)'),
      content: Text('क्या आप वाकई लॉग आउट करना चाहते हैं? (Do you really want to logout?)'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('रद्द करें (Cancel)'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          },
          child: Text('हाँ (Yes)', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void showPlaceholderDialog(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text('यह सुविधा जल्द ही आएगी। (This feature is coming soon.)'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('ठीक है (OK)'),
        ),
      ],
    ),
  );
}