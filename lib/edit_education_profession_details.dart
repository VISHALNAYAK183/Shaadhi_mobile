import 'package:flutter/material.dart';
import 'package:practice/dashboard_model.dart';
import 'package:practice/lang.dart';
import 'package:practice/profile_page.dart';
import 'api_models.dart';
import 'api_services.dart';
import 'custom_widget.dart';

class EducationProfessionPage extends StatefulWidget {
  final userprofile profile;

  const EducationProfessionPage({super.key, required this.profile});

  @override
  EducationProfessionPageState createState() => EducationProfessionPageState();
}

class EducationProfessionPageState extends State<EducationProfessionPage> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyCityController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  String? selectedProfession;
  String? selectedSalaryRange;
  String? selectedSpecialisation;
   Color appcolor = Color(0xFFC3A38C);

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


  String? qualificationError;
  String? specialisationError;
  String? professionError;
  String? salaryError;

  List<String> filteredQualification = [];
  TextEditingController qualificationSearchController = TextEditingController();

  List<String> filteredSpecialisation = [];
  TextEditingController specialisationSearchController =
      TextEditingController();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    fetchEducation();
    fetchOccupations();
    fetchProfileDetails();

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

  Future<void> fetchProfileDetails() async {
    try {
      await fetchEducation();
      setState(() {
        companyCityController.text = widget.profile.companyCity;
        companyNameController.text = widget.profile.company;
        selectedSalaryRange = widget.profile.salary;
        selectedProfession = widget.profile.occupation;

        if (specialisationMap.isNotEmpty) {
          selectedSpecialisations = widget.profile.specialization
              .split(',')
              .map((q) {
                String normalizedQ = q.trim().replaceAll(RegExp(r'\s+'), ' ');

                var entry = specialisationMap.entries.firstWhere(
                  (entry) =>
                      entry.key.trim().replaceAll(RegExp(r'\s+'), ' ') ==
                      normalizedQ,
                  orElse: () => MapEntry("", ""),
                );

                print("Mapped Key for '$normalizedQ': '${entry.key}'");
                return entry.key.isNotEmpty ? entry.key : null;
              })
              .whereType<String>()
              .toList();
        }

        specialisationSearchController.text =
            selectedSpecialisations.join(", ");

        if (qualificationMap.isNotEmpty) {
          selectedQualifications = widget.profile.qualification
              .split(',')
              .map((q) {
                String normalizedQ = q.trim().replaceAll(RegExp(r'\s+'), ' ');
                print("Checking Qualification: '$normalizedQ'");

                var entry = qualificationMap.entries.firstWhere(
                  (entry) =>
                      entry.key.trim().replaceAll(RegExp(r'\s+'), ' ') ==
                      normalizedQ,
                  orElse: () => MapEntry("", ""),
                );

                print("Mapped Key for '$normalizedQ': '${entry.key}'");
                return entry.key.isNotEmpty ? entry.key : null;
              })
              .whereType<String>()
              .toList();
        }

        qualificationSearchController.text = selectedQualifications.join(", ");
      });

      print("Fetched Qualifications: ${widget.profile.qualification}");
      print("Parsed Selected Qualifications: $selectedQualifications");
    } catch (e) {
      print("Error fetching user details: $e");
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

      professionError = (selectedProfession == null || selectedProfession!.trim().isEmpty)
    ? "Select Profession"
    : null;

salaryError = (selectedSalaryRange == null || selectedSalaryRange!.trim().isEmpty)
    ? "Select Salary Range"
    : null;

    });

    if (qualificationError == null &&
        specialisationError == null &&
        professionError == null && salaryError == null) {

      String? updatedSalaryRange = selectedSalaryRange ?? widget.profile.salary;

      String? updatedProfession = selectedProfession != null
          ? professionMap[selectedProfession]
          : widget.profile.occupation;

      List<String> qualificationIDs = selectedQualifications
          .map((q) => qualificationMap[q] ?? "")
          .where((id) => id.isNotEmpty)
          .toList();

      List<String> specialisationIDs = selectedSpecialisations
          .map((q) => specialisationMap[q] ?? "")
          .where((id) => id.isNotEmpty)
          .toList();

      print('Sending qualifications: $qualificationIDs');

      bool success = await ApiService.updateEducationDetails(context,
        matriID: widget.profile.matriId,
        id: widget.profile.id,
        qualification: qualificationIDs.join(", "),
        specialization: specialisationIDs.join(", "),
        profession: updatedProfession,
        companyName: companyNameController.text,
        companyCity: companyCityController.text,
        salaryRange: updatedSalaryRange,
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage1(),
          ),
        );
      } else {
        print("Failed to update details");
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
                      labelStyle: TextStyle(color: Color(0xFFC3A38C)),
                      border: OutlineInputBorder(),
                      errorText: qualificationError,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFC3A38C),
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
                      labelStyle: TextStyle(color: Color(0xFFC3A38C)),
                      border: OutlineInputBorder(),
                      errorText: specialisationError,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFC3A38C),
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
              buildTextField(localizations.translate('company_name'), companyNameController),
              buildTextField(localizations.translate('company_city'), companyCityController),
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
              customElevatedButton(validateAndProceed, localizations.translate('submit')),
            ],
          ),
        ),
      ),
    );
  }
}
