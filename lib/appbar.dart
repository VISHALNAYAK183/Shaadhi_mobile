import 'package:flutter/material.dart';
import 'package:buntsmatrimony/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String myName = "Loading...";
  String myMatriId = "Loading...";
  String profileImageUrl = "";
  String gender = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  /// Load user profile data from SharedPreferences
  Future<void> loadProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int retries = 0;
    while (!prefs.containsKey('myName') ||
        !prefs.containsKey('myMatriId') ||
        !prefs.containsKey('myImageUrl')) {
      if (retries >= 10) break; // Prevent infinite loop
      await Future.delayed(const Duration(milliseconds: 500));
      retries++;
    }

    setState(() {
      myName = prefs.getString('myName') ?? "N/A";
      myMatriId = prefs.getString('myMatriId') ?? "N/A";
      gender = prefs.getString('myGender') ?? "N/A";
      profileImageUrl = prefs.getString('myImageUrl') ?? "";
      updateProfileImage();
      isLoading = false;
    });
  }

  /// Update profile image when changed
  void updateProfileImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String newImageUrl = prefs.getString('myImageUrl') ?? "";

    if (profileImageUrl != newImageUrl) {
      setState(() {
        profileImageUrl = newImageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFea4a57),
      iconTheme: const IconThemeData(color: Colors.white),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage1()),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    myName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    myMatriId,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            isLoading
                ? const SizedBox(width: 36, height: 36)
                : CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    backgroundImage: (profileImageUrl.isNotEmpty)
                        ? NetworkImage(profileImageUrl) as ImageProvider
                        : AssetImage(
                            int.tryParse(gender) == 1
                                ? "assets/2.png"
                                : "assets/1.png",
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}
