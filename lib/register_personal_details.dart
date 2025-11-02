import 'package:flutter/material.dart';
import 'package:practice/lang.dart';
import 'package:practice/register_additional_details.dart';
import 'dashboard_model.dart';
import 'package:practice/custom_widget.dart';
import 'api_services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RegisterPersonalDetails extends StatefulWidget {
  final String profileType;
  final String profileCreator;
  final String creatorName;
  final String creatorPhone;
  final String password;

  const RegisterPersonalDetails(
      {super.key,
      required this.profileType,
      required this.profileCreator,
      required this.creatorName,
      required this.creatorPhone,
      required this.password,});

  @override
  RegisterPersonalDetailsState createState() => RegisterPersonalDetailsState();
}

class RegisterPersonalDetailsState extends State<RegisterPersonalDetails> {
  String selectedGender = "";
  String pageTitle = "Enter your Personal Details";
  bool showGenderOptions = true;
  String genderIcon = "";
  bool _isOffline = false;

  String? selectedMaritalStatus;
  String? selectedSubCaste;
  String updatedGender = "";
 

  final List<String> maritalStatusOptions = [
    "Unmarried",
    "Widow/Widower",
    "Divorcee",
    "Separated",
    "Married"
  ];

  String? _getMaritalStatusCode(String? status) {
    Map<String, String> statusMap = {
      "Unmarried": "1",
      "Widow/Widower": "2",
      "Divorcee": "3",
      "Separated": "4",
      "Married": "5",
    };
    return statusMap[status];
  }

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? dobError;
  String? phoneError;
  String? emailError;
  String? firstNameError;
  String? lastNameError;
  String? maritalStatusError;
  String? subCasteError;

  List<String> subCasteOptions = [];
  Map<String, String> subCasteMap = {};
  List<String> filteredSubCasteOptions = [];
  TextEditingController subCasteSearchController = TextEditingController();
  String? selectedValue;
   Color appcolor = Color(0xFFC3A38C);

  @override
  void initState() {
    super.initState();

    _checkInternet();

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      setState(() {
        _isOffline = !result.contains(ConnectivityResult.mobile) &&
            !result.contains(ConnectivityResult.wifi);
      });
    });

    print("Password: ${widget.password}");
    print("Profile creator: ${widget.profileCreator}");
    print("Profile for: ${widget.profileType}");

    phoneController.addListener(() {
      setState(() {
        phoneError = _validatePhone(phoneController.text);
      });
    });

    emailController.addListener(() {
      setState(() {
        emailError = _validateEmail(emailController.text);
      });
    });

    firstNameController.addListener(() {
      setState(() {
        firstNameError = _validateName(firstNameController.text);
      });
    });

    lastNameController.addListener(() {
      setState(() {
        lastNameError = _validateName(lastNameController.text);
      });
    });

    dobController.addListener(() {
      setState(() {
        dobError = _validateDOB(dobController.text);
      });
    });

    fetchSubCastes();
    subCasteSearchController.addListener(() {
      _filterSubCasteOptions(subCasteSearchController.text);
    });
  }

  @override
