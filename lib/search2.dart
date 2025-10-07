// import 'package:flutter/material.dart';
// import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
// import 'package:multi_select_flutter/multi_select_flutter.dart';
// import 'api_service.dart';
// import 'dashboard_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:practice/checkProfiles.dart';
// import 'package:practice/inapp/subscription_list_screen.dart';
// import 'dart:async';
// import 'package:intl/intl.dart';
// import 'profile_view.dart';
// import 'package:dropdown_search/dropdown_search.dart';

// class SearchPage extends StatefulWidget {
//   @override
//   _SearchPageState createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   List<searchcategory> searchProfiles = [];
//   List<searchcategory> filteredProfiles = [];
//   bool _showSearchBar = false;
//   FocusNode _searchFocusNode = FocusNode();
//   bool _isExpanded = false; // Track expansion state
//   Future<SearchData>? _matriSearchResults;
//   Future<Category>? _categorySearchResults;
//   final TextEditingController _controller = TextEditingController();
//   final TextEditingController _searchController = TextEditingController();
//   final MaxLimit _maxLimit = MaxLimit();
//   bool? _isMatriSearch; // Initially null

//   void _performSearch() async {
//     String query = _searchController.text.trim();
//     if (query.isEmpty) return;

//     setState(() {
//       _matriSearchResults = null; // Reset old results before fetching new ones
//     });

//     try {
//       var result = await ApiService.fetchsearchData(query);
//       if (result.dataout.isNotEmpty) {
//         setState(() {
//           _matriSearchResults =
//               Future.value(result); // Correctly store new results
//           _categorySearchResults = null; // Reset category search
//         });
//       } else {
//         setState(() {
//           // _matriSearchResults = Future.error("No profiles found");
//         });
//       }
//     } catch (e) {
//       print("Search Error: $e"); // Debugging information
//       setState(() {
//         _matriSearchResults = Future.error("Failed to fetch data");
//       });
//     }
//   }

//   void _openFilterDialog() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // ✅ Preserve Matri ID
//     String? savedMatriId = prefs.getString("matriId");
//     print("Before Clearing - Matri ID: $savedMatriId");

//     // ✅ Clear only specific filters
//     await prefs.remove("selected_sub_caste");
//     await prefs.remove("selected_education");
//     await prefs.remove("selected_marital_status");
//     await prefs.remove("selected_country_id");
//     await prefs.remove("selected_state_id");
//     await prefs.remove("selected_city_id");
//     await prefs.remove("selected_min_age");
//     await prefs.remove("selected_max_age");
//     await prefs.remove("selected_min_height");
//     await prefs.remove("selected_max_height");

//     // ✅ Restore Matri ID after clearing filters
//     if (savedMatriId != null) {
//       await prefs.setString("matriId", savedMatriId);
//       print("Restored Matri ID: ${prefs.getString('matriId')}");
//     }

