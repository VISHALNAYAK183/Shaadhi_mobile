import 'package:practice/api_service.dart';
import 'package:practice/dashboard_model.dart';
import 'package:practice/lang.dart';
import 'package:practice/register_education_profession_details.dart';
import 'package:flutter/material.dart';
import 'package:practice/custom_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterAdditionalDetailsPage extends StatefulWidget {
  final String matriId;
  final String id;
  final maritalStatus;
  const RegisterAdditionalDetailsPage(
      {super.key,
      required this.matriId,
      required this.id,
      required this.maritalStatus});

  @override
  RegisterAdditionalDetailsPageState createState() =>
      RegisterAdditionalDetailsPageState();
}

class RegisterAdditionalDetailsPageState
    extends State<RegisterAdditionalDetailsPage> {
  late Locale _currentLocale;
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String? selectedBloodGroup;
   Color appcolor = Color(0xFFC3A38C);
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
  String? addressError;

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
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
    fetchCountries().then((_) {
      if (selectedCountry != null) {
        fetchStates(initialLoad: true);
      }
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
            for (var e in countryList) e.country_name: e.country_id
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
          "selected_country_id", countryMap[selectedCountry] ?? "");

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

  Future<void> validateAndProceed() async {
    setState(() {
      heightError = _validateHeight(heightController.text);
      bloodGroupError =
          selectedBloodGroup == null ? "Select Blood Group" : null;
      complexionError = selectedComplexion == null ? "Select Complexion" : null;
      countryError = selectedCountry == null ? "Select Country" : null;
      stateError = selectedState == null ? "Select State" : null;
      cityError = selectedCity == null ? "Select City" : null;
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

      bool success = await ApiService.registeredAdditionalDetails(
        matriID: widget.matriId,
        id: widget.id,
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
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterEducationProfessionPage(
                    matriId: widget.matriId,
                    id: widget.id,
                    maritalStatus: widget.maritalStatus,
                  )),
        );
      } else {
        print("Failed to save additional details");
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
            child: Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 25),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              buildTextField(localizations.translate('height'), heightController,
                  keyboardType: TextInputType.number, errorText: heightError),
              buildTextField(
                localizations.translate('weight'),
                weightController,
                keyboardType: TextInputType.number,
              ),
              // const SizedBox(height: 5),
              buildDropdown(
                  localizations.translate('blood_group'),
                  bloodGroups,
                  selectedBloodGroup,
                  (value) => setState(() {
                        selectedBloodGroup = value;
                        bloodGroupError = null;
                      }),
                  errorText: bloodGroupError),
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

              const SizedBox(height: 5),
              buildTextField(
                  localizations.translate('address'), addressController),
              buildTextField(
                  localizations.translate('remarks'), remarksController,
                  maxLines: 3),
              const SizedBox(height: 20),
              customElevatedButton(
                  validateAndProceed, localizations.translate('next')),
              customTextButton(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterEducationProfessionPage(
                            matriId: widget.matriId,
                            id: widget.id,
                            maritalStatus: widget.maritalStatus,
                          )),
                );
              }, localizations.translate('skip')),
            ],
          ),
        ),
      ),
    );
  }
}
