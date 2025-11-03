import 'package:buntsmatrimony/api_service.dart';
import 'package:buntsmatrimony/dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:buntsmatrimony/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_widget.dart';

class AdditionalDetailsPage extends StatefulWidget {
  final userprofile profile;

  const AdditionalDetailsPage({super.key, required this.profile});

  @override
  AdditionalDetailsPageState createState() => AdditionalDetailsPageState();
}

class AdditionalDetailsPageState extends State<AdditionalDetailsPage> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String? selectedBloodGroup;
  String? selectedComplexion;
  String? selectedDisability;
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  String? heightError;
  String? bloodGroupError;
  String? complexionError;
  String? countryError;
  String? stateError;
  String? cityError;
  Color appcolor = Color(0xFFea4a57);

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];
  final List<String> complexions = ['Fair', 'Wheatish', 'Dusky', 'Dark'];
  final List<String> disabilityOptions = ['No', 'Yes'];

  List<String> countries = [];
  List<String> states = [];
  List<String> cities = [];

  Map<String, String> countryMap = {};
  Map<String, String> stateMap = {};
  Map<String, String> cityMap = {};

  @override
  void initState() {
    super.initState();
    fetchProfileDetails().then((_) {
      fetchCountries().then((_) {
        if (selectedCountry != null) {
          fetchStates(initialLoad: true);
        }
      });
    });
    heightController.addListener(() {
      setState(() {
        heightError = _validateHeight(heightController.text);
      });
    });
  }

  Future<void> fetchCountries() async {
    try {
      List<searchcountry> countryList = await ApiService.fetchcountry();
      if (countryList.isNotEmpty) {
        setState(() {
          countryMap = {
            for (var e in countryList) e.country_name: e.country_id,
          };
          countries = countryMap.keys.toList();
        });
      }
    } catch (e) {
      print("Error fetching countries: $e");
    }
  }

  Future<void> fetchStates({bool initialLoad = false}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        "selected_country_id",
        countryMap[selectedCountry] ?? "",
      );

      List<searchstate> statesList = await ApiService.fetchstate();

      if (statesList.isNotEmpty) {
        setState(() {
          stateMap = {for (var e in statesList) e.state_name: e.state_id};
          states = stateMap.keys.toList();

          if (!initialLoad || !states.contains(selectedState)) {
            selectedState = null;
            selectedCity = null;
          } else {
            fetchCities(initialLoad: true);
          }
        });
      } else {
        setState(() {
          states.clear();
          cities.clear();
          selectedState = null;
          selectedCity = null;
        });
      }
    } catch (e) {
      print("Error fetching states: $e");
    }
  }

  Future<void> fetchCities({bool initialLoad = false}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("selected_state_id", stateMap[selectedState] ?? "");

      List<searchcity> citiesList = await ApiService.fetchcity();

      if (citiesList.isNotEmpty) {
        setState(() {
          cityMap = {for (var e in citiesList) e.city_name: e.city_id};
          cities = cityMap.keys.toList();

          if (!initialLoad || !cities.contains(selectedCity)) {
            selectedCity = null;
          }
        });
      } else {
        setState(() {
          cities.clear();
          selectedCity = null;
        });
      }
    } catch (e) {
      print("Error fetching cities: $e");
    }
  }

  Future<void> fetchProfileDetails() async {
    try {
      setState(() {
        heightController.text = widget.profile.height;
        weightController.text = widget.profile.weight;
        addressController.text = widget.profile.address;
        selectedBloodGroup = widget.profile.bloodGroup;
        selectedDisability = widget.profile.disability;
        selectedCity = widget.profile.city;
        selectedComplexion = widget.profile.complexion;
        selectedCountry = widget.profile.country;
        selectedState = widget.profile.state;
        remarksController.text = widget.profile.remark;
      });
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  String? _validateHeight(String height) {
    if (height.isEmpty) {
      return null;
    }
    int? heightValue = int.tryParse(height);
    if (heightValue != null && heightValue < 100) {
      return "Minimum height required is 100 cm";
    }
    return null;
  }

  void validateAndProceed() async {
    setState(() {
      heightError = _validateHeight(heightController.text);
      bloodGroupError =
          (selectedBloodGroup == null || selectedBloodGroup!.isEmpty)
          ? "Select Blood Group"
          : null;
      complexionError =
          (selectedComplexion == null || selectedComplexion!.isEmpty)
          ? "Select Complexion"
          : null;
      countryError = (selectedCountry == null || selectedCountry!.isEmpty)
          ? "Select Country"
          : null;
      stateError = (selectedState == null || selectedState!.isEmpty)
          ? "Select State"
          : null;
      cityError = (selectedCity == null || selectedCity!.isEmpty)
          ? "Select City"
          : null;
    });

    if (heightError == null &&
        bloodGroupError == null &&
        complexionError == null &&
        countryError == null &&
        stateError == null &&
        cityError == null) {
      String? updatedCountry = countryMap[selectedCountry];
      String? updatedState = stateMap[selectedState];
      String? updatedCity = cityMap[selectedCity];

      bool success = await ApiService.updateAdditionalDetails(
        context,
        matriID: widget.profile.matriId,
        id: widget.profile.id,
        height: heightController.text,
        weight: weightController.text,
        bloodGroup: selectedBloodGroup,
        complexion: selectedComplexion,
        country: updatedCountry,
        state: updatedState,
        city: updatedCity,
        disability: selectedDisability,
        address: addressController.text,
        remark: remarksController.text,
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage1()),
        );
      } else {
        print("Failed to update additional details");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          localizations.translate('additional_details'),
          style: TextStyle(color: Colors.white),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildTextField(
                localizations.translate('height'),
                heightController,
                errorText: heightError,
                keyboardType: TextInputType.number,
              ),
              buildTextField(
                localizations.translate('weight'),
                weightController,
                keyboardType: TextInputType.number,
              ),
              buildDropdown(
                localizations.translate('blood_group'),
                bloodGroups,
                selectedBloodGroup,
                (value) => setState(() {
                  selectedBloodGroup = value;
                  bloodGroupError = null;
                }),
                errorText: bloodGroupError,
              ),
              buildDropdown(
                localizations.translate('complexion'),
                complexions,
                selectedComplexion,
                (value) {
                  setState(() {
                    selectedComplexion = value;
                    complexionError = null;
                  });
                },
                errorText: complexionError,
              ),
              buildDropdown(
                localizations.translate('disabilities'),
                disabilityOptions,
                selectedDisability,
                (value) {
                  setState(() {
                    selectedDisability = value;
                  });
                },
              ),
              buildDropdown(
                localizations.translate('country'),
                countries,
                selectedCountry,
                (value) async {
                  setState(() {
                    selectedCountry = value!;
                    countryError = null;
                    selectedState = null;
                    selectedCity = null;
                    states.clear();
                    cities.clear();
                  });
                  await fetchStates();
                },
                errorText: countryError,
              ),
              buildDropdown(
                localizations.translate('state'),
                states,
                selectedState,
                (value) async {
                  setState(() {
                    selectedState = value!;
                    stateError = null;
                    selectedCity = null;
                    cities.clear();
                  });
                  await fetchCities();
                },
                errorText: stateError,
              ),
              buildDropdown(
                localizations.translate('city'),
                cities,
                selectedCity,
                (value) {
                  setState(() {
                    selectedCity = value!;
                    cityError = null;
                  });
                },
                errorText: cityError,
              ),
              buildTextField(
                localizations.translate('address'),
                addressController,
              ),
              buildTextField(
                localizations.translate('remarks'),
                remarksController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              customElevatedButton(
                validateAndProceed,
                localizations.translate('submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
