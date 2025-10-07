import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:practice/lang.dart';
import 'package:practice/main_screen.dart';
import 'api_service.dart';
import 'dashboard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterDialog extends StatefulWidget {
  final String matriId;
  final String id;
  const FilterDialog({super.key, required this.matriId, required this.id});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  Future<List<searchpartner>>? _futureProfiles;

  List<searchsubcaste> _subCasteList = [];
  List<searcheducation> _educationList = [];
  List<searchcountry> _countryList = [];
  List<searchstate> _stateList = [];
  List<searchcity> _cityList = [];
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
  String? _selectedMaritalStatus;
  //int? selectedMaritalStatusValue = maritalStatusMap[_selectedMaritalStatus];

  double _selectedMinAge = 18;
  double _selectedMaxAge = 40;
  double _selectedMinheight = 50;
  double _selectedMaxheight = 250;

  @override
  void initState() {
    super.initState();
    _loadFilterData();
    _loadData();
    // _storeMatriId();
  }

  Future<void> _loadFilterData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    await _loadData();

    String? countryId = prefs.getString("selected_country_id");
    String? stateId = prefs.getString("selected_state_id");
    String? cityId = prefs.getString("selected_city_id");

    _selectedCountry = null;
    _selectedState = null;
    _selectedCity = null;

    setState(() {});
  }

  Future<void> _loadData() async {
    _subCasteList = await ApiService.fetchsearchsubcaste();
    _educationList = await ApiService.fetcheducation();
    _countryList = await ApiService.fetchcountry();
    _stateList = await ApiService.fetchstate();
    _cityList = await ApiService.fetchcity();
    setState(() {});
  }
  
  Future<void> _onSearch() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get all selected filter values
    String countryId = prefs.getString("selected_country_id") ?? "";
    String stateId = prefs.getString("selected_state_id") ?? "";
    String cityId = prefs.getString("selected_city_id") ?? "";
    
    // 🔥 Fix the list retrieval
    List<String> subCasteList = prefs.getStringList("selected_sub_caste") ?? [];
    List<String> educationList = prefs.getStringList("selected_education") ?? [];

    int maritalStatus = prefs.getInt("selected_marital_status") ?? 1;
    double minAge = prefs.getDouble("selected_min_age") ?? 18;
    double maxAge = prefs.getDouble("selected_max_age") ?? 40;
    double minHeight = prefs.getDouble("selected_min_height") ?? 50;
    double maxHeight = prefs.getDouble("selected_max_height") ?? 250;
    
    await prefs.setString("matriId", widget.matriId);

    // Call API with selected filters
    List<searchpartner> filteredProfiles = await ApiService.fetchpartner();

    Navigator.pop(context);
  } catch (e) {
    print("Error fetching filtered profiles: $e");
  }
}

  Future<void> _saveFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save selected subcastes
    await prefs.setStringList("selected_sub_caste",
        _selectedSubCasteList.map((sc) => sc.id).toList());

    // Save selected education
    await prefs.setStringList("selected_education",
        _selectedEducationList.map((ed) => ed.id).toList());
  }
  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              localizations.translate('partner_preference'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // Subcaste Dropdown
             MultiSelectDialogField(
                
                items: _subCasteList
                    .map((sc) => MultiSelectItem(sc, sc.sub_caste))
                    .toList(),
                buttonText: Text(localizations.translate('sub_caste')),
                chipDisplay: MultiSelectChipDisplay(),
                onConfirm: (values) {
                  setState(() => _selectedSubCasteList =
                      List<searchsubcaste>.from(values));
                  _saveFilters();
                },
                initialValue: _selectedSubCasteList,
                buttonIcon: Icon(Icons.arrow_drop_down, color: Colors.black),
                dialogWidth: MediaQuery.of(context).size.width *
                    0.85, 
                searchable:
                    true, 
                searchHint:
                    "Search Subcaste...",
                title: Text(
                    ""),
              ),

              SizedBox(height: 10),
              MultiSelectDialogField(
                items: _educationList
                    .map((ed) => MultiSelectItem(ed, ed.name))
                    .toList(),
                buttonText: Text(localizations.translate('education')),
                chipDisplay: MultiSelectChipDisplay(),
                onConfirm: (values) {
                  setState(() => _selectedEducationList =
                      List<searcheducation>.from(values));
                  _saveFilters();
                },
                buttonIcon: Icon(Icons.arrow_drop_down, color: Colors.black),
                dialogWidth: MediaQuery.of(context).size.width * 0.85, 
                searchable: true, 
                searchHint:
                    "Search Education...", 
                title: Text(""), 
              ),

            SizedBox(height: 10),

            // Marital Status Dropdown
            DropdownButtonFormField<String>(
              value: _selectedMaritalStatus,
              isExpanded: true,
              onChanged: (value) async {
                setState(() => _selectedMaritalStatus = value);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setInt(
                    "selected_marital_status", maritalStatusMap[value] ?? 1);
              },
              items: maritalStatusMap.keys.map((ms) {
                return DropdownMenuItem(value: ms, child: Text(ms));
              }).toList(),
              decoration: InputDecoration(labelText: localizations.translate('marital_status')),
            ),
            SizedBox(height: 10),

            // Country Dropdown
            DropdownSearch<searchcountry>(
                popupProps: PopupProps.menu(showSearchBox: true),
                items: _countryList,
                itemAsString: (c) => c.country_name,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(labelText:localizations.translate('country')),
                ),
                onChanged: (searchcountry? value) async {
                  if (value == null) return;
                  setState(() {
                    _selectedCountry = value;
                    _selectedState = null;
                    _selectedCity = null;
                    _stateList =
                        []; // Clear the state list before fetching new states
                  });

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString(
                      "selected_country_id", value.country_id);
                  await prefs.setString(
                      "selected_country_name", value.country_name);

                  print("Country ID: ${value.country_id}");

                  // **Fetch states dynamically based on selected country**
                  List<searchstate> fetchedStates =
                      await ApiService.fetchstate();
                  setState(() {
                    _stateList = fetchedStates
                        .where((state) => state.country_id == value.country_id)
                        .toList();
                  });

                  print("States fetched: ${_stateList.length}");
                }),
            DropdownSearch<searchstate>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Search here...",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    isDense: true,
                  ),
                ),
              ),
              items: _stateList,
              itemAsString: (searchstate s) => s.state_name,
              selectedItem: _stateList.firstWhere(
                (s) => s.state_id == _selectedState?.state_id,
                orElse: () => searchstate(
                    state_id: "",
                    state_name: localizations.translate('state'),
                    state_code: "",
                    country_id: ""),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(labelText: ""),
              ),
              onChanged: (searchstate? value) async {
                if (value == null) return;
                setState(() {
                  _selectedState = value;
                  _selectedCity = null;
                  _cityList = [];
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("selected_state_id", value.state_id);
                await prefs.setString("selected_state_name", value.state_name);
                print("stattt${_selectedState}");

                // Fetch cities based on the selected state
                List<searchcity> allCities = await ApiService.fetchcity();
                setState(() {
                  _cityList = allCities
                      .where((city) => city.state_id == value.state_id)
                      .toList();
                });
              },
            ),

            DropdownSearch<searchcity>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Search here...",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    isDense: true,
                  ),
                ),
              ),
              items: _cityList,
              itemAsString: (searchcity c) => c.city_name,
              selectedItem: _cityList.firstWhere(
                (c) => c.city_id == _selectedCity?.city_id,
                orElse: () => searchcity(
                    city_id: "",
                    city_name: localizations.translate('city'),
                    state_id: "",
                    country_id: ""),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(labelText: ""),
              ),
              onChanged: (searchcity? value) async {
                if (value == null) return;
                setState(() {
                  _selectedCity = value;
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("selected_city_id", value.city_id);
                await prefs.setString("selected_city_name", value.city_name);
                print("selected cityyyyy${_selectedCity}");
              },
            ),
            SizedBox(height: 10),

            // Age Range Selector
            Text(
  localizations.translate('age_range')
      .replaceAll('{min}', _selectedMinAge.round().toString())
      .replaceAll('{max}', _selectedMaxAge.round().toString()),
),
            RangeSlider(
              values: RangeValues(_selectedMinAge, _selectedMaxAge),
              min: 18,
              max: 100,
              divisions: 82,
              onChanged: (values) async {
                setState(() {
                  _selectedMinAge = values.start;
                  _selectedMaxAge = values.end;
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setDouble("selected_min_age", _selectedMinAge);
                await prefs.setDouble("selected_max_age", _selectedMaxAge);
              },
            ),
            SizedBox(height: 10),

            // Height Range Selector
            Text(
  localizations.translate('height_range')
      .replaceAll('{min}', _selectedMinheight.round().toString())
      .replaceAll('{max}', _selectedMaxheight.round().toString()),
),
            RangeSlider(
              values: RangeValues(_selectedMinheight, _selectedMaxheight),
              min: 50,
              max: 250,
              divisions: 82,
              onChanged: (values) async {
                setState(() {
                  _selectedMinheight = values.start;
                  _selectedMaxheight = values.end;
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setDouble(
                    "selected_min_height", _selectedMinheight);
                await prefs.setDouble(
                    "selected_max_height", _selectedMaxheight);
              },
            ),
            SizedBox(height: 20),

            // Search Button
            ElevatedButton(
              onPressed: () async {
                await _onSearch();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8A2727),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              child: Text(localizations.translate('search'), style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
