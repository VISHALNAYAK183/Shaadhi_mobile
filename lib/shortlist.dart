import 'package:flutter/material.dart';
import 'package:practice/lang.dart';
import 'api_service.dart';
import 'dashboard_model.dart';
import 'package:practice/checkProfiles.dart';
import 'dart:async';

class ShortlistsPage extends StatefulWidget {
  const ShortlistsPage({Key? key}) : super(key: key);

  @override
  ShortlistsPageState createState() => ShortlistsPageState();
}

class ShortlistsPageState extends State<ShortlistsPage> {
  List<ShortlistedProfile> shortlistedProfiles = [];
  List<ShortlistedProfile> filteredProfiles = [];
  FocusNode _searchFocusNode = FocusNode();
  final MaxLimit _maxLimit = MaxLimit();
  bool _isExpanded = false; // Track expansion state
  final TextEditingController _controller = TextEditingController();
  final Color _signColor = Color(0xFF8A2727);
  Color appcolor = Color(0xFF8A2727);
  bool isLoading = true;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    
    _controller.addListener(_filterProfiles);
    fetchshortlistedProfiles();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchshortlistedProfiles() async {
    try {
      filteredProfiles = [];
      final ShortlistData = await ApiService.fetchShortlistedProfiles();

      String baseUrl = (await matchedprofile.getBaseUrl()) ?? "";
      _controller.addListener(_filterProfiles);

      setState(() {
        shortlistedProfiles = ShortlistData.profiles;
        filteredProfiles = shortlistedProfiles;
        isLoading = false;
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching shortlisted profiles: $e")),
        );
      });
      print("Error fetching shortlisted profiles: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterProfiles() {
    String query = _controller.text.toLowerCase();
    setState(() {
      filteredProfiles = shortlistedProfiles
          .where((profile) =>
                  profile.name.toLowerCase().contains(query) ||
                  profile.matriId
                      .toLowerCase()
                      .contains(query) // Add more filters if needed
              )
          .toList();
    });
  }

  bool isValidImageUrl(String url) {
    return url.isNotEmpty && url != "null" && !url.endsWith("/null");
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appcolor,
          title: Text(
            localizations.translate('shortlist'),
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 25), // Back button icon
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (isLoading) ...[
                  const SizedBox(height: 10),
                  const Center(child: CircularProgressIndicator()),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Align text left & search right
                    children: [
                      // ✅ Shortlisted Heading (Left Side)
                      Text(
                        '${localizations.translate('shortlisted')} (${filteredProfiles.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      // ✅ Search Bar (Right Side)
                      Row(
                        mainAxisSize: MainAxisSize
                            .min, // Keep search bar and icon together
                        children: [
                          AnimatedContainer(
                            duration:
                                Duration(milliseconds: 400), // Smooth animation
                            width:
                                _isExpanded ? 150 : 0, // Expands when searching
                            curve: Curves.easeInOut,
                            child: TextField(
                              controller: _controller,
                              focusNode: _searchFocusNode,
                              decoration: InputDecoration(
                                hintText: "Search...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isExpanded ? Icons.close : Icons.search,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded; // Toggle state
                                if (!_isExpanded) {
                                  _controller.clear();
                                  filteredProfiles =
                                      shortlistedProfiles; // Reset list when closed
                                  _searchFocusNode.unfocus(); // Hide keyboard
                                } else {
                                  FocusScope.of(context).requestFocus(
                                      _searchFocusNode); // Request focus
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth > 600
                              ? 3
                              : 2;
                      return filteredProfiles.isEmpty
                          ? Center(
                              child: Text(localizations.translate('no_matches')))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 13,
                                mainAxisSpacing: 13,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: filteredProfiles.length,
                              itemBuilder: (context, index) {
                                final profile = filteredProfiles[index];

                                return GestureDetector(
                                  onTap: () async {
                                    await _maxLimit.checkProfileView(
                                        profile.matriId, context);
                                  },
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    // child: Padding(
                                    //   padding: EdgeInsets.all(5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                isValidImageUrl(
                                                        profile.imageUrl)
                                                    ? profile.imageUrl
                                                    : (int.tryParse(profile
                                                                .gender
                                                                .toString()) ==
                                                            2
                                                        ? "assets/1.png"
                                                        : "assets/2.png"),
                                                height: 160,
                                                width: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.asset(
                                                    int.tryParse(profile.gender
                                                                .toString()) ==
                                                            2
                                                        ? "assets/1.png"
                                                        : "assets/2.png",
                                                    height: 160,
                                                    width: 150,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              ),
                                            ),
                                            if (profile.planStatus ==
                                                "Paid") // ✅ Show badge only if Paid
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: Image.asset(
                                                  "assets/verification_new.png",
                                                  width:
                                                      25, // Adjust size as needed
                                                  height: 25,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          "${(profile.name).length > 15 ? (profile.name).substring(0, 12) + "..." : profile.name}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 1),
                                        Text("Age: ${profile.age}",
                                            style: TextStyle(fontSize: 10)),
                                        Text(
                                          " ${profile.matriId} ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                      // ),
                                    ),
                                  ),
                                );
                              },
                            );
                    },
                  ),
                ],
              ],
            ),
          ),
        ) 
        );
  }
}
