import 'package:flutter/material.dart';
import 'package:buntsmatrimony/api_services.dart';
import 'package:buntsmatrimony/custom_widget.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:buntsmatrimony/upload_image.dart';
import 'package:buntsmatrimony/api_models.dart';

class RegisterFamilyDetailsPage extends StatefulWidget {
  final String matriId;
  final String id;
  final maritalStatus;
  const RegisterFamilyDetailsPage({
    super.key,
    required this.matriId,
    required this.id,
    required this.maritalStatus,
  });

  @override
  _RegisterFamilyDetailsPageState createState() =>
      _RegisterFamilyDetailsPageState();
}

class _RegisterFamilyDetailsPageState extends State<RegisterFamilyDetailsPage> {
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

  final List<String> kidsOptions = ['0', '1', '2', '3', '4+'];
  final List<String> brothersOptions = ['0', '1', '2', '3', '4+'];
  final List<String> sistersOptions = ['0', '1', '2', '3', '4+'];
  Map<String, String> motherTongueMap = {};
  List<String> motherTongueOptions = [];
  final List<String> familyTypes = [
    'Single',
    'Joint',
    'Extended',
    'Nuclear',
    'Blended',
  ];

  String? fatherNameError;
  Color appcolor = Color(0xFFea4a57);
  String? motherNameError;
  String? kidsError;
  String? brothersError;
  String? sistersError;
  String? motherTongueError;

  List<String> filteredMotherTongueOptions = [];
  TextEditingController motherTongueSearchController = TextEditingController();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
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
      motherTongueError = selectedMotherTongue == null
          ? "Select Mother Tongue"
          : null;
      if (widget.maritalStatus != "1") {
        kidsError = selectedKids == null ? "Select no. of kids" : null;
      } else {
        kidsError = null;
      }
    });

    if (fatherNameError == null &&
        motherNameError == null &&
        motherTongueError == null &&
        kidsError == null) {
      String? updatedMotherTongue = selectedMotherTongue != null
          ? motherTongueMap[selectedMotherTongue]
          : null;
      bool success = await ApiService.registeredFamilyDetails(
        matriID: widget.matriId,
        id: widget.id,
        fatherName: fatherNameController.text,
        motherName: motherNameController.text,
        fatherOccupation: fatherOccupationController.text,
        motherOccupation: motherOccupationController.text,
        fatherLivingStatus: "0",
        motherLivingStatus: "0",
        numberOfBrothers: selectedBrothers,
        numberOfSisters: selectedSisters,
        numberOfMarriedBrothers: "0",
        numberOfMarriedSisters: "0",
        referenceNumber: referencePhoneController.text,
        reference: referenceNameController.text,
        place: permanentAddressController.text,
        motherTongue: updatedMotherTongue,
        familyType: selectedFamilyType ?? "",
        noOfKids: selectedKids,
      );
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UploadImagePage(matriId: widget.matriId, id: widget.id),
          ),
        );
      } else {
        print("Failed to save details");
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
            children: [
              SizedBox(height: 20),
              if (widget.maritalStatus != "1")
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
                localizations.translate('father_occupation'),
                fatherOccupationController,
              ),
              buildTextField(
                localizations.translate('mother_name'),
                motherNameController,
                errorText: motherNameError,
              ),
              buildTextField(
                localizations.translate('mother_occupation'),
                motherOccupationController,
              ),
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
              buildTextField(
                localizations.translate('permanent_address'),
                permanentAddressController,
              ),
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
              buildDropdown(
                localizations.translate('family_type'),
                familyTypes,
                selectedFamilyType,
                (value) => setState(() => selectedFamilyType = value),
              ),
              buildTextField(
                localizations.translate('reference_name'),
                referenceNameController,
              ),
              buildTextField(
                localizations.translate('reference_phone'),
                referencePhoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              customElevatedButton(
                validateAndProceed,
                localizations.translate('next'),
              ),
              customTextButton(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UploadImagePage(matriId: widget.matriId, id: widget.id),
                  ),
                );
              }, localizations.translate('skip')),
            ],
          ),
        ),
      ),
    );
  }
}
