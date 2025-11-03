import 'package:flutter/material.dart';
import 'package:buntsmatrimony/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
// adjust import path if needed

Future<void> handleSessionExpiry(BuildContext context) async {
  // 1️⃣ Clear all stored preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // 2️⃣ Show alert message
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Session Expired",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Your session has expired. Please login again."),
          actions: [
            TextButton(
              onPressed: () {
                // 3️⃣ Navigate back to Login page & remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("OK", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
