import 'package:flutter/material.dart';
// import 'package:buntsmatrimony/dashboard.dart';
import 'package:buntsmatrimony/dashboard_model.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:buntsmatrimony/profile_page.dart';
import 'custom_widget.dart';
import 'api_services.dart';

class PersonalDetails extends StatefulWidget {
  final userprofile profile;

  const PersonalDetails({super.key, required this.profile});

  @override
  PersonalDetailsState createState() => PersonalDetailsState();
}

class PersonalDetailsState extends State<PersonalDetails> {
  String selectedGender = "";
  Color appcolor = Color(0xFFea4a57);

  String? selectedMaritalStatus;
  String? selectedSubCaste;
  final List<String> maritalStatusOptions = [
    "Unmarried",
    "Widow/Widower",
    "Divorcee",
    "Separated",
    "Married",
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
  List<String> filteredSubCasteOptions = [];
  TextEditingController subCasteSearchController = TextEditingController();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    fetchSubCastes();
    fetchProfileDetails();

    subCasteSearchController.addListener(() {
      _filterSubCasteOptions(subCasteSearchController.text);
    });
  }

  void _filterSubCasteOptions(String query) {
    setState(() {
      filteredSubCasteOptions = subCasteOptions
          .where(
            (subCaste) => subCaste.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  Future<void> fetchProfileDetails() async {
    try {
      setState(() {
        firstNameController.text = widget.profile.firstName;
        lastNameController.text = widget.profile.lastName;
        phoneController.text = widget.profile.phone;
        emailController.text = widget.profile.email;
        selectedMaritalStatus = widget.profile.status;
        selectedSubCaste = widget.profile.subCaste;
        if (widget.profile.dob.isNotEmpty) {
          List<String> parts = widget.profile.dob.split('-');
          if (parts.length == 3) {
            dobController.text = "${parts[2]}/${parts[1]}/${parts[0]}";
          }
        }
      });
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Map<String, String> subCasteMap = {}; // Map to store name -> ID

  Future<void> fetchSubCastes() async {
    try {
      List<searchsubcaste>? subCastes = await ApiService.fetchSubCaste("1");

      if (subCastes.isNotEmpty) {
        setState(() {
          subCasteMap = {for (var e in subCastes) e.sub_caste: e.id};

          subCasteOptions = subCasteMap.keys.toList(); // Only store names
        });
      }
    } catch (e) {
      print("Error fetching sub castes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          localizations.translate('basic_details'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              buildTextField(
                localizations.translate('first_name'),
                firstNameController,
                readOnly: true,
              ),
              buildTextField(
                localizations.translate('last_name'),
                lastNameController,
                readOnly: true,
              ),
              _buildDOBField(),
              buildTextField(
                localizations.translate('phone_number'),
                phoneController,
                readOnly: true,
                keyboardType: TextInputType.phone,
                errorText: phoneError,
              ),
              buildTextField(
                localizations.translate('email'),
                emailController,
                readOnly: true,
                keyboardType: TextInputType.emailAddress,
                errorText: emailError,
              ),
              buildDropdown(
                localizations.translate('marital_status'),
                maritalStatusOptions,
                selectedMaritalStatus,
                (newValue) => setState(() {
                  selectedMaritalStatus = newValue;
                  maritalStatusError = null;
                }),
                errorText: maritalStatusError,
              ),
              buildDropdown(
                localizations.translate('sub_caste'),
                subCasteOptions,
                selectedSubCaste,
                (newValue) => setState(() {
                  selectedSubCaste = newValue;
                  subCasteError = null;
                }),
                errorText: subCasteError,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: customElevatedButton(
                  validateAndProceed,
                  localizations.translate('submit'),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void validateAndProceed() async {
    setState(() {
      maritalStatusError = selectedMaritalStatus == null
          ? "Please select a marital status"
          : null;
      subCasteError = selectedSubCaste == null
          ? "Please select a sub caste"
          : null;
    });

    if (maritalStatusError == null && subCasteError == null) {
      String? updatedSubCaste = selectedSubCaste != null
          ? subCasteMap[selectedSubCaste]
          : widget.profile.subCasteId;

      String? updatedMaritalStatus = selectedMaritalStatus != null
          ? _getMaritalStatusCode(selectedMaritalStatus)
          : _getMaritalStatusCode(widget.profile.status);

      print(
        "Sending API update: MaritalStatus ID: $updatedMaritalStatus, SubCaste ID: $updatedSubCaste",
      );

      bool success = await ApiService.updateProfile(
        context,
        matriID: widget.profile.matriId,
        maritalStatus: updatedMaritalStatus,
        subCaste: updatedSubCaste,
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage1()),
        );
      } else {
        print("Failed to update user profile");
      }
    }
  }

  Widget _buildDOBField() {
    var localizations = AppLocalizations.of(context);
    return buildTextField(
      localizations.translate('dob'),
      dobController,
      readOnly: true,
      errorText: dobError,
    );
  }
}
