import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:practice/chat/chats.dart';
import 'package:practice/checkProfiles.dart';
import 'package:practice/inapp/subscription_list_screen.dart';
import 'package:practice/lang.dart';
import 'package:practice/payment_gateway.dart';
import 'api_service.dart';
import 'dashboard_model.dart';
import 'Block.dart';
import 'dart:ui' as ui;

class ProfilePage extends StatefulWidget {
  final String matriId;

  const ProfilePage({Key? key, required this.matriId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String selectedSection = 'Basic';
  int _selectedIndex = 0;
  //bool _isLiked = false;
  final MaxLimit _maxLimit = MaxLimit();
  late Future<ProfileViewData> _profileDataFuture;

  final Color _signColor = Color(0xFF8A2727);
  @override
  void initState() {
    super.initState();
    print("profilepage");
    _profileDataFuture = ApiService.fetchProfileViewData(context,widget.matriId);
    _checkIfShortlisted(widget.matriId);
    _checkIfLiked(widget.matriId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var localizations = AppLocalizations.of(context);
    setState(() {
      selectedSection = localizations.translate('basic');
    });
  }

  Future<void> _checkIfShortlisted(String matriId) async {
    try {
      ShortlistData shortlistData =
          await ApiService.fetchShortlistedProfiles(context); // ✅ Corrected type

      setState(() {
        _isShortlisted =
            shortlistData.profiles.any((profile) => profile.matriId == matriId);
      });

      debugPrint("Shortlist status for $matriId: $_isShortlisted");
    } catch (error) {
      debugPrint("Error fetching shortlist data: $error");
    }
  }

  //Added Extra
  Future<void> _checkIfLiked(String matriId) async {
    try {
      Map<String, dynamic> response =
          await ApiService.fetchLikedProfiles(context);
      LikeData likedata = LikeData.fromJson(response, ApiService.baseUrl);

      setState(() {
        _isLiked = likedata.profiles.any((profile) => profile.id == matriId);
      });
    } catch (error) {
      debugPrint("Error fetching shortlist data: $error");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Color(0xFF0134d4);

    return Scaffold(
      body: FutureBuilder<ProfileViewData>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          profileview profile = snapshot.data!.dataout[0];
          print("Profile url${profile.url}");
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.black, size: 25), // Back button icon
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(30),
                  // Adjust height
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Align(
                      alignment:
                          Alignment.topLeft, // Moves the container to the left
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4), // Adds padding
                        decoration: BoxDecoration(
                          color: Color.fromARGB(
                              181, 255, 255, 255), // Background color
                          borderRadius:
                              BorderRadius.circular(12), // Circular border
                        ),
                        child: Text(
                          widget.matriId,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                expandedHeight: screenHeight * 0.5,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            color: Colors.black,
                            width: 1), // Border only at the top
                      ),
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(
                              10)), // Rounded corners only at the top
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10)), // Match border radius
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          profile.url.isNotEmpty &&
                                  profile.url.toLowerCase() != "null"
                              ? Image.network(
                                  profile.url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      int.tryParse(profile.gender.toString()) ==
                                              1
                                          ? 'assets/2.png'
                                          : 'assets/1.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  profile.gender == 1
                                      ? 'assets/2.png'
                                      : 'assets/1.png',
                                  fit: BoxFit.cover,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      _buildActionButtons(profile),
                      const Divider(
                          thickness: 3, color: Colors.grey), // Line added here
                      _buildPersonalInfoSection(profile),
                      _buildMoreSection(),

                      _buildDynamicContent(profile),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

//ADD
  Widget _buildPersonalInfoSection(profileview profile) {
    var localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              localizations.translate('personal_info'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildInfoRow(localizations.translate('name'), profile.firstName),
          _buildInfoRow(localizations.translate('age'), profile.age.toString()),
          _buildInfoRow(
              localizations.translate('height'), "${profile.height} cm"),
          _buildInfoRow(localizations.translate('place'), profile.city),
          _buildInfoRow(
              localizations.translate('qualification'), profile.qualification),
        ],
      ),
    );
  }

