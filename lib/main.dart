import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:buntsmatrimony/login.dart';
import 'package:buntsmatrimony/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_provider.dart';
import 'lang.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            supportedLocales: [Locale('en', ''), Locale('kn', '')],
            localizationsDelegates: [
              const AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: FutureBuilder<Widget>(
              future: _getLoginData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ); // Show loading indicator while checking login
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(child: Text("Error: ${snapshot.error}")),
                  );
                } else {
                  return snapshot.data ??
                      LoginScreen(); // Navigate based on login status
                }
              },
            ),
          );
        },
      ),
    );
  }
}

Future<Widget> _getLoginData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? matriId = prefs.getString("matriId");

  if (matriId == null || matriId.isEmpty) {
    return LoginScreen();
  } else {
    return MainScreen();
  }
}
