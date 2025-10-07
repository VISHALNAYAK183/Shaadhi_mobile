import 'package:flutter/material.dart';
import 'package:practice/api_models.dart';
import 'package:practice/api_services.dart';
import 'package:practice/custom_widget.dart';
import 'package:practice/lang.dart';
import 'package:practice/register_horoscope_details.dart';


class RegisterEducationProfessionPage extends StatefulWidget {
  final String matriId;
  final String id;
  final maritalStatus;
  const RegisterEducationProfessionPage(
      {super.key,
      required this.matriId,
      required this.id,
      required this.maritalStatus,});

  @override
  RegisterEducationProfessionPageState createState() =>
      RegisterEducationProfessionPageState();
}

class RegisterEducationProfessionPageState
    extends State<RegisterEducationProfessionPage> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyCityController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  String? selectedSpecialisation;
  String? selectedProfession;
  String? selectedSalaryRange;

  String? qualificationError;
  String? specialisationError;
  String? professionError;
  String? salaryError;
   Color appcolor = Color(0xFF8A2727);

  List<String> filteredQualification = [];
  TextEditingController qualificationSearchController = TextEditingController();

  List<String> filteredSpecialisation = [];
  TextEditingController specialisationSearchController =
      TextEditingController();

  String? selectedValue;

  Map<String, String> qualificationMap = {}; // Map to store name -> ID
  List<String> qualifications = [];
  List<String> selectedQualifications = [];

  Map<String, String> specialisationMap = {}; // Map to store name -> ID
  List<String> specialisations = [];
  List<String> selectedSpecialisations = [];

  final List<String> salaryRangeOptions = [
    "0-1 Lakh",
    "1-2 Lakh",
    "2-3 Lakh",
    "3-5 Lakh",
    "5-7 Lakh",
    "7-9 Lakh",
    "9-11 Lakh",
    "11-13 Lakh",
    "13-15 Lakh",
    "15-20 Lakh",
    "20-25 Lakh",
    "25-30 Lakh",
    "30-35 Lakh",
    "35-40 Lakh",
    "40-45 Lakh",
    "45-50 Lakh",
    "50 Lakh and Above"
  ];

  @override
  void initState() {
    super.initState();
    fetchOccupations();
    fetchEducation();
    qualificationSearchController.addListener(() {
      _filterQualifications(qualificationSearchController.text);
    });

    specialisationSearchController.addListener(() {
      _filterSpecialisations(specialisationSearchController.text);
    });
  }

  Map<String, String> professionMap = {};
  List<String> professionOptions = [];

  Future<void> fetchOccupations() async {
    try {
      List<OccupationItems> occupations = await ApiService.fetchOccupation();

      if (occupations.isNotEmpty) {
        setState(() {
          professionMap = {for (var e in occupations) e.name: e.id};
          professionOptions = professionMap.keys.toList();
        });
      }
    } catch (e) {
      print("Error fetching occupations: $e");
    }
  }

  Future<void> fetchEducation() async {
    try {
      List<EducationItems>? educationList = await ApiService.fetchEducations();
      if (educationList.isNotEmpty) {
        setState(() {
          qualificationMap = {for (var e in educationList) e.name: e.id};
          qualifications = qualificationMap.keys.toList();

          specialisationMap = {for (var e in educationList) e.name: e.id};
          specialisations = specialisationMap.keys.toList();
        });
      }
    } catch (e) {
      print("Error fetching education: $e");
    }
  }

  void _filterQualifications(String query) {
    setState(() {
      filteredQualification = qualifications
          .where((option) => option.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (!filteredQualification.contains(selectedValue)) {
        selectedValue = null;
      }
    });
  }

  void _filterSpecialisations(String query) {
    setState(() {
      filteredSpecialisation = specialisations
          .where((option) => option.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (!filteredSpecialisation.contains(selectedValue)) {
        selectedValue = null;
      }
    });
  }

  Future<void> validateAndProceed() async {
    setState(() {
      qualificationError = selectedQualifications.isEmpty
          ? "Select at least one qualification"
          : null;
      specialisationError = (selectedSpecialisations.isEmpty)
          ? "Select at least one Specialisation"
          : null;
      professionError =
          (selectedProfession == null) ? "Select Profession" : null;
      salaryError = selectedSalaryRange == null ? "Select salary range" : null;
    });

    if (qualificationError == null &&
        specialisationError == null &&
        professionError == null &&
        salaryError == null) {
      String? updatedSalaryRange = selectedSalaryRange;

      String? updatedProfession =
          selectedProfession != null ? professionMap[selectedProfession] : null;

      List<String> qualificationIDs = selectedQualifications
          .map((q) => qualificationMap[q] ?? "")
          .where((id) => id.isNotEmpty)
          .toList();

      List<String> specialisationIDs = selectedSpecialisations
          .map((q) => specialisationMap[q] ?? "")
          .where((id) => id.isNotEmpty)
          .toList();
      bool success = await ApiService.registredEducationDetails(
        matriID: widget.matriId,
        id: widget.id,
        qualification: qualificationIDs.join(","),
        specialization: specialisationIDs.join(","),
        profession: updatedProfession,
        companyName: companyNameController.text,
        companyCity: companyCityController.text,
        salaryRange: updatedSalaryRange,
      );

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegisterHoroscopeDetailsPage(
                    matriId: widget.matriId,
                    id: widget.id,
                    maritalStatus: widget.maritalStatus,
                  )),
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
          localizations.translate('education_profession'),
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
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showCustomDialog(
                    context: context,
                    title: "Select Qualification",
                    options: qualifications,
                    selectedValues: selectedQualifications,
                    onSelected: (List<String> values) {
                      setState(() {
                        selectedQualifications = values;
                        qualificationSearchController.text =
                            selectedQualifications.join(", ");
                        qualificationError = null;
                      });
                    },
                  );
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: qualificationSearchController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: localizations.translate('qualification'),
                      labelStyle: const TextStyle(color: Color(0xFF8A2727)),
                      border: OutlineInputBorder(),
                      errorText: qualificationError,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8A2727),
                    ),
                    readOnly: true,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  showCustomDialog(
                    context: context,
                    title: "Select Specialisation",
                    options: specialisations,
                    selectedValues: selectedSpecialisations,
                    onSelected: (List<String> values) {
                      setState(() {
                        selectedSpecialisations = values;
                        specialisationSearchController.text =
                            selectedSpecialisations.join(", ");
                        specialisationError = null;
                      });
                    },
                  );
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: specialisationSearchController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: localizations.translate('specialisation'),
                      labelStyle: const TextStyle(color: Color(0xFF8A2727)),
                      border: OutlineInputBorder(),
                      errorText: specialisationError,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8A2727),
                    ),
                    readOnly: true,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              buildDropdown(
                  localizations.translate('profession'),
                  professionOptions,
                  selectedProfession,
                  (value) => setState(() {
                        selectedProfession = value;
                        professionError = null;
                      }),
                  errorText: professionError),
              buildTextField(localizations.translate('company_name'),
                  companyNameController),
              buildTextField(localizations.translate('company_city'),
                  companyCityController),
              buildDropdown(
                  localizations.translate('salary_range'),
                  salaryRangeOptions,
                  selectedSalaryRange,
                  (value) => setState(() {
                        selectedSalaryRange = value;
                        salaryError = null;
                      }),
                  errorText: salaryError),
              const SizedBox(height: 20),
              customElevatedButton(
                  validateAndProceed, localizations.translate('next')),
              customTextButton(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterHoroscopeDetailsPage(
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