//     showDialog(
//       context: context,
//       builder: (context) {
//         return FilterDialog(
//           onApplyFilters: (List<searchcategory> filteredProfiles) {
//             setState(() {
//               _categorySearchResults =
//                   Future.value(Category(dataout: filteredProfiles));
//               _matriSearchResults = null; // Reset Matri ID search
//               searchProfiles = filteredProfiles; // Store profiles for searching
//               this.filteredProfiles = filteredProfiles;
//               _showSearchBar =
//                   filteredProfiles.isNotEmpty; // Update filtered list
//               _isExpanded = true; // Expand search bar automatically
//             });
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Row(
//               children: [
//                 Text(
//                   "Search By:",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             _isMatriSearch = true;
//                             _showSearchBar =
//                                 false; // ✅ Hide search bar when switching to Matri ID
//                           });
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _isMatriSearch == true
//                               ? Color(0xFF8A2727)
//                               : Colors.white,
//                           foregroundColor: _isMatriSearch == true
//                               ? Colors.white
//                               : Color(0xFF8A2727),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6)),
//                         ),
//                         child: Text("Matri ID"),
//                       ),
//                       SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             _isMatriSearch = false;
//                             _openFilterDialog();
//                           });
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _isMatriSearch == false
//                               ? Color(0xFF8A2727) // Active button color
//                               : Colors.white, // Default unselected color
//                           foregroundColor: _isMatriSearch == false
//                               ? Colors.white // Text color for selected
//                               : Color(0xFF8A2727), // Text color for unselected
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                         child: Text("Category"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_showSearchBar)
//             Row(
//               children: [
//                 AnimatedContainer(
//                   duration: Duration(milliseconds: 400), // Smooth animation
//                   width: _isExpanded ? 150 : 0, // Expands to 150px when focused
//                   curve: Curves.easeInOut,
//                   child: TextField(
//                     controller: _controller,
//                     focusNode: _searchFocusNode, // Auto-focus listener
//                     onChanged: (query) {
//                       setState(() {
//                         filteredProfiles = searchProfiles
//                             .where((profile) =>
//                                 profile.firstName
//                                     .toLowerCase()
//                                     .contains(query.toLowerCase()) ||
//                                 profile.lastName
//                                     .toLowerCase()
//                                     .contains(query.toLowerCase()))
//                             .toList();
//                       });
//                     },
//                     decoration: InputDecoration(
//                       hintText: "Search...",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       contentPadding: EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 10,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 5), // Add spacing between text field and button
//                 IconButton(
//                   icon: Icon(_isExpanded ? Icons.close : Icons.search,
//                       color: Colors.red),
//                   onPressed: () {
//                     setState(() {
//                       _isExpanded = !_isExpanded; // Toggle state
//                       if (!_isExpanded) {
//                         _controller.clear();
//                         _searchFocusNode.unfocus(); // Hide keyboard
//                         filteredProfiles = searchProfiles; // Reset list
//                       } else {
//                         FocusScope.of(context)
//                             .requestFocus(_searchFocusNode); // Request focus
//                       }
//                     });
//                   },
//                 ),
//               ],
//             ),
//           SizedBox(height: 15),
//           if (_isMatriSearch == true)
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: SizedBox(
//                 height: 40,
//                 width: 250, // Adjust the height as needed
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     labelText: "Enter Matri ID",
//                     border: OutlineInputBorder(),
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                   ),
//                   style: TextStyle(fontSize: 14),
//                   onChanged: (value) => _performSearch(),

//                   // Trigger search on submit
//                 ),
//               ),
//             ),
//           Expanded(
//             child: _matriSearchResults != null
//                 ? _buildMatriSearchResults()
//                 : _categorySearchResults != null
//                     ? _buildCategorySearchResults()
//                     : Center(child: Text("")),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMatriSearchResults() {
//     return FutureBuilder<SearchData>(
//       future: _matriSearchResults,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return Center(child: Text("Error: ${snapshot.error}"));
//         }
//         if (!snapshot.hasData || snapshot.data!.dataout.isEmpty) {
//           return Center(child: Text("No profiles found"));
//         }

//         final List<searchprofile> profiles = snapshot.data!.dataout;
//         return _buildProfileGrid(profiles); // ✅ FIX: Use correct profile list
//       },
//     );
//   }

//   bool isValidImageUrl(String url) {
//     return url.isNotEmpty && url != "null" && !url.endsWith("/null");
//   }

//   Widget _buildCategorySearchResults() {
//     if (filteredProfiles.isEmpty) {
//       return Center(child: Text("No profiles found"));
//     }

//     // Convert searchcategory to searchprofile dynamically
//     List<searchprofile> convertedProfiles = filteredProfiles.map((category) {
//       return searchprofile(
//         id: category.id,
//         matriId: category.matriId,
//         firstName: category.firstName,
//         lastName: category.lastName,
//         phone: category.phone,
//         dob: category.dob,
//         age: category.age,
//         gender: category.gender,
//         genderType: category.genderType,
//         planStatus: category.planStatus,
//         height: category.height,
//         weight: category.weight,
//         url: category.url,
//       );
//     }).toList();

//     return _buildProfileGrid(convertedProfiles);
//   }

//   Widget _buildProfileGrid(List<searchprofile> profiles) {
//     return GridView.builder(
//       padding: EdgeInsets.all(10),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.7,
//       ),
//       itemCount: profiles.length, // ✅ FIX: Use actual search results
//       itemBuilder: (context, index) {
//         var profile = profiles[index]; // ✅ FIX: Use correct data list

//         return GestureDetector(
//           onTap: () async {
//             String status = await _maxLimit.checkProfileView(profile.matriId);
//             if (status == "Y") {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) =>
//                         ProfilePage(matriId: profile.matriId)),
//               );
//             } else {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => SubscriptionScreen()),
//               );
//             }
//           },
//           child: Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(5),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.network(
//                           isValidImageUrl(profile.url)
//                               ? profile.url
//                               : (profile.gender == 2
//                                   ? "assets/1.png"
//                                   : "assets/2.png"),
//                           height: 140,
//                           width: 120,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Image.asset(
//                               profile.gender == 2
//                                   ? "assets/1.png"
//                                   : "assets/2.png",
//                               height: 140,
//                               width: 120,
//                               fit: BoxFit.cover,
//                             );
//                           },
//                         ),
//                       ),
//                       if (profile.planStatus ==
//                           "Paid") // ✅ Show badge only if Paid
//                         Positioned(
//                           top: 5,
//                           right: 5,
//                           child: Image.asset(
//                             "assets/verification_new.png",
//                             width: 25, // Adjust size as needed
//                             height: 25,
//                           ),
//                         ),
//                     ],
//                   ),
//                   SizedBox(height: 3),
//                   Text(
//                     "${profile.firstName} ${profile.lastName}",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 1),
//                   Text("Age: ${profile.age}", style: TextStyle(fontSize: 10)),
//                   Text(
//                     " ${profile.matriId} ",
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold, // ✅ Makes text bold
//                       color: Colors.red, // ✅ Sets text color to red
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class FilterDialog extends StatefulWidget {
//   final Function(List<searchcategory>) onApplyFilters;

//   FilterDialog({required this.onApplyFilters});

//   @override
//   _FilterDialogState createState() => _FilterDialogState();
// }

// class _FilterDialogState extends State<FilterDialog> {
//   Future<List<searchcategory>>? _futureProfiles;

//   List<searchsubcaste> _subCasteList = [];
//   List<searcheducation> _educationList = [];
//   List<searchcountry> _countryList = [];
//   List<searchstate> _stateList = [];
//   List<searchcity> _cityList = [];
//   Map<String, int> maritalStatusMap = {
//     "Unmarried": 1,
//     "Widow/Widower": 2,
//     "Divorcee": 3,
//     "Separated": 4,
//     "Married": 5,
//   };

//   searchcountry? _selectedCountry;
//   searchstate? _selectedState;
//   searchcity? _selectedCity;
//   List<searchsubcaste> _selectedSubCasteList = [];
//   List<searcheducation> _selectedEducationList = [];
//   String? _selectedMaritalStatus;
//   //int? selectedMaritalStatusValue = maritalStatusMap[_selectedMaritalStatus];

//   double _selectedMinAge = 18;
//   double _selectedMaxAge = 40;
//   double _selectedMinheight = 50;
//   double _selectedMaxheight = 250;

//   @override
//   void initState() {
//     super.initState();
//     _loadFilterData();
//     _loadData();
//     _loadSavedFilters();
//   }

//   Future<void> _loadFilterData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     await _loadData();

//     String? countryId = prefs.getString("selected_country_id");
//     String? stateId = prefs.getString("selected_state_id");
//     String? cityId = prefs.getString("selected_city_id");

//     _selectedCountry = null;
//     _selectedState = null;
//     _selectedCity = null;

//     setState(() {});
//   }

//   Future<void> _loadData() async {
//     _subCasteList = await ApiService.fetchsearchsubcaste();
//     _educationList = await ApiService.fetcheducation();
//     _countryList = await ApiService.fetchcountry();
//     _stateList = await ApiService.fetchstate();
//     _cityList = await ApiService.fetchcity();
//     setState(() {});
//   }

//   Future<void> _onSearch() async {
//     try {
//       List<searchcategory> categories = await ApiService.fetchcategory();
//       widget.onApplyFilters(categories);
//       Navigator.pop(context);
//     } catch (e) {
//       print("Error fetching profiles: $e");
//     }
//   }

//   Future<void> _loadSavedFilters() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Load saved subcastes
//     List<String> savedSubCasteIds =
//         prefs.getStringList("selected_sub_caste") ?? [];
//     _selectedSubCasteList =
//         _subCasteList.where((sc) => savedSubCasteIds.contains(sc.id)).toList();

//     // Load saved education
//     List<String> savedEducationIds =
//         prefs.getStringList("selected_education") ?? [];
//     _selectedEducationList = _educationList
//         .where((ed) => savedEducationIds.contains(ed.id))
//         .toList();

//     // Load country, state, and city
//     String? countryId = prefs.getString("selected_country_id");
//     _selectedCountry = _countryList.firstWhere((c) => c.country_id == countryId,
//         orElse: () =>
//             searchcountry(country_id: "", country_name: "", country_code: ""));

//     String? stateId = prefs.getString("selected_state_id");
//     _selectedState = _stateList.firstWhere((s) => s.state_id == stateId,
//         orElse: () => searchstate(
//             state_id: "", state_name: "", state_code: "", country_id: ""));

//     String? cityId = prefs.getString("selected_city_id");
//     _selectedCity = _cityList.firstWhere((c) => c.city_id == cityId,
//         orElse: () => searchcity(
//             city_id: "", city_name: "", state_id: "", country_id: ""));

//     setState(() {});
//   }

//   Future<void> _saveFilters() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Save selected subcastes
//     await prefs.setStringList("selected_sub_caste",
//         _selectedSubCasteList.map((sc) => sc.id).toList());

//     // Save selected education
//     await prefs.setStringList("selected_education",
//         _selectedEducationList.map((ed) => ed.id).toList());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.85,
//         padding: EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Text("Filter Profiles",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               SizedBox(height: 10),

//               // Subcaste Dropdown
//               MultiSelectDialogField(
                
//                 items: _subCasteList
//                     .map((sc) => MultiSelectItem(sc, sc.sub_caste))
//                     .toList(),
//                 buttonText: Text("Select Subcaste"),
//                 chipDisplay: MultiSelectChipDisplay(),
//                 onConfirm: (values) {
//                   setState(() => _selectedSubCasteList =
//                       List<searchsubcaste>.from(values));
//                   _saveFilters();
//                 },
//                 initialValue: _selectedSubCasteList,
//                 buttonIcon: Icon(Icons.arrow_drop_down, color: Colors.black),
//                 dialogWidth: MediaQuery.of(context).size.width *
//                     0.85, 
//                 searchable:
//                     true, 
//                 searchHint:
//                     "Search Subcaste...",
//                 title: Text(
//                     ""),
//               ),

//               SizedBox(height: 10),
//               MultiSelectDialogField(
//                 items: _educationList
//                     .map((ed) => MultiSelectItem(ed, ed.name))
//                     .toList(),
//                 buttonText: Text("Select Education"),
//                 chipDisplay: MultiSelectChipDisplay(),
//                 onConfirm: (values) {
//                   setState(() => _selectedEducationList =
//                       List<searcheducation>.from(values));
//                   _saveFilters();
//                 },
//                 buttonIcon: Icon(Icons.arrow_drop_down, color: Colors.black),
//                 dialogWidth: MediaQuery.of(context).size.width * 0.85, 
//                 searchable: true, 
//                 searchHint:
//                     "Search Education...", 
//                 title: Text(""), 
//               ),

//               SizedBox(height: 10),

//               // Marital Status Dropdown
//               DropdownButtonFormField<String>(
//                 value: _selectedMaritalStatus?.isNotEmpty == true
//                     ? _selectedMaritalStatus
//                     : null,
//                 isExpanded: true,
//                 onChanged: (value) async {
//                   setState(() => _selectedMaritalStatus = value);
//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   await prefs.setInt(
//                       "selected_marital_status", maritalStatusMap[value] ?? 1);
//                 },
//                 items: maritalStatusMap.keys.map((ms) {
//                   return DropdownMenuItem(value: ms, child: Text(ms));
//                 }).toList(),
//                 decoration: InputDecoration(labelText: "Marital Status"),
//               ),

//               SizedBox(height: 10),
//               // Country Dropdown
//               DropdownSearch<searchcountry>(
//                 popupProps: PopupProps.menu(
//                   showSearchBox: true,
//                   searchFieldProps: TextFieldProps(
//                     decoration: InputDecoration(
//                       hintText: "Search here...",
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                       isDense: true,
//                     ),
//                   ),
//                 ),
//                 items: _countryList,
//                 itemAsString: (searchcountry c) => c.country_name,
//                 selectedItem: _countryList.firstWhere(
//                   (c) => c.country_id == _selectedCountry?.country_id,
//                   orElse: () => searchcountry(
//                       country_id: "",
//                       country_name: " Country",
//                       country_code: ""),
//                 ),
//                 dropdownDecoratorProps: DropDownDecoratorProps(
//                   dropdownSearchDecoration: InputDecoration(labelText: ""),
//                 ),
//                 onChanged: (searchcountry? value) async {
//                   if (value == null) return;
//                   setState(() {
//                     _selectedCountry = value;
//                     _selectedState = null;
//                     _selectedCity = null;
//                     _stateList = [];
//                   });
//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   await prefs.setString(
//                       "selected_country_id", value.country_id);
//                   await prefs.setString(
//                       "selected_country_name", value.country_name);
//                   print("Country IDDD${_selectedCountry}");

//                   // Fetch states based on the selected country
//                   List<searchstate> allStates = await ApiService.fetchstate();
//                   setState(() {
//                     _stateList = allStates
//                         .where((state) => state.country_id == value.country_id)
//                         .toList();
//                   });
//                 },
//               ),

//               SizedBox(height: 10),

//               DropdownSearch<searchstate>(
//                 popupProps: PopupProps.menu(
//                   showSearchBox: true,
//                   searchFieldProps: TextFieldProps(
//                     decoration: InputDecoration(
//                       hintText: "Search here...",
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                       isDense: true,
//                     ),
//                   ),
//                 ),
//                 items: _stateList,
//                 itemAsString: (searchstate s) => s.state_name,
//                 selectedItem: _stateList.firstWhere(
//                   (s) => s.state_id == _selectedState?.state_id,
//                   orElse: () => searchstate(
//                       state_id: "",
//                       state_name: " State",
//                       state_code: "",
//                       country_id: ""),
//                 ),
//                 dropdownDecoratorProps: DropDownDecoratorProps(
//                   dropdownSearchDecoration: InputDecoration(labelText: ""),
//                 ),
//                 onChanged: (searchstate? value) async {
//                   if (value == null) return;
//                   setState(() {
//                     _selectedState = value;
//                     _selectedCity = null;
//                     _cityList = [];
//                   });
//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   await prefs.setString("selected_state_id", value.state_id);
//                   await prefs.setString(
//                       "selected_state_name", value.state_name);
//                   print("stattt${_selectedState}");

//                   // Fetch cities based on the selected state
//                   List<searchcity> allCities = await ApiService.fetchcity();
//                   setState(() {
//                     _cityList = allCities
//                         .where((city) => city.state_id == value.state_id)
//                         .toList();
//                   });
//                 },
//               ),

//               DropdownSearch<searchcity>(
//                 popupProps: PopupProps.menu(
//                   showSearchBox: true,
//                   searchFieldProps: TextFieldProps(
//                     decoration: InputDecoration(
//                       hintText: "Search here...",
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                       isDense: true,
//                     ),
//                   ),
//                 ),
//                 items: _cityList,
//                 itemAsString: (searchcity c) => c.city_name,
//                 selectedItem: _cityList.firstWhere(
//                   (c) => c.city_id == _selectedCity?.city_id,
//                   orElse: () => searchcity(
//                       city_id: "",
//                       city_name: " City",
//                       state_id: "",
//                       country_id: ""),
//                 ),
//                 dropdownDecoratorProps: DropDownDecoratorProps(
//                   dropdownSearchDecoration: InputDecoration(labelText: ""),
//                 ),
//                 onChanged: (searchcity? value) async {
//                   if (value == null) return;
//                   setState(() {
//                     _selectedCity = value;
//                   });
//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   await prefs.setString("selected_city_id", value.city_id);
//                   await prefs.setString("selected_city_name", value.city_name);
//                   print("selected cityyyyy${_selectedCity}");
//                 },
//               ),

              

//               SizedBox(height: 10),

//               // Age Range Selector
//               Text(
//                 "Age Range: ${_selectedMinAge.round()} - ${_selectedMaxAge.round()} years",
//               ),
//               RangeSlider(
//                 values: RangeValues(_selectedMinAge, _selectedMaxAge),
//                 min: 18,
//                 max: 100,
//                 divisions: 82,
//                 labels: RangeLabels(
//                   "${_selectedMinAge.round()}",
//                   "${_selectedMaxAge.round()}",
//                 ),
//                 onChanged: (values) async {
//                   setState(() {
//                     _selectedMinAge = values.start;
//                     _selectedMaxAge = values.end;
//                   });

//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   await prefs.setDouble("selected_min_age", _selectedMinAge);
//                   await prefs.setDouble("selected_max_age", _selectedMaxAge);
//                 },
//                 activeColor: Color(0xFF8A2727), // Your main color
//                 inactiveColor:
//                     Colors.white, // Change the inactive side to white
//               ),

//               SizedBox(height: 10),

//               Text(
//                 "Height Range: ${_selectedMinheight.round()} - ${_selectedMaxheight.round()} cm",
//               ),
//               RangeSlider(
//                 values: RangeValues(_selectedMinheight, _selectedMaxheight),
//                 min: 50,
//                 max: 250,
//                 divisions: 82,
//                 labels: RangeLabels("${_selectedMinheight.round()}",
//                     "${_selectedMaxheight.round()}"),
//                 onChanged: (values) async {
//                   setState(() {
//                     _selectedMinheight = values.start;
//                     _selectedMaxheight = values.end;
//                   });

//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   await prefs.setDouble(
//                       "selected_min_height", _selectedMinheight);
//                   await prefs.setDouble(
//                       "selected_max_height", _selectedMaxheight);
//                 },
//                 activeColor: Color(0xFF8A2727), // Apply the specified color
//                 inactiveColor: Colors.white,
//                 //  thumbColor: Color(0xFF8A2727),
//               ),

//               Center(
//                 child: ElevatedButton(
//                   onPressed: _onSearch,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         Color(0xFF8A2727), // Apply the specified color
//                     shape: RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.circular(5), // Reduce border radius
//                     ),
//                   ),
//                   child: Text(
//                     "Search",
//                     style: TextStyle(
//                         color: Colors.white), // Ensure text is readable
//                   ),
//                 ),
//               ),

//               SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }