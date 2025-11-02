import 'package:flutter/material.dart';
import 'package:practice/dashboard_model.dart';
import 'package:practice/lang.dart';
import 'package:practice/profile_page.dart';
import 'api_services.dart';
import 'custom_widget.dart';
import 'api_models.dart';

class FamilyDetailsPage extends StatefulWidget {
  final userprofile profile;
  const FamilyDetailsPage({super.key, required this.profile});

  @override
  _FamilyDetailsPageState createState() => _FamilyDetailsPageState();
}

class _FamilyDetailsPageState extends State<FamilyDetailsPage> {
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController fatherOccupationController =
      TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController motherOccupationController =
      TextEditingController();
  final TextEditingController permanentAddressController =
      TextEditingController();
  final TextEditingController referenceNameController = TextEditingController();
  final TextEditingController referencePhoneController =
      TextEditingController();

  String? selectedKids;
  String? selectedBrothers;
  String? selectedSisters;
  String? selectedMotherTongue;
  String? selectedFamilyType;
  String selectedFatherLivingStatus="0";
  String selectedMotherLivingStatus="0";
   Color appcolor = Color(0xFFC3A38C);

  String marriedBrothersController="1";
  String marriedSistersController="1";

  final List<String> kidsOptions = ['0', '1', '2', '3', '4+'];
  final List<String> brothersOptions = ['0', '1', '2', '3', '4+'];
  final List<String> sistersOptions = ['0', '1', '2', '3', '4+'];
  final List<String> familyTypes = ['Single','Joint','Extended','Nuclear', 'Blended'];

  String? fatherNameError;
  String? motherNameError;
  String? kidsError;
  String? brothersError;
  String? sistersError;
  String? motherTongueError;

  Map<String, String> motherTongueMap = {};
  List<String> motherTongueOptions = [];
  TextEditingController motherTongueSearchController = TextEditingController();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    fetchProfileDetails();
    fetchMotherTongue();

    fatherNameController.addListener(() {
      setState(() {
        fatherNameError = _validateFathersName(fatherNameController.text);
      });
    });

    motherNameController.addListener(() {
      setState(() {
        motherNameError = _validateMothersName(motherNameController.text);
      });
    });
  }

  String? _validateFathersName(String fathername) {
    if (fathername.isEmpty) {
      return "Enter Father's name";
    }
    return null;
  }

  String? _validateMothersName(String mothername) {
    if (mothername.isEmpty) {
      return "Enter Mother's name";
    }
    return null;
  }

  Future<void> fetchProfileDetails() async {
    setState(() {
      fatherNameController.text = widget.profile.fatherName;
      fatherOccupationController.text = widget.profile.fatherOccupation;
      motherNameController.text = widget.profile.motherName;
      motherOccupationController.text = widget.profile.motherOccupation;
      permanentAddressController.text = widget.profile.homeTown;
      referenceNameController.text = widget.profile.reference;
      referencePhoneController.text = widget.profile.reference_no;
      selectedBrothers = widget.profile.numberOfBrothers;
      selectedFamilyType = widget.profile.familyType;
      selectedKids = widget.profile.kids;
      selectedMotherTongue = widget.profile.motherTongue;
      selectedSisters = widget.profile.numberOfSisters;
    });
  }

  Future<void> fetchMotherTongue() async {
    try {
      List<MotherTongueItem> occupations = await ApiService.fetchMotherTongue();

      if (occupations.isNotEmpty) {
        setState(() {
          motherTongueMap = {for (var e in occupations) e.language: e.id};
          motherTongueOptions = motherTongueMap.keys.toList();
        });
      }
    } catch (e) {
      print("Error fetching mother tongue: $e");
    }
  }

  

  Future<void> validateAndProceed() async {
    setState(() {
      fatherNameError = _validateFathersName(fatherNameController.text);
      motherNameError = _validateMothersName(motherNameController.text);
      motherTongueError =
          (selectedMotherTongue == null || selectedMotherTongue!.isEmpty) ? "Select Mother Tongue" : null;
      kidsError = (selectedKids == null || selectedKids!.isEmpty) ? "Select no. of kids" : null;
    });

    if (fatherNameError == null &&
        motherNameError == null &&
        kidsError == null &&
        motherTongueError == null) {

          String? updatedMotherTongue = selectedMotherTongue != null
          ? motherTongueMap[selectedMotherTongue]
          : widget.profile.motherTongue;
      bool success = await ApiService.updateFamilyDetails(context,
  matriID: widget.profile.matriId,
  fatherName: fatherNameController.text,
  motherName: motherNameController.text,
  id: widget.profile.id,
  fatherOccupation: fatherOccupationController.text,
  motherOccupation: motherOccupationController.text,
  numberOfBrothers: selectedBrothers,
  numberOfSisters: selectedSisters,
  referenceNumber: referencePhoneController.text,
  reference: referenceNameController.text,
  place: permanentAddressController.text,
  familyType: selectedFamilyType,
  kidsCount: selectedKids,
  motherTongue: updatedMotherTongue,
);



if (success) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage1(), 
    ),
  );
} else {
  print("Failed to update family details");
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
          localizations.translate('family_details'),
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
            children: [
              if(widget.profile.maritalStatus != "1")
              buildDropdown(
                  localizations.translate('no_of_kids'),
                  kidsOptions,
                  selectedKids,
                  (value) => setState(() {
                    selectedKids = value;
                    kidsError = null;
                  }),
                  errorText: kidsError,
                ),
              buildTextField(
                localizations.translate('father_name'),
                fatherNameController,
                errorText: fatherNameError,
              ),



              buildTextField(
                  localizations.translate('father_occupation'), fatherOccupationController),
              buildTextField(
                localizations.translate('mother_name'),
                motherNameController,
                errorText: motherNameError,
              ),
              buildTextField(
                  localizations.translate('mother_occupation'), motherOccupationController),
              buildDropdown(
                localizations.translate('no_of_brothers'),
                brothersOptions,
                selectedBrothers,
                (value) => setState(() => selectedBrothers = value),
              ),
              buildDropdown(
                localizations.translate('no_of_sisters'),
                sistersOptions,
                selectedSisters,
                (value) => setState(() => selectedSisters = value),
              ),
              buildTextField(localizations.translate('permanent_address'), permanentAddressController),
              buildDropdown(
                localizations.translate('mother_tongue'),
                motherTongueOptions,
                selectedMotherTongue,
                (value) => setState(() {
                  selectedMotherTongue = value;
                  motherTongueError = null;
                }),
                errorText: motherTongueError,
              ),
              buildDropdown(localizations.translate('family_type'), familyTypes, selectedFamilyType,
                  (value) => setState(() => selectedFamilyType = value)),
              buildTextField(localizations.translate('reference_name'), referenceNameController),
              buildTextField(localizations.translate('reference_phone'), referencePhoneController,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              customElevatedButton(validateAndProceed, localizations.translate('submit')),
            ],
          ),
        ),
      ),
    );
  }
}
