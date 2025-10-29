import 'package:flutter/material.dart';
import 'package:practice/lang.dart';
import 'package:practice/language_provider.dart';
import 'package:practice/profile_view.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';
import 'dashboard_model.dart';
import 'package:practice/checkProfiles.dart';
import 'package:practice/inapp/subscription_list_screen.dart';

class MatchedPage extends StatefulWidget {
  // final String matriId;

  const MatchedPage({Key? key}) : super(key: key);

  @override
  MatchedPageState createState() => MatchedPageState();
}

class MatchedPageState extends State<MatchedPage> {
  List<matchedprofile> MatchedProfiles = [];
  List<matchedprofile> filteredProfiles = [];
  bool isLoading = true;
  FocusNode _searchFocusNode = FocusNode();
  String selectedtypeName = "";
  bool _isExpanded = false; // Track expansion state
  final TextEditingController _controller = TextEditingController();
  final MaxLimit _maxLimit = MaxLimit();
  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  var localizations = AppLocalizations.of(context);
  setState(() {
    selectedtypeName = localizations.translate('liked_by_me');
  });

    fetchMatchedProfiles("iliked"); 
  }

  bool isValidImageUrl(String url) {
    return url.isNotEmpty && url != "null" && !url.endsWith("/null");
  }

  Future<void> fetchMatchedProfiles(String dataType) async {
    try {
      setState(() {
        isLoading = true;
      });

      String? baseUrl;
      int retryCount = 0;
      while (baseUrl == null || baseUrl.isEmpty) {
        baseUrl = await matchedprofile.getBaseUrl();
        retryCount++;

        if (retryCount > 5) {
          print("Failed to retrieve baseUrl after multiple attempts.");
          setState(() {
            isLoading = false;
          });
          return;
        }

        await Future.delayed(
            Duration(milliseconds: 500)); // Wait before retrying
      }

      final matchedData = await ApiService.fetchMatchedProfiles(context,dataType);
      _controller.addListener(_filterProfiles);

      setState(() {
        MatchedProfiles = matchedData.dataout
            .map<matchedprofile>(
              (profile) => matchedprofile.fromJson(profile.toJson(), baseUrl!),
            )
            .toList();
        filteredProfiles = MatchedProfiles;
        isLoading = false;
      });

      for (var profile in MatchedProfiles) {
        print("Final Image URL: ${profile.url}");
      }
    } catch (e) {
      print("Error fetching matched profiles: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterProfiles() {
    String query = _controller.text.toLowerCase();
    setState(() {
      filteredProfiles = MatchedProfiles.where((profile) =>
              profile.firstName.toLowerCase().contains(query) ||
              profile.matriId
                  .toLowerCase()
                  .contains(query) // Add more filters if needed
          ).toList();
    });
  }

  Future<void> fetchViewedProfiles(String dataType) async {
    try {
      final matchedData = await ApiService.fetchViewedProfiles(context,dataType);
      String baseUrl = (await matchedprofile.getBaseUrl()) ?? "";

      _controller.addListener(_filterProfiles);

      setState(() {
        MatchedProfiles = matchedData.dataout
            .map<matchedprofile>(
              (profile) => matchedprofile.fromJson(profile.toJson(), baseUrl),
            )
            .toList();
        filteredProfiles = MatchedProfiles;
        isLoading = false;
      });

      // Debugging: Print image URLs
      for (var profile in MatchedProfiles) {
        print("Final Image URL: ${profile.url}");
      }
    } catch (e) {
      print("Error fetching matched profiles: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchContactedProfiles(String dataType) async {
    try {
      final matchedData = await ApiService.fetchContactedProfiles(context,dataType);
      String baseUrl = (await matchedprofile.getBaseUrl()) ?? "";

      _controller.addListener(_filterProfiles);

      setState(() {
        MatchedProfiles = matchedData.dataout
            .map<matchedprofile>(
              (profile) => matchedprofile.fromJson(profile.toJson(), baseUrl),
            )
            .toList();
        filteredProfiles = MatchedProfiles;
        isLoading = false;
      });

      // Debugging: Print image URLs
      for (var profile in MatchedProfiles) {
        print("Final Image URL: ${profile.url}");
      }
    } catch (e) {
      print("Error fetching matched profiles: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildLabels() {
    var localizations = AppLocalizations.of(context);
    var textLabels = [
      localizations.translate('liked_by_me'),
      localizations.translate('viewed_by_me'),
      localizations.translate('contacted'),
      localizations.translate('liked_by_others'),
      localizations.translate('viewed_by_others'),
      localizations.translate('mutually_liked')
    ];

    final List<VoidCallback> passValues = [
      () => fetchMatchedProfiles("iliked"),
      () => fetchViewedProfiles("iviewed"),
      () => fetchContactedProfiles("icontacted"),
      () => fetchMatchedProfiles("likedby"),
      () => fetchViewedProfiles("viewedby"),
      () => fetchMatchedProfiles("mutual"),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 buttons per row
        crossAxisSpacing: 4, // Adjusted spacing for better readability
        mainAxisSpacing: 4,
        childAspectRatio: 2.5, // Increased to make buttons wider
      ),
      itemCount: textLabels.length,
      itemBuilder: (context, index) {
        return ElevatedButton(
          onPressed: () {
            setState(() {
              isLoading = true;
              _isExpanded = false;
              selectedtypeName = textLabels[index];
            });
            passValues[index]();
            print('${textLabels[index]} clicked');
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(8), // Padding inside buttons
            alignment: Alignment.center, // Centers text inside button
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown, // Ensures text scales down to fit
            child: Text(
              textLabels[index],
              style:
                  const TextStyle(fontSize: 14), // Fixed size for consistency
              textAlign: TextAlign.center, // Ensure text is centered
            ),
          ),
        );
      },
    );
  }

  Widget buildLabel(String text) {
    return Container(
      width: 125, // Specify width
      height: 25, // Specify height
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

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);

    return GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // ✅ Remove focus when tapping outside
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabels(),
                  const SizedBox(height: 4),
                  if (isLoading) ...[
                    const SizedBox(height: 10),
                    const Center(child: CircularProgressIndicator()),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$selectedtypeName (${MatchedProfiles.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize
                              .min, // Keep search bar and icon together
                          children: [
                            AnimatedContainer(
                              duration: Duration(
                                  milliseconds: 400), // Smooth animation
                              width: _isExpanded ? 125 : 0, // Expands to 200px
                              curve: Curves.easeInOut,
                              child: TextField(
                                controller: _controller,
                                focusNode:
                                    _searchFocusNode, //_isExpanded, // Auto-focus when expanded
                                decoration: InputDecoration(
                                  hintText: localizations.translate('search'),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                  _isExpanded ? Icons.close : Icons.search,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded; // Toggle state
                                  if (!_isExpanded) {
                                    _controller.clear();
                                    filteredProfiles =
                                        MatchedProfiles; // Reset list when closed
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth >= 900
                            ? 4
                            : constraints.maxWidth > 600
                                ? 3
                                : 2;
                        return filteredProfiles.isEmpty
                            ? Center(
                                child:
                                    Text(localizations.translate('no_matches')))
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
                                                  isValidImageUrl(profile.url)
                                                      ? profile.url
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
                                                      int.tryParse(profile
                                                                  .gender
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
                                              if (profile.planStatus == "Paid")
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
                                            "${(profile.firstName + " " + profile.lastName).length > 15 ? (profile.firstName + " " + profile.lastName).substring(0, 12) + "..." : profile.firstName + " " + profile.lastName}",
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
                  ]
                ],
              ),
            ),
          ),
        ));
  }
}
