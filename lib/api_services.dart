import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice/dashboard_model.dart';
import 'package:practice/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_models.dart';

class ApiService {
  static const String _baseUrl = "https://www.sharutech.com/matrimony";
  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
  };
 static Future<http.Response> _post(
      BuildContext context, String endpoint, Map<String, dynamic> body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.post(
      Uri.parse("$_baseUrl/$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      _handleSessionExpiry(context);
    }

    return response;
  }

 static void _handleSessionExpiry(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Session Expired"),
        content: const Text("Please login again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

static Future<bool> updateProfile(
  BuildContext context, {
  String? matriID,
  String? maritalStatus,
  String? subCaste,
}) async {
  try {
  
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');
    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    Map<String, dynamic> requestBody = {
      "type": "basic_data",
      "matri_id": matriId1,
      "marital_status": maritalStatus,
      "sub_caste": subCaste,
    };

    debugPrint("Sending API Request: ${jsonEncode(requestBody)}");

    final response = await _post(context, "update_profile.php", requestBody);

    debugPrint("API Response Code: ${response.statusCode}");
    debugPrint("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);

      final newToken = decodedJson["newToken"] ?? decodedJson["token"];
      if (newToken != null) {
        await prefs.setString("token", newToken);
        debugPrint("Token updated after profile update");
      }

      if (decodedJson["message"] != null &&
          decodedJson["message"]["p_out_mssg_flg"] == "Y") {
        debugPrint(decodedJson["message"]["p_out_mssg"]);
        return true;
      } else {
        debugPrint("Update failed: ${decodedJson["message"]}");
        return false;
      }
    } else {
      throw Exception("Failed to update profile. Status: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error updating profile: $e");
    return false;
  }
}

 static Future<bool> updateEducationDetails(
  BuildContext context, {
  String? matriID,
  String? id,
  String? qualification,
  String? specialization,
  String? profession,
  String? companyName,
  String? companyCity,
  String? salaryRange,
}) async {
  try {
   
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');
    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    Map<String, dynamic> requestBody = {
      "type": "education",
      "matri_id": matriId1,
      "id": id,
      "qualification": qualification,
      "specialization": specialization,
      "profession": profession,
      "company_name": companyName,
      "company_city": companyCity,
      "salary_range": salaryRange,
    };

    debugPrint("Sending API Request: ${jsonEncode(requestBody)}");

  
    final response = await _post(context, "update_profile.php", requestBody);

    debugPrint("API Response Code: ${response.statusCode}");
    debugPrint("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);

      final newToken = decodedJson["newToken"] ?? decodedJson["token"];
      if (newToken != null) {
        await prefs.setString("token", newToken);
        debugPrint("Token updated after education details update");
      }

      if (decodedJson["message"] != null &&
          decodedJson["message"]["p_out_mssg_flg"] == "Y") {
        debugPrint(decodedJson["message"]["p_out_mssg"]);
        return true;
      } else {
        debugPrint("Update failed: ${decodedJson["message"]}");
        return false;
      }
    } else {
      throw Exception(
          "Failed to update education details. Status: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error updating education details: $e");
    return false;
  }
}

 static Future<bool> updateHoroscopeDetails(
  BuildContext context, {
  String? matriID,
  String? id,
  String? rashi,
  String? nakshatra,
  String? sunSign,
  String? birthTime,
  String? birthPlace,
  String? horoscope,
  String? gothra,
  String? familyDiety,
}) async {
  try {
   
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');
    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    Map<String, dynamic> requestBody = {
      "type": "horoscope",
      "matri_id": matriId1,
      "id": id,
      "rashi": rashi,
      "nakshatra": nakshatra,
      "sun_sign": sunSign,
      "birth_time": birthTime,
      "birth_place": birthPlace,
      "horoscope": horoscope,
      "gothra": gothra,
      "family_diety": familyDiety,
    };

    debugPrint("Sending API Request: ${jsonEncode(requestBody)}");

    final response = await _post(context, "update_profile.php", requestBody);

    debugPrint("API Response Code: ${response.statusCode}");
    debugPrint("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);

      final newToken = decodedJson["newToken"] ?? decodedJson["token"];
      if (newToken != null) {
        await prefs.setString("token", newToken);
        debugPrint("Token updated after horoscope details update");
      }

      if (decodedJson["message"] != null &&
          decodedJson["message"]["p_out_mssg_flg"] == "Y") {
        debugPrint(decodedJson["message"]["p_out_mssg"]);
        return true;
      } else {
        debugPrint("Update failed: ${decodedJson["message"]}");
        return false;
      }
    } else {
      throw Exception(
          "Failed to update horoscope details. Status: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error updating horoscope details: $e");
    return false;
  }
}


static Future<bool> updateFamilyDetails(
  BuildContext context, {
  String? matriID,
  String? id,
  String? fatherName,
  String? motherName,
  String? fatherLivingStatus,
  String? motherLivingStatus,
  String? fatherOccupation,
  String? motherOccupation,
  String? numberOfBrothers,
  String? numberOfSisters,
  String? numberOfMarriedBrothers,
  String? numberOfMarriedSisters,
  String? referenceNumber,
  String? reference,
  String? place,
  String? familyType,
  String? kidsCount,
  String? motherTongue,
}) async {
  try {
   
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');
    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    Map<String, dynamic> requestBody = {
      "type": "family_details",
      "matri_id": matriId1,
      "id": id,
      "kids_count": kidsCount,
      "father_name": fatherName,
      "mother_name": motherName,
      "father_living_status": fatherLivingStatus,
      "mother_living_status": motherLivingStatus,
      "father_ocupation": fatherOccupation,
      "mother_occupation": motherOccupation,
      "number_of_brothers": numberOfBrothers,
      "number_of_sisters": numberOfSisters,
      "number_married_brother": numberOfMarriedBrothers,
      "number_of_married_sister": numberOfMarriedSisters,
      "reference_number": referenceNumber,
      "reference": reference,
      "place": place,
      "family_type": familyType,
      "mother_tongue": motherTongue,
    };

    debugPrint("Sending API Request: ${jsonEncode(requestBody)}");

    final response = await _post(context, "update_profile.php", requestBody);

    debugPrint("API Response Code: ${response.statusCode}");
    debugPrint("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);

      final newToken = decodedJson["newToken"] ?? decodedJson["token"];
      if (newToken != null) {
        await prefs.setString("token", newToken);
        debugPrint("Token updated after family details update");
      }

      if (decodedJson["message"] != null &&
          decodedJson["message"]["p_out_mssg_flg"] == "Y") {
        debugPrint(decodedJson["message"]["p_out_mssg"]);
        return true;
      } else {
        debugPrint("Update failed: ${decodedJson["message"]}");
        return false;
      }
    } else {
      throw Exception(
          "Failed to update family details. Status: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error updating family details: $e");
    return false;
  }
}


  static Future<List<searchsubcaste>> fetchSubCaste(String casteId) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/get_data.php"),
        headers: _headers,
        body: jsonEncode({
          "type": "sub_caste",
          "caste_id": "1",
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return SubCaste.fromJson(data).dataout;
      } else {
        throw Exception("Failed to load sub castes");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  static Future<List<MotherTongueItem>> fetchMotherTongue() async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/get_data.php"),
        headers: _headers,
        body: jsonEncode({"type": "mother_tongue"}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MotherTongue.fromJson(data).dataout;
      } else {
        throw Exception("Failed to load mother tongue");
      }
    } catch (e) {
      throw Exception("Error fetching mother tongue: $e");
    }
  }

  static Future<List<EducationItems>> fetchEducations() async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/get_data.php"),
        headers: _headers,
        body: jsonEncode({"type": "education"}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Educations.fromJson(data).dataout;
      } else {
        throw Exception("Failed to load education");
      }
    } catch (e) {
      throw Exception("Error fetching education: $e");
    }
  }

  static Future<List<EducationItems>> fetchSpecialisations() async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/get_data.php"),
        headers: _headers,
        body: jsonEncode({"type": "education"}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Educations.fromJson(data).dataout;
      } else {
        throw Exception("Failed to load education");
      }
    } catch (e) {
      throw Exception("Error fetching education: $e");
    }
  }

  static Future<List<OccupationItems>> fetchOccupation() async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/get_data.php"),
        headers: _headers,
        body: jsonEncode({"type": "occupation"}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Occupations.fromJson(data).dataout;
      } else {
        throw Exception("Failed to load occupation");
      }
    } catch (e) {
      throw Exception("Error fetching occupation: $e");
    }
  }

  static Future<bool> registredEducationDetails({
    String? matriID,
    String? id,
    String? qualification,
    String? specialization,
    String? profession,
    String? companyName,
    String? companyCity,
    String? salaryRange,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        "type": "education",
        "matri_id": matriID,
        "id": id,
        "qualification": qualification,
        "specialization": specialization,
        "profession": profession,
        "company_name": companyName,
        "company_city": companyCity,
        "salary_range": salaryRange,
      };

      print("Sending API Request: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse("$_baseUrl/sign_in.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("API Response Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["message"]["p_out_mssg_flg"] == "Y";
      } else {
        print("Failed to save education details: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error saving education details: $e");
      return false;
    }
  }

  static Future<bool> validatePhoneNumber(String phoneNumber) async {
    print("Checking phone number: $phoneNumber");
    final response = await http.post(
      Uri.parse("$_baseUrl/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user": phoneNumber,
        "category": "register",
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("p_out_mssg_flg: ${data["message"]["p_out_mssg_flg"]}");
      return data["message"]["p_out_mssg_flg"] ==
          "Y"; 
    }
    return false;
  }

  static Future<String?> generateOTP(String phoneNumber) async {
    final url = Uri.parse("$_baseUrl/send_sms.php");

    final response = await http.post(
      url,
      body: jsonEncode({"type": "otp", "number": phoneNumber}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData["message"]["p_out_mssg_flg"] == "Y") {
        // Extract OTP safely
        String? otp = responseData["data"]?["Otp"];
        print(otp);

        if (otp != null) {
          // String encryptedOTP = md5.convert(utf8.encode(otp)).toString();
          return otp;
        } else {
          print("Error: OTP not found in response data.");
        }
      } else {
        print("Error: ${responseData["message"]["p_out_mssg"]}");
      }
    } else {
      print(
          "Error: Failed to send request. Status Code: ${response.statusCode}");
    }

    return null;
  }

  static Future<Map<String, String>?> registeredPersonalDetails({
  String? maritalStatus,
  String? profileCreator,
  String? profileFor,
  String? firstName,
  String? lastName,
  String? password,
  String? phone,
  String? email,
  String? dob,
  String? gender,
  String? subCaste,
  String? creatorName,
  String? creatorPhone,
}) async {
  try {
    Map<String, dynamic> requestBody = {
      "type": "sign_in",
      "marital_status": maritalStatus,
      "profile_creator": profileCreator,
      "profile_for": profileFor,
      "first_name": firstName,
      "last_name": lastName,
      "password": password,
      "phone": phone,
      "email": email,
      "dob": dob,
      "gender": gender,
      "sub_caste": subCaste,
      "creator_name": creatorName,
      "creator_phone": creatorPhone,
    };

    print("Sending API Request: ${jsonEncode(requestBody)}");

    final response = await http.post(
      Uri.parse("$_baseUrl/sign_in.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    print("API Response Code: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("API Response: $data");

      if (data["message"]["p_out_mssg_flg"] == "Y") {
        String userId = data["data"][0]["id"].toString(); 
        String matriId = data["data"][0]["matri_id"]; 

        print("Registration success! Matri ID: $matriId, User ID: $userId");

        return {
          "matri_id": matriId,
          "id": userId,
        };
      } else {
        // Return the error message from API
        return {
          "error": data["message"]["p_out_mssg"] ?? "Unknown error occurred"
        };
      }
    } else {
      return {"error": "Server error. Please try again later."};
    }
  } catch (e) {
    print("Error during sign-in: $e");
    return {"error": "Network error. Please check your connection."};
  }
}


  static Future<bool> registeredFamilyDetails({
    String? matriID,
    String? id,
    String? fatherName,
    String? motherName,
    String? fatherOccupation,
    String? motherOccupation,
    String? fatherLivingStatus,
    String? motherLivingStatus,
    String? numberOfBrothers,
    String? numberOfSisters,
    String? numberOfMarriedBrothers,
    String? numberOfMarriedSisters,
    String? referenceNumber,
    String? reference,
    String? place,
    String? motherTongue,
    String? familyType,
    String? noOfKids,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        "type": "family_details",
        "matri_id": matriID,
        "id": id,
        "father_name": fatherName,
        "mother_name": motherName,
        "father_living_status": fatherLivingStatus,
        "mother_living_status": motherLivingStatus,
        "father_ocupation": fatherOccupation,
        "mother_occupation": motherOccupation,
        "number_of_brothers": numberOfBrothers,
        "number_of_sisters": numberOfSisters,
        "number_married_brother": numberOfMarriedBrothers,
        "number_of_married_sister": numberOfMarriedSisters,
        "reference_number": referenceNumber,
        "reference": reference,
        "place": place,
        "mother_tongue": motherTongue,
        "family_type": familyType,
        "kids_count" : noOfKids,
      };

      print("Sending API Request: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse("$_baseUrl/sign_in.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("API Response Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["message"]["p_out_mssg_flg"] == "Y";
      } else {
        print("Failed to save family details: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error saving family details: $e");
      return false;
    }
  }

  static Future<bool> registeredHoroscopeDetails({
    required String id,
    required String matriID,
    required String rashi,
    required String nakshatra,
    required String sunSign,
    required String birthTime,
    required String birthPlace,
    required String horoscope,
    required String gothra,
    required String familyDeity,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        "id": id,
        "matri_id": matriID,
        "type": "horoscope",
        "rashi": rashi,
        "nakshatra": nakshatra,
        "sun_sign": sunSign,
        "birth_time": birthTime,
        "birth_place": birthPlace,
        "horoscope": horoscope,
        "gothra": gothra,
        "family_diety": familyDeity
      };

      print("Sending API Request: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse("$_baseUrl/sign_in.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("API Response Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["message"]["p_out_mssg_flg"] == "Y";
      } else {
        print("Failed to save horoscope details: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error saving horoscope details: $e");
      return false;
    }
  }
}