void didChangeDependencies() {
    super.didChangeDependencies();
    _setProfileDetails(); 
}

  Future<void> _checkInternet() async {
    var localizations = AppLocalizations.of(context);
    List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = !connectivityResult.contains(ConnectivityResult.mobile) &&
          !connectivityResult.contains(ConnectivityResult.wifi);
    });

    if (_isOffline) {
      _showPopup(localizations.translate('no_internet'), localizations.translate('no_internet_msg'));
    }
  }

  void _showPopup(String title, String message) {
    var localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                Text(localizations.translate('ok'), style: TextStyle(color: Colors.red, fontSize: 16)),      
            ),
          ],
        );
      },
    );
  }

  void _setProfileDetails() {
    var localizations = AppLocalizations.of(context);
    switch (widget.profileType) {
      case "1":
        pageTitle = localizations.translate('enter_personal_details');
        selectedGender = "";
        showGenderOptions = true;
        break;
      case "2":
        pageTitle = localizations.translate('enter_sons_details');
        selectedGender = localizations.translate('gender_male');
        genderIcon = "assets/2.png";
        showGenderOptions = false;
        break;
      case "3":
        pageTitle = localizations.translate('enter_daughters_details');
        selectedGender = localizations.translate('gender_female');
        genderIcon = "assets/1.png";
        showGenderOptions = false;
        break;
      case "4":
        pageTitle = localizations.translate('enter_brothers_details');
        selectedGender = localizations.translate('gender_male');
        genderIcon = "assets/2.png";
        showGenderOptions = false;
        break;
      case "5":
        pageTitle = localizations.translate('enter_sisters_details');
        selectedGender = localizations.translate('gender_female');
        genderIcon = "assets/1.png";
        showGenderOptions = false;
        break;
      // default:
      //   pageTitle = "Enter your Personal Details";
      //   selectedGender = "";
      //   showGenderOptions = true;
    }
  }

  Future<void> fetchSubCastes() async {
    try {
      List<searchsubcaste>? subCastes = await ApiService.fetchSubCaste("1");

      if (subCastes.isNotEmpty) {
        setState(() {
          subCasteMap = {for (var e in subCastes) e.sub_caste: e.id};

          subCasteOptions = subCasteMap.keys.toList();
        });
      }
    } catch (e) {
      print("Error fetching sub castes: $e");
    }
  }

  void _filterSubCasteOptions(String query) {
    setState(() {
      filteredSubCasteOptions = subCasteOptions
          .where((subCaste) =>
              subCaste.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          pageTitle,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showGenderOptions)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGenderSelection(
                            localizations.translate('gender_male'),
                            "assets/2.png"),
                        SizedBox(width: 20),
                        _buildGenderSelection(
                            localizations.translate('gender_female'),
                            "assets/1.png"),
                      ],
                    )
                  else
                    _buildFixedGenderImage(),
                ],
              ),
              SizedBox(height: 20),
              buildTextField(
                  localizations.translate('first_name'), firstNameController,
                  errorText: firstNameError),
              buildTextField(
                  localizations.translate('last_name'), lastNameController,
                  errorText: lastNameError),
              _buildDOBField(),
              buildTextField(
                  localizations.translate('phone_number'), phoneController,
                  keyboardType: TextInputType.phone, errorText: phoneError),
              buildTextField(localizations.translate('email'), emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorText: emailError),
              buildDropdown(
                  localizations.translate('marital_status'),
                  maritalStatusOptions,
                  selectedMaritalStatus,
                  (newValue) => setState(() {
                        selectedMaritalStatus = newValue;
                        maritalStatusError = null;
                      }),
                  errorText: maritalStatusError),
              buildDropdown(
                  localizations.translate('sub_caste'),
                  subCasteOptions,
                  selectedSubCaste,
                  (newValue) => setState(() {
                        selectedSubCaste = newValue;
                        subCasteError = null;
                      }),
                  errorText: subCasteError),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: customElevatedButton(
                    validateAndProceed, localizations.translate('next')),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFixedGenderImage() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(genderIcon),
        ),
        SizedBox(height: 8),
        Text(
          selectedGender,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> validateAndProceed() async {
    if (_isOffline) {
      _showPopup("No Internet Connection", "Please check your network.");
      return;
    }

    if (selectedGender.isEmpty) {
      _showGenderSelectionAlert();
      return;
    }

    setState(() {
      firstNameError = _validateName(firstNameController.text);
      lastNameError = _validateName(lastNameController.text);
      dobError = _validateDOB(dobController.text);
      phoneError = _validatePhone(phoneController.text);
      emailError = _validateEmail(emailController.text);
      maritalStatusError = selectedMaritalStatus == null
          ? "Please select a marital status"
          : null;
      subCasteError =
          selectedSubCaste == null ? "Please select a sub caste" : null;
    });

    if (phoneError == null) {
      bool isPhoneValid =
          await ApiService.validatePhoneNumber(phoneController.text);

      if (!isPhoneValid) {
        setState(() {
          phoneError = "Phone number is already registered";
        });
        return;
      }
    }

    if (firstNameError == null &&
        lastNameError == null &&
        dobError == null &&
        phoneError == null &&
        emailError == null &&
        maritalStatusError == null &&
        subCasteError == null) {
      String? updatedMaritalStatus = selectedMaritalStatus != null
          ? _getMaritalStatusCode(selectedMaritalStatus)
          : null;

      String? updatedSubCaste =
          selectedSubCaste != null ? subCasteMap[selectedSubCaste] : null;

      if (selectedGender == 'ಪುರುಷ' || selectedGender == 'Male') {
        updatedGender = "Male";
      }else{
        updatedGender = "Female";
      }

      try {
        Map<String, String>? registrationData =
            await ApiService.registeredPersonalDetails(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          dob: dobController.text,
          phone: phoneController.text,
          email: emailController.text,
          subCaste: updatedSubCaste,
          maritalStatus: updatedMaritalStatus,
          gender: updatedGender == "Male" ? "1" : "2",
          creatorName: widget.creatorName,
          creatorPhone: widget.creatorPhone,
          profileCreator: widget.profileCreator,
          profileFor: widget.profileType,
          password: widget.password,
        );

        if (registrationData != null) {
          if (registrationData.containsKey("error")) {
            String errorMsg = registrationData["error"]!;

            if (errorMsg.contains("EMAIL")) {
              setState(() {
                emailError = "This email is already registered.";
              });
              return;
            }
          } else {
            String matriId = registrationData["matri_id"] ?? "";
            String id = registrationData["id"] ?? "";

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterAdditionalDetailsPage(
                  matriId: matriId,
                  id: id,
                  maritalStatus: updatedMaritalStatus,
                ),
              ),
            );
          }
        }
      } catch (e) {
        print("Error during registration: $e");
        setState(() {
          emailError = "Something went wrong. Please try again.";
        });
      }
    }
  }

  void _showGenderSelectionAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Gender Selection"),
          content: Text("Please select your gender first."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  String? _validateDOB(String dob) {
    if (dob.isEmpty) return "Date of Birth is required";
    DateTime? birthDate;
    try {
      List<String> parts = dob.split('/');
      birthDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (e) {
      return "Enter a valid Date of Birth (DD/MM/YYYY)";
    }

    DateTime minDate =
        DateTime.now().subtract(Duration(days: 6570)); // 18 years
    if (birthDate.isAfter(minDate)) return "You must be at least 18 years old";

    return null;
  }

  String? _validatePhone(String phone) {
    if (phone.isEmpty) {
      return "Phone number is required";
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      return "Enter a valid 10-digit phone number";
    }
    return null;
  }

  String? _validateName(String name) {
    if (name.isEmpty) {
      return "Name is required";
    } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(name)) {
      return "Only alphabets are allowed";
    }
    return null;
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return "Email is required";
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return "Enter a valid email";
    }
    return null;
  }

  Widget _buildDOBField() {
    var localizations = AppLocalizations.of(context);
    return buildTextField(localizations.translate('dob'), dobController,
        readOnly: true, onTap: _pickDOB, errorText: dobError);
  }

  Future<void> _pickDOB() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      DateTime minDate =
          DateTime.now().subtract(Duration(days: 6570)); // 18 years ago
      setState(() {
        if (pickedDate.isAfter(minDate)) {
          dobError = "You must be at least 18 years old";
        } else {
          dobController.text =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          dobError = null;
        }
      });
    }
  }

  Widget _buildGenderSelection(String gender, String imagePath) {
    bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() => selectedGender = gender);
      },
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(imagePath),
              ),
              if (!isSelected && selectedGender.isNotEmpty)
                Positioned.fill(
                  child: ClipOval(
                    child: Container(color: Colors.white.withOpacity(0.4)),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            gender,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isSelected ? Color.fromARGB(255, 109, 78, 115) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