  bool _isShortlisted = false;
  bool _isLiked = false;
//End
  Widget _buildActionButtons(profileview profile) {
    var localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          _buildIconButton(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            localizations.translate('like'),
            color: _isLiked ? Colors.red : Colors.blue,
            onPressed: () async {
              try {
                if (_isLiked) {
                  // Call remove shortlist API
                  Removelike response =
                      await ApiService.fetchRemovelikeData(context,widget.matriId);
                  debugPrint("Removed from Liked: ${response.message}");

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Removed from Liked")),
                  );
                } else {
                  // Call add shortlist API
                  Addlike response =
                      await ApiService.fetchAddlikeData(context,widget.matriId);
                  debugPrint("Liked Successfully: ${response.message}");

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Liked Successfully!")),
                  );
                }

                // Toggle the shortlist state
                setState(() {
                  _isLiked = !_isLiked;
                });
              } catch (error) {
                debugPrint("Error updating Shortlist: $error");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update Like. Try again!")),
                );
              }
            },
          ),

          _buildIconButton(
            _isShortlisted ? Icons.bookmark : Icons.bookmark_border,
            localizations.translate('shortlist'),
            color: _isShortlisted ? Colors.green : Colors.blue,
            onPressed: () async {
              try {
                if (_isShortlisted) {
                  // Call remove shortlist API
                  RemoveShortlist response =
                      await ApiService.fetchRemoveShortlistData(context,widget.matriId);
                  debugPrint("Removed from Shortlist: ${response.message}");

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Removed from Shortlist")),
                  );
                } else {
                  // Call add shortlist API
                  AddShortlist response =
                      await ApiService.fetchAddShortlistData(context,widget.matriId);
                  debugPrint("Shortlisted Successfully: ${response.message}");

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Shortlisted Successfully!")),
                  );
                }

                // Toggle the shortlist state
                setState(() {
                  _isShortlisted = !_isShortlisted;
                });
              } catch (error) {
                debugPrint("Error updating Shortlist: $error");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Failed to update shortlist. Try again!")),
                );
              }
            },
          ),

          _buildIconButton(Icons.chat_bubble_outline,
              (localizations.translate('chat')).toString(),
              onPressed: () async {
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                      matriId: widget.matriId,
                      profile: profile.url,
                      name: profile.firstName),
                ),
              );
            }
          }),

          _buildIconButton(Icons.phone, localizations.translate('contact_info'),
              onPressed: () async {
            String status =
                await _maxLimit.checkContactedProfiles(widget.matriId,context);
            if (status == "Y") {
              _showContactInfoDialog(context, profile);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionPaymentPage(),
                ),
              );
            }
          }),
          _buildIconButton(Icons.report, localizations.translate('block'),
              onPressed: () {
            _showBlockReportDialog(context);
          }),
        ],
      ),
    );
  }

  void _showBlockReportDialog(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          title: Text(localizations.translate('block_report')),
          content:
              BlockReportCard(matriIdTo: widget.matriId), // Pass matriId here
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(localizations.translate('cancel')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(IconData icon, String label,
      {VoidCallback? onPressed, Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(icon,
                size: 30, color: color ?? Colors.blue), // Use dynamic color
            onPressed: onPressed ?? () {},
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

// Method to show the contact info dialog
  void _showContactInfoDialog(BuildContext context, profileview profile) {
    var localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('contact_details')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContactInfoRow(
                  '${localizations.translate('email')}:', profile.email),
              _buildContactInfoRow(
                  '${localizations.translate('phone_number')}:', profile.phone),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.translate('cancel')),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactInfoRow(String label, String value) {
    var localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty
                  ? value
                  : localizations.translate('not_available'),
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicContent(profileview profile) {
    var localizations = AppLocalizations.of(context);
    var selectedBasic = localizations.translate('basic');
    var selectedAttributes = localizations.translate('attributes');
    var selectedEducation = localizations.translate('education_profession');
    var selectedHoroscope = localizations.translate('horoscope');
    var selectedFamily = localizations.translate('family');
    var selectedImages = localizations.translate('images');

    if (selectedSection == selectedBasic) {
      return _buildSection(localizations.translate('basic_details'), [
        _buildInfoRow(localizations.translate('dob'),
            DateFormat("dd-MM-yyyy").format(DateTime.parse(profile.dob))),
        _buildInfoRow(
            localizations.translate('profile_handler'), profile.profileCreator),
        _buildInfoRow(localizations.translate('creating_profile_for'),
            profile.profileFor),
        _buildInfoRow(
            localizations.translate('marital_status'), profile.status),
        _buildInfoRow(localizations.translate('sub_caste'), profile.subCaste),
      ]);
    } else if (selectedSection == selectedAttributes) {
      return _buildSection(localizations.translate('additional_details'), [
        _buildInfoRow(
            localizations.translate('height'), "${profile.height} cm"),
        _buildInfoRow(
            localizations.translate('weight'), "${profile.weight} kg"),
        _buildInfoRow(
            localizations.translate('blood_group'), profile.bloodGroup),
        _buildInfoRow(
            localizations.translate('complexion'), profile.complexion),
        _buildInfoRow(
            localizations.translate('disabilities'), profile.disability),
        _buildInfoRow(localizations.translate('country'), profile.country),
        _buildInfoRow(localizations.translate('state'), profile.state),
        _buildInfoRow(localizations.translate('city'), profile.city),
        _buildInfoRow(localizations.translate('address'), profile.address),
        _buildInfoRow(localizations.translate('remarks'), profile.remark),
      ]);
    } else if (selectedSection == selectedEducation) {
      return _buildSection(localizations.translate('education_profession'), [
        _buildInfoRow(
            localizations.translate('qualification'), profile.qualification),
        _buildInfoRow(
            localizations.translate('specialisation'), profile.specialization),
        _buildInfoRow(
            localizations.translate('profession'), profile.occupation),
        _buildInfoRow(localizations.translate('company_name'), profile.company),
        _buildInfoRow(
            localizations.translate('company_city'), profile.companyCity),
        _buildInfoRow(localizations.translate('salary_range'), profile.salary),
      ]);
    } else if (selectedSection == selectedHoroscope) {
      return _buildSection(localizations.translate('horoscope'), [
        _buildInfoRow(localizations.translate('rashi'), profile.rashi),
        _buildInfoRow(localizations.translate('nakshatra'), profile.nakshatra),
        _buildInfoRow(localizations.translate('gothra'), profile.gothra),
        _buildInfoRow(
            localizations.translate('birth_place'), profile.birthPlace),
        _buildInfoRow(localizations.translate('birth_time'), profile.birthTime),
        _buildInfoRow(
            localizations.translate('family_deity'), profile.familyDiety),
      ]);
    } else if (selectedSection == selectedFamily) {
      return _buildSection(localizations.translate('family_details'), [
        _buildInfoRow(
            localizations.translate('father_name'), profile.fatherName),
        _buildInfoRow(localizations.translate('father_occupation'),
            profile.fatherOccupation),
        _buildInfoRow(
            localizations.translate('mother_name'), profile.motherName),
        _buildInfoRow(localizations.translate('mother_occupation'),
            profile.motherOccupation),
        _buildInfoRow(localizations.translate('no_of_brothers'),
            profile.numberOfBrothers),
        _buildInfoRow(
            localizations.translate('no_of_sisters'), profile.numberOfSisters),
        _buildInfoRow(
            localizations.translate('permanent_address'), profile.address),
        _buildInfoRow(
            localizations.translate('mother_tongue'), profile.motherTongue),
        _buildInfoRow(
            localizations.translate('family_type'), profile.familyType),
        _buildInfoRow(
            localizations.translate('reference_name'), profile.reference),
        _buildInfoRow(localizations.translate('reference_phone'),
            profile.referenceNumber),
      ]);
    } else if (selectedSection == selectedImages) {
      // Added case for Photos
      return _buildPhotosSection();
    } else {
      return _buildSection('Unknown Section', []);
    }
  }

  Widget _buildSection(String title, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildMoreSection() {
    var localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildOptionButton(localizations.translate('basic')),
            _buildOptionButton(localizations.translate('attributes')),
            _buildOptionButton(localizations.translate('education_profession')),
            _buildOptionButton(localizations.translate('horoscope')),
            _buildOptionButton(localizations.translate('family')),
            _buildOptionButton(localizations.translate('images')),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    var localizations = AppLocalizations.of(context);
    return FutureBuilder<List<searchimages>>(
      future: ApiService.fetchimages(widget.matriId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<searchimages> images = snapshot.data ?? [];

        if (images.isEmpty) {
          return Center(child: Text(localizations.translate('no_images')));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 11,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullImage(
                    context, images, index), // Pass images & index
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    images[index].img_url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/1.png');
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFullImage(
      BuildContext context, List<searchimages> images, int initialIndex) {
    PageController _pageController = PageController(initialPage: initialIndex);
    int currentIndex = initialIndex;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => Navigator.pop(context), // Close on tap anywhere
              child: Stack(
                children: [
                  // Blurred Background
                  BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                  // Full Image Dialog with PageView
                  Center(
                    child: Dialog(
                      backgroundColor: Colors.transparent,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: images.length,
                              onPageChanged: (index) {
                                setState(() {
                                  currentIndex =
                                      index; // Update current image index
                                });
                              },
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      images[index].img_url,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset('assets/1.png');
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Left Arrow (Previous Image)
                            if (currentIndex > 0)
                              Positioned(
                                left: 10,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back_ios,
                                      color: Colors.white, size: 30),
                                  onPressed: () {
                                    if (currentIndex > 0) {
                                      _pageController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                ),
                              ),
                            // Right Arrow (Next Image)
                            if (currentIndex < images.length - 1)
                              Positioned(
                                right: 10,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_forward_ios,
                                      color: Colors.white, size: 30),
                                  onPressed: () {
                                    if (currentIndex < images.length - 1) {
                                      _pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionButton(String text) {
    bool isSelected = selectedSection == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSection = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.red, width: 1) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF35356D),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
