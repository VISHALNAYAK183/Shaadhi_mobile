import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:buntsmatrimony/chat/show_chats.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'matches.dart';
import 'search.dart';
import 'appbar.dart';
import 'custom_sidebar.dart';
import 'custom_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? matriId;
  int _selectedIndex = 0;
  Key _chatPageKey = UniqueKey();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _loadMatriId(); // Fetch matriId asynchronously
    _checkConnectivity();
  }

  Future<void> _loadMatriId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      matriId = prefs.getString('matriId');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        _chatPageKey = UniqueKey(); // Assign new key to refresh chat
      }
      _selectedIndex = index;
    });
  }

  Future<void> _checkConnectivity() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    _updateConnectionStatus(
      results.isNotEmpty ? results.first : ConnectivityResult.none,
    );

    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectionStatus(
        results.isNotEmpty ? results.first : ConnectivityResult.none,
      );
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    bool isConnected = result != ConnectivityResult.none;
    if (!isConnected && _isConnected) {
      _showNoInternetDialog();
    }
    setState(() {
      _isConnected = isConnected;
    });
  }

  void _showNoInternetDialog() {
    var localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min, // To keep it compact
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 40), // Larger icon
            SizedBox(height: 8), // Space between icon and text
            Text(
              localizations.translate('no_internet'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(localizations.translate('no_internet_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('ok')),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showBackDialog(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('confirm_exit')),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(localizations.translate('exit')),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(localizations.translate('no')),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<FormData>(
      canPop: false, // _selectedIndex == 0, // Only allow pop when on index 0
      onPopInvokedWithResult: (bool didPop, FormData? result) async {
        if (didPop) {
          return;
        }
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0; // Navigate back to Dashboard
          });
          return; // Prevent app from closing
        } else {
          final bool shouldPop = await _showBackDialog(context) ?? false;
          if (context.mounted && shouldPop) {
            exit(0);
          }
        }
      },

      child: Scaffold(
        appBar: CustomAppBar(),
        drawer: CustomSidebar(),
        body: matriId == null
            ? Center(
                child: CircularProgressIndicator(),
              ) // Show loading until matriId is available
            : IndexedStack(
                index: _selectedIndex,
                children: [
                  DashboardScreen(),
                  MatchedPage(),
                  ChatListPage(key: _chatPageKey),
                  // SubscriptionScreen(),
                  SearchPage(),
                ],
              ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
