import 'package:flutter/material.dart';
import 'package:practice/api_services.dart';
import 'package:practice/dashboard_model.dart';
import 'package:practice/lang.dart';
import 'package:practice/profile_page.dart';
import 'custom_widget.dart';

// import 'package:intl/intl.dart';

class HoroscopeDetailsPage extends StatefulWidget {
  final userprofile profile;

  const HoroscopeDetailsPage({super.key, required this.profile});

  @override
  _HoroscopeDetailsPageState createState() => _HoroscopeDetailsPageState();
}

class _HoroscopeDetailsPageState extends State<HoroscopeDetailsPage> {
  final TextEditingController birthTimeController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();
  final TextEditingController gothraController = TextEditingController();
  final TextEditingController familyDeityController = TextEditingController();

  String? selectedNakshatra;
  String? selectedRashi;
  String? birthTimeError;
  String? birthPlaceError;
  String? nakshatraError;
  String? rashiError;
  String horoscopeController = "1";
  String sunSignController = "6";
   Color appcolor = Color(0xFF8A2727);

  final List<String> nakshatraOptions = [
    "Anuradha",
    "AARIDRA",
    "Ashlesha",
    "Ashwini",
    "Bharani",
    "Chitra",
    "Dhanishta",
    "Hasta",
    "Jyeshtha",
    "Krittika",
    "Magha",
    "Moola",
    "Mrigashira",
    "Punarvasu",
    "Purva Ashadha",
    "Purva Bhadrapada",
    "Purva Phalguni",
    "PUSHYA",
    "Revati",
    "Rohini",
    "Shatabhisha",
    "Shravana",
    "Swati",
    "Uttara Ashadha",
    "Uttara Bhadrapada",
    "Uttara Phalguni",
    "Vishakha"
  ];

  final List<String> rashiOptions = [
    "Dhanu (Sagittarius)",
    "Kanya (Virgo)",
    "Karka (Cancer)",
    "Kumbha (Aquarius)",
    "Makara (Capricorn)",
    "Meena (Pisces)",
    "Mesha (Aries)",
    "Mithuna (Gemini)",
    "Simha (Leo)",
    "Tula (Libra)",
    "Vrischika (Scorpio)",
    "Vrishabha (Taurus)"
  ];

  String? _getNakshatraCode(String? nakshatra) {
    Map<String, String> nakshatraMap = {
      "Anuradha": "1",
      "AARIDRA": "2",
      "Ashlesha": "3",
      "Ashwini": "4",
      "Bharani": "5",
      "Chitra": "6",
      "Dhanishta": "7",
      "Hasta": "8",
      "Jyeshtha": "9",
      "Krittika": "10",
      "Magha": "11",
      "Moola": "12",
      "Mrigashira": "13",
      "Punarvasu": "14",
      "Purva Ashadha": "15",
      "Purva Bhadrapada": "16",
      "Purva Phalguni": "17",
      "PUSHYA": "18",
      "Revati": "19",
      "Rohini": "20",
      "Shatabhisha": "21",
      "Shravana": "22",
      "Swati": "23",
      "Uttara Ashadha": "24",
      "Uttara Bhadrapada": "25",
      "Uttara Phalguni": "26",
      "Vishakha": "27",
    };
    return nakshatraMap[nakshatra];
  }

  String? _getRashiCode(String? rashi) {
    Map<String, String> rashiMap = {
      "Dhanu (Sagittarius)": "1",
      "Kanya (Virgo)": "2",
      "Karka (Cancer)": "3",
      "Kumbha (Aquarius)": "4",
      "Makara (Capricorn)": "5",
      "Meena (Pisces)": "6",
      "Mesha (Aries)": "7",
      "Mithuna (Gemini)": "8",
      "Simha (Leo)": "9",
      "Tula (Libra)": "10",
      "Vrischika (Scorpio)": "11",
      "Vrishabha (Taurus)": "12",
    };
    return rashiMap[rashi];
  }

  @override
  void initState() {
    super.initState();
    fetchProfileDetails();

    birthPlaceController.addListener(() {
      setState(() {
        birthPlaceError = _validateBirthPlace(birthPlaceController.text);
      });
    });
  }

  String? _validateBirthPlace(String birthplace) {
    if (birthplace.isEmpty) {
      return "Enter Birth Place";
    }
    return null;
  }

  Future<void> fetchProfileDetails() async {
    try {
      setState(() {
        birthPlaceController.text = widget.profile.birthPlace;
        birthTimeController.text = widget.profile.birthTime;
        gothraController.text = widget.profile.gothra;
        familyDeityController.text = widget.profile.familyDiety;
        selectedNakshatra = widget.profile.nakshatra;
        selectedRashi = widget.profile.rashi;
      });
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> validateAndProceed() async {
    setState(() {
      birthTimeError =
          birthTimeController.text.isEmpty ? "Select Birth Time" : null;
      birthPlaceError = _validateBirthPlace(birthPlaceController.text);
      nakshatraError = (selectedNakshatra == null || selectedNakshatra!.isEmpty) ? "Select Nakshatra" : null;
    rashiError = (selectedRashi == null || selectedRashi!.isEmpty) ? "Select Rashi" : null;
    
    });

    if (birthTimeError == null && birthPlaceError == null && nakshatraError==null && rashiError==null) {
      String? updatedNakshatra = selectedNakshatra != null
          ? _getNakshatraCode(selectedNakshatra)
          : _getNakshatraCode(widget.profile.nakshatra);

      String? updatedRashi = selectedRashi != null
          ? _getRashiCode(selectedRashi)
          : _getRashiCode(widget.profile.rashi);

      bool success = await ApiService.updateHoroscopeDetails(context,
        matriID: widget.profile.matriId,
        id: widget.profile.id,
        rashi: updatedRashi,
        nakshatra: updatedNakshatra,
        sunSign: sunSignController,
        birthTime: birthTimeController.text,
        birthPlace: birthPlaceController.text,
        horoscope: horoscopeController,
        gothra: gothraController.text,
        familyDiety: familyDeityController.text,
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage1(),
          ),
        );
      } else {
        print("Failed to update horoscope details");
      }
    }
  }

  Widget _buildBirthTime() {
    var localizations = AppLocalizations.of(context);
    return buildTextField(
      localizations.translate('birth_time'),
      birthTimeController,
      readOnly: true,
      onTap: selectTime,
      errorText: birthTimeError,
    );
  }

  Future<void> selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        birthTimeController.text = pickedTime.format(context);
        birthTimeError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          localizations.translate('horoscope'),
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
              buildDropdown(
                  localizations.translate('nakshatra'),
                  nakshatraOptions,
                  selectedNakshatra,
                  (value) => setState(() {
                        selectedNakshatra = value;
                        nakshatraError = null;
                      }),
                  errorText: nakshatraError),
              buildDropdown(
                  localizations.translate('rashi'),
                  rashiOptions,
                  selectedRashi,
                  (value) => setState(() {
                        selectedRashi = value;
                        rashiError = null;
                      }),
                  errorText: rashiError),
              buildTextField(localizations.translate('gothra'), gothraController),
              _buildBirthTime(),
              buildTextField(localizations.translate('birth_place'), birthPlaceController,
                  errorText: birthPlaceError),
              buildTextField(localizations.translate('family_deity'), familyDeityController),
              const SizedBox(height: 20),
              customElevatedButton(validateAndProceed, localizations.translate('submit')),
            ],
          ),
        ),
      ),
    );
  }
}
