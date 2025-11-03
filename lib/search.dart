import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:buntsmatrimony/checkProfiles.dart';
import 'package:buntsmatrimony/inapp/subscription_list_screen.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:buntsmatrimony/profile_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buntsmatrimony/api_service.dart';
import 'package:buntsmatrimony/dashboard_model.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isMatriSearch = true;
  List<searchcategory1> searchResults = [];
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 100;
  bool _isPaginationFetched = false;
  final MaxLimit _maxLimit = MaxLimit();
  bool _isloading = false;
  Timer? _debounce;
  //  bool _isLoading = false;
  bool _isLoadingState = false;
  bool _isLoadingCity = false;
  String? _selectedCountryCode;
  Future<SearchData>? _matriSearchResults;
  Future<Category>? _categorySearchResults;

  List<searchsubcaste> _subCasteList = [];
  List<searcheducation> _educationList = [];
  List<searchcountry> _countryList = [];
  List<searchstate> _stateList = [];
  List<searchcity> _cityList = [];
  List<searchcategory1> filteredProfiles = [];
  final TextEditingController _searchController = TextEditingController();

  Map<String, int> maritalStatusMap = {
    "Unmarried": 1,
    "Widow/Widower": 2,
    "Divorcee": 3,
    "Separated": 4,
    "Married": 5,
  };

  searchcountry? _selectedCountry;
  searchstate? _selectedState;
  searchcity? _selectedCity;
  List<searchsubcaste> _selectedSubCasteList = [];
  List<searcheducation> _selectedEducationList = [];
  bool _isExpanded = false; // Track expansion state
  final TextEditingController _controller = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  String? _selectedMaritalStatus;
  double _selectedMinAge = 18;
  double _selectedMaxAge = 40;
  double _selectedMinHeight = 50;
  double _selectedMaxHeight = 250;
  Color appcolor = Color(0xFFea4a57);

  @override
  void initState() {
    super.initState();
  }

  void _filterProfiles() {
    String query = _controller.text.toLowerCase();
    setState(() {
      filteredProfiles = searchResults
          .where(
            (profile) =>
                profile.firstName.toLowerCase().contains(query) ||
                profile.matriId.toLowerCase().contains(
                      query,
                    ), // Add more filters if needed
          )
          .toList();
    });
  }

  Future<void> _searchByCategory(int page) async {
    var result = await ApiService.fetchCategory1(
      page.toString(),
      _pageSize.toString(),
    );
    _controller.addListener(_filterProfiles);

    setState(() {
      searchResults = result['data'];
      _currentPage = page;
      filteredProfiles = searchResults;

      // Fetch total pages only on first page fetch
      if (!_isPaginationFetched) {
        _totalPages = (result['totalRows'] / _pageSize).ceil();
        _isPaginationFetched = true;
      }
      print(
        "$_totalPages  ${result['totalRows']}  $_pageSize ${searchResults.length}",
      );
    });
  }

  Future<void> _showFilterModal() async {
    var localizations = AppLocalizations.of(context);
    setState(() {
      _selectedCountry = null;
      _selectedState = null;
      _selectedCity = null;
      _stateList = [];
      _cityList = [];
      _selectedEducationList = [];
      _selectedMaritalStatus = null;
      _selectedSubCasteList = [];
      _selectedMinAge = 18;
      _selectedMaxAge = 40;
      _selectedMinHeight = 50;
      _selectedMaxHeight = 250;
    });
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(15),
              height: MediaQuery.of(context).size.height * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('apply_filters'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),

                    DropdownButtonFormField<String>(
                      value: _selectedMaritalStatus?.isNotEmpty == true
                          ? _selectedMaritalStatus
                          : null,
                      isExpanded: true,
                      onChanged: (value) async {
                        setState(() => _selectedMaritalStatus = value);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        if (value != null &&
                            maritalStatusMap.containsKey(value)) {
                          await prefs.setInt(
                            "selected_marital_status",
                            maritalStatusMap[value]!,
                          );
                        } else {
                          await prefs.remove("selected_marital_status");
                        }

                        print(
                          "Selected marital status: ${maritalStatusMap[value] ?? 'None'}",
                        );
                      },
                      items: maritalStatusMap.keys.map((ms) {
                        return DropdownMenuItem(value: ms, child: Text(ms));
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: localizations.translate('marital_status'),
                      ),
                    ),

                    // Subcaste Dropdown
                    MultiSelectDialogField(
                      items: _subCasteList
                          .map((sc) => MultiSelectItem(sc, sc.sub_caste))
                          .toList(),
                      buttonText: Text(
                        localizations.translate('sub_caste'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2d2d2d),
                        ),
                        textAlign: TextAlign.left,
                      ),

                      chipDisplay: MultiSelectChipDisplay(),
                      onConfirm: (values) {
                        setState(
                          () => _selectedSubCasteList =
                              List<searchsubcaste>.from(values),
                        );
                        _saveFilters();
                      },
                      initialValue: _selectedSubCasteList,
                      buttonIcon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                        size: 24,
                      ), // Increase icon size
                      dialogWidth: MediaQuery.of(context).size.width * 0.85,
                      searchable: true,
                      searchHint: "Search Subcaste...",
                      title: Text(""),
                    ),

                    SizedBox(height: 10),

                    MultiSelectDialogField(
                      items: _educationList
                          .map((ed) => MultiSelectItem(ed, ed.name))
                          .toList(),
                      buttonText: Text(
                        localizations.translate('education'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2d2d2d),
                        ),
                      ),
                      chipDisplay: MultiSelectChipDisplay(),
                      onConfirm: (values) {
                        setState(
                          () => _selectedEducationList =
                              List<searcheducation>.from(values),
                        );
                        _saveFilters();
                      },
                      buttonIcon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                      ),
                      dialogWidth: MediaQuery.of(context).size.width * 0.85,
                      searchable: true,
                      searchHint: "Search Education...",
                      title: Text(""),
                    ),

                    SizedBox(height: 10),

                    // Country Dropdown
                    _buildCountryDropdown(setModalState),

                    SizedBox(height: 10),

                    _isLoadingState
                        ? Center(child: Text("Loading States..."))
                        : _buildStateDropdown(setModalState),

                    SizedBox(height: 10),

                    _isLoadingCity
                        ? Center(child: Text("Loading Cities..."))
                        : _buildCityDropdown(setModalState),

                    SizedBox(height: 10),

                    SizedBox(height: 10),

                    SizedBox(height: 10),

                    // Age Range
                    Text(
                      localizations
                          .translate('age_range')
                          .replaceAll(
                            '{min}',
                            _selectedMinAge.round().toString(),
                          )
                          .replaceAll(
                            '{max}',
                            _selectedMaxAge.round().toString(),
                          ),
                    ),
                    RangeSlider(
                      values: RangeValues(_selectedMinAge, _selectedMaxAge),
                      min: 18,
                      max: 100,
                      divisions: 82,
                      labels: RangeLabels(
                        "${_selectedMinAge.round()}",
                        "${_selectedMaxAge.round()}",
                      ),
                      onChanged: (values) async {
                        setModalState(() {
                          _selectedMinAge = values.start;
                          _selectedMaxAge = values.end;
                        });

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setDouble(
                          "selected_min_age",
                          _selectedMinAge,
                        );
                        await prefs.setDouble(
                          "selected_max_age",
                          _selectedMaxAge,
                        );
                      },
                      activeColor: Color(0xFFea4a57),
                      inactiveColor: Colors.white,
                    ),

                    // Height Range _selectedMinHeight
                    Text(
                      localizations
                          .translate('height_range')
                          .replaceAll(
                            '{min}',
                            _selectedMinHeight.round().toString(),
                          )
                          .replaceAll(
                            '{max}',
                            _selectedMaxHeight.round().toString(),
                          ),
                    ),
                    RangeSlider(
                      values: RangeValues(
                        _selectedMinHeight,
                        _selectedMaxHeight,
                      ),
                      min: 50,
                      max: 250,
                      divisions: 82,
                      labels: RangeLabels(
                        "${_selectedMinHeight.round()}",
                        "${_selectedMaxHeight.round()}",
                      ),
                      onChanged: (values) async {
                        setModalState(() {
                          _selectedMinHeight = values.start;
                          _selectedMaxHeight = values.end;
                        });

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setDouble(
                          "selected_min_height",
                          _selectedMinHeight,
                        );
                        await prefs.setDouble(
                          "selected_max_height",
                          _selectedMaxHeight,
                        );
                      },
                      activeColor: Color(
                        0xFFea4a57,
                      ), // Apply the specified color
                      inactiveColor: Colors.white,
                      //  thumbColor: Color(0xFFea4a57),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          searchResults = [];
                          _isPaginationFetched = false;
                          Navigator.pop(context);
                          _saveFilters();
                          _searchByCategory(1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMatriSearch == false
                              ? Color(0xFFea4a57)
                              : Colors.white,
                          foregroundColor: isMatriSearch == false
                              ? Colors.white
                              : Color(0xFFea4a57),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(localizations.translate('search')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      "selected_sub_caste",
      _selectedSubCasteList.map((sc) => sc.id).toList(),
    );

    await prefs.setStringList(
      "selected_education",
      _selectedEducationList.map((ed) => ed.id).toList(),
    );
  }

  Widget _buildCountryDropdown(Function setModalState) {
    var localizations = AppLocalizations.of(context);
    return DropdownSearch<searchcountry>(
      popupProps: PopupProps.menu(showSearchBox: true),
      items: _countryList,
      itemAsString: (searchcountry c) => "${c.country_name}",
      selectedItem: _selectedCountry,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: localizations.translate('country'),
        ),
      ),
      onChanged: (searchcountry? value) async {
        if (value == null) return;

        setModalState(() {
          _selectedCountry = value;
          _selectedCountryCode = value.country_code;
          _selectedState = null;
          _selectedCity = null;
          _stateList = [];
          _cityList = [];
          _isLoadingState = true;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("selected_country_id", value.country_id);
        await prefs.setString("selected_country_name", value.country_name);
        await prefs.setString("selected_country_code", value.country_code);

        print(
          "Selected Country: ${_selectedCountry?.country_name} - Code: $_selectedCountryCode",
        );

        List<searchstate> allStates = await ApiService.fetchstate();

        setModalState(() {
          _stateList =
              allStates.where((s) => s.country_id == value.country_id).toList();
          _isLoadingState = false;
        });
      },
    );
  }

  Widget _buildStateDropdown(Function setModalState) {
    var localizations = AppLocalizations.of(context);
    return DropdownSearch<searchstate>(
      popupProps: PopupProps.menu(showSearchBox: true),
      items: _stateList,
      itemAsString: (searchstate s) => s.state_name,
      selectedItem: _selectedState,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: localizations.translate('state'),
        ),
      ),
      onChanged: (searchstate? value) async {
        if (value == null) return;

        setModalState(() {
          _selectedState = value;
          _selectedCity = null;
          _cityList = [];
          _isLoadingCity = true;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("selected_state_id", value.state_id);
        await prefs.setString("selected_state_name", value.state_name);

        print("Selected State: ${_selectedState?.state_name}");

        List<searchcity> allCities = await ApiService.fetchcity();

        setModalState(() {
          _cityList =
              allCities.where((c) => c.state_id == value.state_id).toList();
          _isLoadingCity = false;
        });
      },
    );
  }

  Widget _buildCityDropdown(Function setModalState) {
    var localizations = AppLocalizations.of(context);
    return DropdownSearch<searchcity>(
      popupProps: PopupProps.menu(showSearchBox: true),
      items: _cityList,
      itemAsString: (searchcity c) => c.city_name,
      selectedItem: _selectedCity,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: localizations.translate('city'),
        ),
      ),
      onChanged: (searchcity? value) async {
        if (value == null) return;
        setModalState(() {
          _selectedCity = value;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("selected_city_id", value.city_id);
        await prefs.setString("selected_city_name", value.city_name);

        print("Selected City: ${_selectedCity?.city_name}");

        // _searchByCategory(1);
      },
    );
  }

  void _openFilterDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? savedMatriId = prefs.getString("matriId");
    print("Before Clearing - Matri ID: $savedMatriId");

    await prefs.remove("selected_sub_caste");
    await prefs.remove("selected_education");
    await prefs.remove("selected_marital_status");
    await prefs.remove("selected_country_id");
    await prefs.remove("selected_state_id");
    await prefs.remove("selected_city_id");
    await prefs.remove("selected_min_age");
    await prefs.remove("selected_max_age");
    await prefs.remove("selected_min_height");
    await prefs.remove("selected_max_height");
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  top: 20.0,
                  bottom: 4.0,
                ), // Adjust as needed
                child: Text(
                  localizations.translate('search'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  isMatriSearch = true;
                  searchResults = [];
                  _isPaginationFetched = false;
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isMatriSearch == true ? Color(0xFFea4a57) : Colors.white,
                  foregroundColor:
                      isMatriSearch == true ? Colors.white : Color(0xFFea4a57),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(localizations.translate('matri_id')),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isMatriSearch = false;
                  });
                  _loadFilterData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isMatriSearch == false ? Color(0xFFea4a57) : Colors.white,
                  foregroundColor:
                      isMatriSearch == false ? Colors.white : Color(0xFFea4a57),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(localizations.translate('category')),
              ),
            ],
          ),

          // Pagination Row (Always Visible)
          if (!isMatriSearch && _isPaginationFetched) ...[
            _searchbox(_controller),
            if (_totalPages > 1)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_totalPages, (index) {
                      //
                      int pageNumber = index + 1;
                      return GestureDetector(
                        onTap: () => _searchByCategory(pageNumber),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _currentPage == pageNumber
                                ? appcolor
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            pageNumber.toString(),
                            style: TextStyle(
                              color: _currentPage == pageNumber
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            Expanded(child: _buildResults()),
          ],

          if (isMatriSearch && !_isPaginationFetched) ...[
            search(),
            Expanded(child: _buildMatriSearchResults()),
          ],
        ],
      ),
    );
  }

  bool isValidImageUrl(String url) {
    return url.isNotEmpty && url != "null" && !url.endsWith("/null");
  }

  Future<void> _loadData() async {
    _subCasteList = await ApiService.fetchsearchsubcaste();
    _educationList = await ApiService.fetcheducation();
    _countryList = await ApiService.fetchcountry();

    setState(() {});
  }

  Future<void> _loadFilterData() async {
    _openFilterDialog();
    setState(() {
      _isloading = true;
    });
    await _loadData();
    setState(() {
      _isloading = false;
    });
    _showFilterModal();
  }

  Widget _buildMatriSearchResults() {
    var localizations = AppLocalizations.of(context);

    if (_matriSearchResults == null) {
      return SizedBox.shrink();
    }

    return FutureBuilder<SearchData>(
      future: _matriSearchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.dataout.isEmpty) {
          return SizedBox.shrink();
        }

        final List<searchprofile> profiles = snapshot.data!.dataout;
        return _buildProfileGrid(profiles);
      },
    );
  }

  Widget _buildProfileGrid(List<searchprofile> profiles) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        var profile = profiles[index];

        return GestureDetector(
          onTap: () async {
            await _maxLimit.checkProfileView(profile.matriId, context);
            // String status = await _maxLimit.checkProfileView(profile.matriId);
            // if (status == "Y") {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) =>
            //             ProfilePage(matriId: profile.matriId)),
            //   );
            // } else {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => SubscriptionScreen()),
            //   );
            // }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ), // gap between cards
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ), // smoother round corners
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          isValidImageUrl(profile.url)
                              ? profile.url
                              : (profile.gender == 2
                                  ? "assets/1.png"
                                  : "assets/2.png"),
                          height: 180, // slightly increased height
                          width: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              profile.gender == 2
                                  ? "assets/1.png"
                                  : "assets/2.png",
                              height: 180,
                              width: 160,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      if (profile.planStatus == "Paid")
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Image.asset(
                            "assets/verification_new.png",
                            width: 28,
                            height: 28,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(profile.firstName + " " + profile.lastName).length > 15 ? (profile.firstName + " " + profile.lastName).substring(0, 12) + "..." : profile.firstName + " " + profile.lastName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Age: ${profile.age}",
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    " ${profile.matriId} ",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget search() {
    var localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 40,
        width: 250, // Adjust the height as needed
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: localizations.translate('enter_id'),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          ),
          style: TextStyle(fontSize: 14),
          onChanged: (value) {
            _performSearch(value); // Pass the updated value for search
          },
        ),
      ),
    );
  }

  Widget _searchbox(TextEditingController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 400),
          width: _isExpanded ? 125 : 0,
          curve: Curves.easeInOut,
          child: TextField(
            controller: _controller,
            focusNode:
                _searchFocusNode, //_isExpanded, // Auto-focus when expanded
            decoration: InputDecoration(
              hintText: "Search...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
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
                filteredProfiles = searchResults; // Reset list when closed
                _searchFocusNode.unfocus(); // Hide keyboard
              } else {
                FocusScope.of(
                  context,
                ).requestFocus(_searchFocusNode); // Request focus
              }
            });
          },
        ),
      ],
    );
  }

  void _performSearch(String query) {
    query = query.trim();

    // ✅ Clear old results immediately when typing
    setState(() {
      _matriSearchResults = null;
    });

    if (query.isEmpty) return; // Stop if input is empty

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        var result = await ApiService.fetchsearchData(context, query);
        print("API Response: ${result.dataout}");

        // ✅ Explicitly clear UI when no results are found
        setState(() {
          _matriSearchResults =
              result.dataout.isNotEmpty ? Future.value(result) : null;
        });
      } catch (e) {
        print("Search Error: $e");

        // ✅ Ensure UI is cleared on API error
        setState(() {
          _matriSearchResults = null;
        });
      }
    });
  }

  Widget _buildResults() {
    var localizations = AppLocalizations.of(context);
    if (_isloading) {
      return Center(child: CircularProgressIndicator()); // Show loader
    }
    if (filteredProfiles.isEmpty)
      return Center(child: Text(localizations.translate('no_profiles')));
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredProfiles.length,
      itemBuilder: (context, index) {
        final profile = filteredProfiles[index];

        return GestureDetector(
          onTap: () async {
            await _maxLimit.checkProfileView(profile.matriId, context);
          },
          child: Card(
            elevation: 0, // remove shadow
            color: Colors.transparent, // no background border color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // left aligned
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.network(
                        isValidImageUrl(profile.url)
                            ? profile.url
                            : (profile.gender == 2
                                ? "assets/1.png"
                                : "assets/2.png"),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            profile.gender == 2
                                ? "assets/1.png"
                                : "assets/2.png",
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    if (profile.planStatus == "Paid")
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Image.asset(
                          "assets/verification_new.png",
                          width: 28,
                          height: 28,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  "${(profile.firstName + " " + profile.lastName).length > 15 ? (profile.firstName + " " + profile.lastName).substring(0, 12) + "..." : profile.firstName + " " + profile.lastName}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      "${profile.age} yrs, ",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "${profile.matriId}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
