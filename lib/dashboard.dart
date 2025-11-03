import 'package:flutter/material.dart';
import 'package:buntsmatrimony/checkProfiles.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:buntsmatrimony/main_screen.dart';
import 'package:buntsmatrimony/profile_page.dart';
import 'package:buntsmatrimony/upload_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'dashboard_model.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final String? matriId;
  // final dynamic userData;

  const DashboardScreen({super.key, this.matriId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color _signColor = Color(0xFFea4a57);
  final Color _backgroundColor = Color(0xFFF1F1F1);
  final Color _progressColor = Color(0xFF4CAF50);
  final Color _boxBackground = Color(0xFFF0F0F0);
  int _selectedIndex = 0;
  final MaxLimit _maxLimit = MaxLimit();
  bool isDashboardLoaded = false;
  late Future<DashboardData> _dashboardDataFuture;
  bool _shouldShowPopup = true;

  @override
  void initState() {
    super.initState();
    //  _dashboardDataFuture = ApiService.fetchDashboardData();
    _loadDashboardData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadDashboardData() async {
    _dashboardDataFuture = ApiService.fetchDashboardData(context); // Fetch data
    DashboardData dashboardData = await _dashboardDataFuture; // Wait for data

    // Access the first profile safely
    Profile? profile = dashboardData.myProfile.isNotEmpty
        ? dashboardData.myProfile.first
        : null;

    String userScore = profile?.Score ?? "N/A";
    String expiredate = profile?.expiry_date ?? "N/A";
    String myName = profile?.myName ?? "N/A";
    String myMatriId = profile?.myMatriId ?? "N/A";
    String myImageUrl = profile?.profileUrl ?? "assets/2.png";
    String myGender = profile?.gender ?? "N/A";
    String creator_phone = profile?.creator_phone ?? "N/A";

    // Access the first notification safely
    AppNotification? notification = dashboardData.advnotifivation.isNotEmpty
        ? dashboardData.advnotifivation.first
        : null;
    String notification_url = notification?.notiurl ?? "N/A";

    print("Notification: $notification_url");
    await saveProfileData(
      userScore,
      expiredate,
      myName,
      myMatriId,
      myImageUrl,
      myGender,
      creator_phone,
    );

    print(
      'dashboardData.myProfile[0].profileUrl.isEmpty ${dashboardData.myProfile[0].profileUrl.isEmpty}',
    );
    if (dashboardData.myProfile[0].profileUrl.isEmpty) {
      _showUploadPopup(dashboardData.myProfile[0].myMatriId);
    }

    setState(() {
      isDashboardLoaded = true;
    });
  }

  // Widget buildLabels(ProfileList profileData) {
  //   var localizations = AppLocalizations.of(context);
  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           buildLabel(
  //               '${localizations.translate('viewed_by_me')} (${profileData.i_viewed})'),
  //           buildLabel(
  //               '${localizations.translate('viewed_by_others')} (${profileData.viewed_by})'),
  //           buildLabel(
  //               '${localizations.translate('liked_by_me')} (${profileData.i_liked})'),
  //         ],
  //       ),
  //       const SizedBox(height: 5), // Spacing between rows
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           buildLabel(
  //               '${localizations.translate('liked_by_others')} (${profileData.liked_by})'),
  //           buildLabel(
  //               '${localizations.translate('mutually_liked')} (${profileData.mutual_liked})'),
  //           buildLabel(
  //               '${localizations.translate('contacted')} (${profileData.profile_contacted})'),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget buildLabel(String text) {
    return Container(
      width: 100, // Specify width
      height: 30, // Specify height
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNotificationBox(List<String> imageUrls) {
    PageController _pageController = PageController(initialPage: 0);
    int _currentPage = 0;
    Timer? _timer;
    bool _isPaused = false;

    void _startAutoScroll() {
      _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
        if (!_isPaused) {
          if (_currentPage < imageUrls.length - 1) {
            _currentPage++;
          } else {
            _currentPage = 0; // Loop back to first image
          }
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    if (imageUrls.length > 1) {
      _startAutoScroll();
    }

    return Container(
      width: double.infinity,
      height: 260,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: PageView.builder(
          controller: _pageController,
          itemCount: imageUrls.length,
          onPageChanged: (index) {
            _currentPage = index;
          },
          itemBuilder: (context, index) {
            return GestureDetector(
              onTapDown: (_) {
                _isPaused = true;
              },
              onTapUp: (_) {
                _isPaused = false;
              },
              onTapCancel: () {
                _isPaused = false;
              },
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print("Image Error: ${imageUrls[index]}");
                  return Center(child: Text("Image not available"));
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageSquareBox(
    String score,
    String expiredate,
    String planStatus,
  ) {
    final PageController _pageController = PageController();
    int _currentPage = 0;

    Map<String, String> imageMap = {
      "0": 'assets/Welcome.jpg', // Default image (non-clickable)
      "1": 'assets/EditAdditional.jpg',
      "2": 'assets/EditEducation.jpg',
      "3": 'assets/horoscope.jpg',
      "4": 'assets/EditFamily.jpg',
      "5": 'assets/EditPhoto.jpg',
    };

    List<String> selectedImages = [
      'assets/Welcome.jpg',
    ]; // Always include Welcome
    for (var key in imageMap.keys) {
      if (key != "0" && score.contains(key)) {
        selectedImages.add(imageMap[key]!);
      }
    }

    String formattedDate = expiredate;
    try {
      DateTime parsedDate = DateTime.parse(expiredate);
      formattedDate = DateFormat("dd-MMM-yyyy").format(parsedDate);
    } catch (e) {
      formattedDate = "Invalid Date";
    }

    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < selectedImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });

    return Container(
      width: double.infinity,
      height: 260,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: PageView.builder(
                controller: _pageController,
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  String imagePath = selectedImages[index];

                  return GestureDetector(
                    onTap: () {
                      if (imagePath != 'assets/Welcome.jpg') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage1(),
                          ),
                        );
                      }
                    },
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          if (planStatus == "Paid")
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Plan Expiry Date: $formattedDate",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget buildDashboardWidget(
  //     BuildContext context, DashboardData dashboardData) {
  //   String userScore = dashboardData.myProfile.isNotEmpty
  //       ? dashboardData.myProfile[0].Score
  //       : "N/A"; // Ensure list is not empty
  //   String expiredate = dashboardData.myProfile.isNotEmpty
  //       ? dashboardData.myProfile[0].expiry_date
  //       : "N/A";
  //   // String planStatus = dashboardData.myProfile.isNotEmpty ? dashboardData.myProfile[0].planStatus : "N/A";
  //   String myName = dashboardData.myProfile.isNotEmpty
  //       ? dashboardData.myProfile[0].myName
  //       : "N/A";
  //   String myMatriId = dashboardData.myProfile.isNotEmpty
  //       ? dashboardData.myProfile[0].myMatriId
  //       : "N/A";
  //   String myImageUrl = dashboardData.myProfile.isNotEmpty
  //       ? dashboardData.myProfile[0].profileUrl
  //       : "N/A";
  //   String myGender = dashboardData.myProfile.isNotEmpty
  //       ? dashboardData.myProfile[0].gender
  //       : "N/A";
  //   String planStatus = dashboardData.myProfile.isNotEmpty
  //       ? dashboardData.myProfile[0].planStatus
  //       : "N/A";
  //   saveProfileData(
  //       userScore, expiredate, myName, myMatriId, myImageUrl, myGender);
  //   return _buildImageSquareBox(userScore, expiredate, planStatus);
  //   // return _buildHorizontalCardList(data.recentlyLoggedIn, planStatus),
  // }

  Future<void> saveProfileData(
    String userScore,
    String expiredate,
    String name,
    String matriId,
    String imageUrl,
    String myGender,
    String creator_phone,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('userScore', userScore);
    await prefs.setString('expiredate', expiredate);
    await prefs.setString('myName', name);
    await prefs.setString('myMatriId', matriId);
    await prefs.setString('myImageUrl', imageUrl);
    await prefs.setString('myGender', myGender);
    await prefs.setString('creator_phone', creator_phone);
  }
  //planStatus

  //String planStatus = dashboardData.myProfile.isNotEmpty ? dashboardData.myProfile[0].planStatus : "N/A";

  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<DashboardData>(
          future: _dashboardDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(" "));
            }
            if (snapshot.hasData) {
              DashboardData data = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: data.myProfile.isNotEmpty
                                  ? (double.tryParse(
                                              data.myProfile[0].percentage,
                                            ) ??
                                            0.0) /
                                        100
                                  : 0.0,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(
                                _progressColor,
                              ),
                              semanticsValue: data.myProfile.isNotEmpty
                                  ? "${data.myProfile[0].percentage}%"
                                  : "0%",
                              minHeight: 8,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          data.myProfile.isNotEmpty
                              ? "${data.myProfile[0].percentage}%"
                              : "0%",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // buildLabels(data.profilecount),
                    SizedBox(height: 10),
                    _buildImageSquareBox(
                      data.myProfile.isNotEmpty ? data.myProfile[0].Score : "0",
                      data.myProfile.isNotEmpty
                          ? data.myProfile[0].expiry_date
                          : "0",
                      data.myProfile.isNotEmpty
                          ? data.myProfile[0].planStatus
                          : "0",
                    ),
                    if (data.advnotifivation != null &&
                        data.advnotifivation.isNotEmpty)
                      if (data.advnotifivation.isNotEmpty)
                        _buildNotificationBox(
                          data.advnotifivation.map((e) => e.notiurl).toList(),
                        ),
                    _buildSectionTitle(
                      (localizations.translate(
                        'Recently Active Members',
                      )).toString(),
                    ),
                    _buildHorizontalCardList(data.recentlyLoggedIn),
                    SizedBox(height: 15),
                    _buildSectionTitle(
                      (localizations.translate('matchedProfile')).toString(),
                    ),
                    _buildHorizontalCardList(data.matched),
                    SizedBox(height: 10),
                    _buildSectionTitle(
                      (localizations.translate('recentlyJoined')).toString(),
                    ),
                    _buildHorizontalCardList(data.recentlyJoined),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulating API call

    setState(() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (Route<dynamic> route) => false, // Removes all previous routes
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: _signColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showUploadPopup(String matri_id) {
    var localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          localizations.translate('upload_profile'),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.grey,
            ), // Profile icon
            SizedBox(height: 10),
            Text(localizations.translate('profile_msg')),
            SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                setState(() {
                  _shouldShowPopup = false; // Never show again
                });
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => UploadImageDash(
                //         matriId: widget.matriId.toString()), // ProfilePage1(),
                //   ),
                // );

                print('widget.matriId, ${matri_id}');
                String value = await uploadImage(matri_id.toString());
                print('widget.value, ${value}');
                value == "uploaded"
                    ? _refreshData()
                    : _showUploadPopup(matri_id.toString());

                /* Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                        (Route<dynamic> route) => false);*/
              }, // Function to trigger upload
              icon: Icon(Icons.upload),
              label: Text(localizations.translate('upload_now')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Future.delayed(Duration(seconds: 5), () {
                _showUploadPopup(matri_id); // Show again after 5 seconds
              });
            },
            child: Text(localizations.translate('cancel')),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCardList(List<User> users) {
    return SizedBox(
      height: 190, // increased height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        itemBuilder: (context, index) {
          User user = users[index];

          String imageUrl = user.imageUrl.isNotEmpty
              ? user.imageUrl
              : int.tryParse(user.gender.toString()) == 1
              ? 'assets/1.png'
              : 'assets/2.png';

          return GestureDetector(
            onTap: () async {
              await _maxLimit.checkProfileView(user.matriId, context);
            },
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(right: 12), // gap between cards
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // round corners
                        child: imageUrl.startsWith('http')
                            ? Image.network(
                                imageUrl,
                                width: 110,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    int.tryParse(user.gender.toString()) == 1
                                        ? 'assets/2.png'
                                        : 'assets/1.png',
                                    width: 110,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                imageUrl,
                                width: 110,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),

                      // Verification icon
                      if (user.planStatus == "Paid")
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Image.asset(
                            'assets/verification_new.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Name
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: _signColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                  // Age & Matri ID (horizontal)
                  Row(
                    children: [
                      Text(
                        "${user.age}yrs",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2d2d2d),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.matriId,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2d2d2d),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: _signColor),
      title: Text(title, style: TextStyle(color: _signColor)),
      onTap: onTap,
    );
  }
}
