import 'package:flutter/material.dart';
import 'package:practice/dashboard.dart';
import 'package:practice/delete_profile/delete.dart';
import 'package:practice/inapp/subscription_list_screen.dart';
import 'package:practice/login.dart';
import 'package:practice/main_screen.dart';
import 'package:practice/pending_counts.dart';
import 'package:practice/payment_gateway.dart';
import 'package:practice/shortlist.dart';
import 'package:practice/profile_page.dart';
import 'package:practice/tearms.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_model.dart';
import 'api_service.dart';
import 'lang.dart';
import 'language_provider.dart';
import 'package:url_launcher/url_launcher.dart';
class CustomSidebar extends StatefulWidget {
  @override
  _CustomSidebarState createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  // static DashboardData? _cachedDashboardData;
  //late Future<DashboardData> _dashboardDataFuture;

  String profileImageUrl = "";
  String userName = "Loading...";
  String matriId = "Loading...";
  String gender = "";

  @override
  void initState() {
    super.initState();
    loadProfileData(); // Fetch data from SharedPreferences
  }

  Future<void> loadProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = prefs.getString('myName') ?? "N/A";
      matriId = prefs.getString('myMatriId') ?? "N/A";
      gender = prefs.getString('myGender') ?? "N/A";

      profileImageUrl = prefs.getString('myImageUrl') ??
          (int.tryParse(gender.toString()) == 1
              ? "assets/2.png"
              : "assets/1.png");
    });
  }

  /// Update the profile info (name & Matri ID) once API fetches data
  // void _updateProfileInfo(DashboardData data) {
  //   if (data.myProfile.isNotEmpty) {
  //     var profile = data.myProfile[0];

  //     setState(() {
  //       userName = profile.myName;
  //       matriId = profile.myMatriId;

  //       // If the profile has a valid image URL, update it
  //       if (profile.profileUrl.isNotEmpty &&
  //           !profile.profileUrl.contains("/null")) {
  //         profileImageUrl = profile.profileUrl;
  //         _storeProfileImage(profile.profileUrl);
  //       } else {
  //         profileImageUrl = (profile.gender == "1")
  //             ? "assets/2.png"
  //             : "assets/1.png"; // Default image based on gender
  //       }
  //     });
  //   }
  // }

  /// Store profile image URL in SharedPreferences for future use
  // Future<void> _storeProfileImage(String imageUrl) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("profile_image", imageUrl);
  // }
  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity, // Full width
            color: Color(0xFF8A2727), // Background color
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        (profileImageUrl != null && profileImageUrl.isNotEmpty)
                            ? NetworkImage(profileImageUrl) as ImageProvider
                            : AssetImage(int.tryParse(gender.toString()) == 1
                                ? "assets/2.png"
                                : "assets/1.png"),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    matriId,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
         Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSidebarItems(context, localizations),
                _buildCopyrightInfo(), // Copyright info at the bottom
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}

Widget _buildLoadingSidebar() {
  return ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: Color(0xFF8A2727)),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    ],
  );
}

Widget _buildErrorSidebar() {
  return ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: Color(0xFF8A2727)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text("User Name",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
    ],
  );
}

Widget _buildSidebarItems(
    BuildContext context, AppLocalizations localizations) {
  var languageProvider = Provider.of<LanguageProvider>(context);
  return Column(
    children: [
      ListTile(
        leading: Icon(Icons.dashboard),
        title: Text(localizations.translate('dashboard')),
        onTap: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen())),
      ),
      ListTile(
        leading: Icon(Icons.bookmark),
        title: Text(localizations.translate('shortlist')),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ShortlistsPage())),
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text(localizations.translate('profile')),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfilePage1())),
      ),
      ListTile(
        leading: Icon(Icons.notifications),
        title: Text(localizations.translate('plans')),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) =>SubscriptionPaymentPage())),
      ),
      ListTile(
        leading: Icon(Icons.language, color: Colors.blue),
        title: Text(localizations.translate('Language')),
        trailing: DropdownButton<String>(
          value: languageProvider.locale.languageCode,
          icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
          onChanged: (String? newValue) {
            if (newValue != null) {
              languageProvider.changeLanguage(newValue);
            }
          },
          items: [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
          ],
        ),
      ),
      ListTile(
        leading: Icon(Icons.pending_actions),
        title: Text(localizations.translate('pending_counts')),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => PendingCountsPage())),
      ),
      
      ListTile(
        leading: Icon(Icons.delete),
        title: Text(localizations.translate('profileStatus')),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChangeStatusPage())),
      ),
      // ListTile(
      //   leading: Icon(Icons.insert_drive_file_rounded),
      //   title: Text(localizations.translate('Payment')),
      //   onTap: () => Navigator.push(context,
      //       MaterialPageRoute(builder: (context) =>MyApp1())),
      // ),
       ListTile(
        leading: Icon(Icons.insert_drive_file_rounded),
        title: Text(localizations.translate('terms')),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => TermsAndConditionsPage())),
      ),
      
      ListTile(
        leading: Icon(Icons.power_settings_new),
        title: Text(localizations.translate('logout')),
        onTap: () => _showLogoutDialog(context),
      ),
    ],
  );
}
Widget _buildCopyrightInfo() {
  String currentYear = DateTime.now().year.toString();

  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(text: "$currentYear © Made by "),
          TextSpan(
            text: "Mobiezy",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      style: TextStyle(fontSize: 14, color: Colors.grey),
      textAlign: TextAlign.center,
    ),
  );
}


void _showLogoutDialog(BuildContext context) {
  var localizations = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localizations.translate('confirm_logout')),
        content: Text(localizations.translate('confirm_text')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text(localizations.translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              // Clear cached data on logout
              prefs.clear();
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false, // Removes all previous routes
              );
            },
            child: Text(localizations.translate('logout'), style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
