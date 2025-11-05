import 'dart:convert';
import 'package:buntsmatrimony/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:buntsmatrimony/chat/chatuser_model.dart';
import 'package:buntsmatrimony/login.dart';
import 'dashboard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search.dart';
import 'package:intl/intl.dart';

class ApiService {
  static const String _baseUrl = "https://www.sharutech.com/matrimony";
  static String get baseUrl => _baseUrl;

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  static Future<http.Response> _post(
    BuildContext context,
    String endpoint,
    Map<String, dynamic> body,
  ) async {
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
                MaterialPageRoute(builder: (_) => AuthScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  static Future<DashboardData> fetchDashboardData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId = prefs.getString('matriId');

    final response = await _post(context, "z_dashboard2.php", {
      "matri_id": matriId,
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData["token"] != null) {
        await prefs.setString("token", jsonData["token"]);
        print("NEw token${jsonData["token"]}");
      }

      return DashboardData.fromJson(jsonData);
    } else {
      throw Exception("Failed to load dashboard data");
    }
  }

  static Future<myProfileData> fetchmyProfileData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId = prefs.getString('matriId');

    final response = await _post(context, "my_profile.php", {
      "matri_id": matriId,
    });

    debugPrint("my_profile status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData["token"] != null) {
        await prefs.setString("token", jsonData["token"]);
        print("My profile token${jsonData["token"]}");
        debugPrint("New token updated (MyProfile)");
      }

      return myProfileData.fromJson(jsonData);
    } else {
      throw Exception(
        "Failed to load profile data. Code: ${response.statusCode}",
      );
    }
  }

 static Future<List<AdditionalImagesData>> fetchAdditionalImages() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId = prefs.getString('matriId');
    String? token = prefs.getString('token');

    if (matriId == null || token == null) {
      throw Exception("Missing matriId or token in SharedPreferences");
    }

    final response = await http.post(
      Uri.parse("$_baseUrl/edit_image.php"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "type": "get_image",
        "matri_id": matriId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

    
      if (jsonData.containsKey('token') && jsonData['token'] != null) {
        await prefs.setString('token', jsonData['token']);
      }

      final List<dynamic>? imagesList = jsonData['dataout'];
      if (imagesList == null) return [];

      return imagesList
          .map((image) => AdditionalImagesData.fromJson(image))
          .toList();
    } 
    else if (response.statusCode == 401) {
   
      throw Exception("Session expired. Please log in again.");
    } 
    else {
      throw Exception("Failed to load additional images: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching additional images: $e");
    rethrow;
  }
}

  //Search Prefernce
  static Future<SearchData> fetchsearchData(
    BuildContext context,
    String matriIdOf,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');

    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    debugPrint("My matr: $matriId1");
    debugPrint("Their matr: $matriIdOf");

    // ✅ Use global _post() (handles 401 + token)
    final response = await _post(context, "z_search_preference2.php", {
      "matri_id": matriId1,
      "matri_id_of": matriIdOf,
      "type": "matri_id",
    });

    debugPrint("API Response (search): ${response.body}");

    if (response.statusCode == 200) {
      try {
        final decodedJson = json.decode(response.body);

        if (decodedJson["token"] != null) {
          await prefs.setString("token", decodedJson["token"]);
          debugPrint("✅ Token updated (Search)");
        }

        if (!decodedJson.containsKey('dataout')) {
          throw Exception("Invalid API response format");
        }

        return await SearchData.fromJsonAsync(decodedJson);
      } catch (e) {
        debugPrint("Error parsing search data: $e");
        throw Exception("Error parsing data");
      }
    } else {
      throw Exception(
        "Failed to load search data. Status: ${response.statusCode}",
      );
    }
  }

  static Future<Map<String, dynamic>> fetchCategory1(
    String page,
    String pageSize,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId1 = prefs.getString('matriId');

      int? selectedMaritalStatus = prefs.getInt("selected_marital_status");
      List<String> selectedSubCasteList =
          prefs.getStringList("selected_sub_caste") ?? [];
      List<String> selectedEducationList =
          prefs.getStringList("selected_education") ?? [];

      double selectedMinAge = prefs.getDouble("selected_min_age") ?? 18.0;
      double selectedMaxAge = prefs.getDouble("selected_max_age") ?? 40.0;
      double selectedMinHeight = prefs.getDouble("selected_min_height") ?? 50.0;
      double selectedMaxHeight =
          prefs.getDouble("selected_max_height") ?? 250.0;
      double selectedIncomeFrom =
          prefs.getDouble("selected_income_from") ?? 0.0;
      double selectedIncomeTo = prefs.getDouble("selected_income_to") ?? 500.0;

      String selectedCountry = prefs.getString("selected_country_id") ?? "";
      String selectedState = prefs.getString("selected_state_id") ?? "";
      String selectedCity = prefs.getString("selected_city_id") ?? "";

      var requestBody = {
        "blood_group": "A+,A-,B+,O-,AB-,AB+,B-,O+",
        "city": selectedCity,
        "country": selectedCountry,
        "state": selectedState,
        "education": selectedEducationList.join(","),
        "height_min": selectedMinHeight.toString(),
        "height_max": selectedMaxHeight.toString(),
        "income_from": selectedIncomeFrom.toString(),
        "income_to": selectedIncomeTo.toString(),
        "limit": "100",
        "marital_status": selectedMaritalStatus != null
            ? selectedMaritalStatus.toString()
            : "",
        "matri_id": matriId1,
        "max_age": selectedMaxAge.toString(),
        "min_age": selectedMinAge.toString(),
        "page_no": page,
        "sub_caste": selectedSubCasteList.join(","),
      };

      print("Request Body: $requestBody");
      String? token = prefs.getString("token");
      final response = await http.post(
        Uri.parse("$_baseUrl/z_search2.php"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('dataout') &&
            responseData['dataout'] != null) {
          List<dynamic> data = responseData['dataout'];
          int rowcount = 0;
          if (page == "1") {
            rowcount =
                int.tryParse(
                  responseData['row_counts'][0]['TOTAL_ROWS']?.toString() ??
                      "0",
                ) ??
                0;
          }
          //print("Result: ${responseData['row_counts'][0]} ");

          return {
            'data': data
                .map((e) => searchcategory1.fromJson(e, _baseUrl))
                .toList(),
            'totalRows': rowcount,
          };
        } else {
          print("API Response Missing 'dataout': $responseData");
          return {'data': [], 'totalRows': 0};
        }
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        return {'data': [], 'totalRows': 0};
      }
    } catch (e) {
      print("Exception in fetchCategory: $e");
      return {'data': [], 'totalRows': 0};
    }
  }

  static Future<String?> _getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url');
  }

  static Future<MatchedData> fetchMatchedProfiles(
    BuildContext context,
    String dataType,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');

    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    final response = await _post(context, "z_matri_liked2.php", {
      "matri_id": matriId1,
      "type": dataType,
    });

    debugPrint("API Response (matched): ${response.body}");

    if (response.statusCode == 200) {
      try {
        final decodedJson = json.decode(response.body);

        if (decodedJson["token"] != null) {
          await prefs.setString("token", decodedJson["token"]);
          debugPrint(" Token updated (Matched Profiles)");
        }

        if (!decodedJson.containsKey('dataout')) {
          throw Exception("Invalid API response format");
        }

        String baseUrl = await matchedprofile.getBaseUrl() ?? "";
        return MatchedData.fromJson(decodedJson, baseUrl);
      } catch (e) {
        debugPrint("Error parsing matched profiles: $e");
        throw Exception("Error parsing matched data");
      }
    } else {
      throw Exception(
        "Failed to load matched profiles. Status: ${response.statusCode}",
      );
    }
  }

  static Future<MatchedData> fetchContactedProfiles(
    BuildContext context,
    String dataType,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');

    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    final response = await _post(context, "z_contacted_profile2.php", {
      "matri_id": matriId1,
      "type": dataType,
    });

    debugPrint("API Response (contacted): ${response.body}");

    if (response.statusCode == 200) {
      try {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint("Token updated (Contacted Profiles)");
        }

        if (!decodedJson.containsKey('dataout')) {
          throw Exception("Invalid API response format");
        }

        String baseUrl = await matchedprofile.getBaseUrl() ?? "";
        return MatchedData.fromJson(decodedJson, baseUrl);
      } catch (e) {
        debugPrint("Error parsing contacted profiles: $e");
        throw Exception("Error parsing contacted data");
      }
    } else {
      throw Exception(
        "Failed to load contacted profiles. Status: ${response.statusCode}",
      );
    }
  }

  static Future<MatchedData> fetchViewedProfiles(
    BuildContext context,
    String dataType,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');

    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    // ✅ Use global _post() (handles 401 + token expiry)
    final response = await _post(context, "z_profile_viewed2.php", {
      "matri_id": matriId1,
      "type": dataType,
    });

    debugPrint("API Response (viewed): ${response.body}");

    if (response.statusCode == 200) {
      try {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          print("New toke in profil view${newToken}");
          debugPrint("Token updated (Viewed Profiles)");
        }

        if (!decodedJson.containsKey('dataout')) {
          throw Exception("Invalid API response format");
        }

        String baseUrl = await matchedprofile.getBaseUrl() ?? "";
        return MatchedData.fromJson(decodedJson, baseUrl);
      } catch (e) {
        debugPrint("Error parsing viewed profiles: $e");
        throw Exception("Error parsing viewed data");
      }
    } else {
      throw Exception(
        "Failed to load viewed profiles. Status: ${response.statusCode}",
      );
    }
  }

  static Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse("$_baseUrl/users"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((user) => User.fromJson(user, _baseUrl)).toList();
    } else {
      throw Exception("Failed to load users");
    }
  }

  static Future<Map<String, dynamic>> loginUser(
    String mobile,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user": mobile, "password": password}),
    );

    print("Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Parsed Response: $jsonResponse");

        final dataOut = jsonResponse["dataout"][0];
        final token = dataOut["token"];

        final parts = token.split('.');
        if (parts.length != 3) {
          throw Exception("Invalid JWT token format");
        }

        final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );

        final data = payload["data"];
        final int id = data["id"] ?? 0;
        final String matriId = data["matri_id"] ?? '';
        final String phone = data["phone"].toString();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setInt("id", id);
        await prefs.setString("matriId", matriId);
        await prefs.setString("phone", phone);

        print("Extracted ID: $id");
        print("Extracted Matri ID: $matriId");
        print("Extracted Phone: $phone");

        return {"id": id, "matri_id": matriId, "phone": phone, "token": token};
      } catch (e) {
        throw Exception("Error decoding response: $e");
      }
    } else {
      throw Exception("Login failed with status code: ${response.statusCode}");
    }
  }

  // Check Phone number

  static Future<Map<String, dynamic>> checkNumber(String number) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user": number}),
    );

    print("Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Parsed Response: $jsonResponse");
        return jsonResponse;
      } catch (e) {
        throw Exception("Invalid JSON response: ${response.body}");
      }
    } else {
      throw Exception(
        "API call failed with status code: ${response.statusCode}",
      );
    }
  }

  static Future<Map<String, dynamic>> loginEntry(String matri_id) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "category": "login_details",
        "matri_id": matri_id,
        "device": "MOBILE",
      }),
    );

    print("Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Parsed Response: $jsonResponse");
        return jsonResponse;
      } catch (e) {
        throw Exception("Invalid JSON response: ${response.body}");
      }
    } else {
      throw Exception(
        "API call failed with status code: ${response.statusCode}",
      );
    }
  }

  //Send OTP
  static Future<Map<String, dynamic>> SendOtp(String number) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/send_sms.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"number": number, "type": "otp"}),
    );

    print("Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Parsed Response: $jsonResponse");
        return jsonResponse;
      } catch (e) {
        throw Exception("Invalid JSON response: ${response.body}");
      }
    } else {
      throw Exception(
        "API call failed with status code: ${response.statusCode}",
      );
    }
  }

  //Send OTP
  static Future<Map<String, dynamic>> getInappProduct(String platform) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/get_data.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"type": 'Inapp_plan', "gateway": platform}),
    );

    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        print("Parsed Response: $jsonResponse");
        return jsonResponse;
      } catch (e) {
        throw Exception("Invalid JSON response: ${response.body}");
      }
    } else {
      throw Exception(
        "API call failed with status code: ${response.statusCode}",
      );
    }
  }

  //New Password
  static Future<Map<String, dynamic>> updatePassword(
    String matriId,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "matri_id": matriId,
        "category": "password",
        "password": password,
      }),
    );

    print("Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Parsed Response: $jsonResponse");
        return jsonResponse;
      } catch (e) {
        throw Exception("Invalid JSON response: ${response.body}");
      }
    } else {
      throw Exception(
        "API call failed with status code: ${response.statusCode}",
      );
    }
  }

  //Profile View
  static Future<ProfileViewData> fetchProfileViewData(
    BuildContext context,
    String matriIdTo,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');

    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    debugPrint("My Matri ID: $matriId1");
    debugPrint("Viewed Matri ID: $matriIdTo");

    final response = await _post(context, "z_my_profile2.php", {
      "matri_id": matriId1,
      "matri_id_to": matriIdTo,
    });

    debugPrint("API Response (profile view): ${response.body}");

    if (response.statusCode == 200) {
      try {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint("✅ Token updated (Profile View)");
        }

        if (!decodedJson.containsKey('dataout')) {
          throw Exception("Invalid API response format");
        }

        return ProfileViewData.fromJson(decodedJson);
      } catch (e) {
        debugPrint("Error parsing profile view data: $e");
        throw Exception("Error parsing profile view data");
      }
    } else {
      throw Exception(
        "Failed to load profile view data. Status: ${response.statusCode}",
      );
    }
  }

  //Sub Caste dropdown ge

  // static Future<List<searchsubcaste>> fetchsearchsubcaste() async {

  static Future<List<searchsubcaste>> fetchsearchsubcaste() async {
    final response = await http.post(
      Uri.parse("$_baseUrl/get_data.php"),
      headers: _headers,
      body: jsonEncode({"type": "sub_caste", "caste_id": "1"}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['dataout'];
      return data.map((e) => searchsubcaste.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load subcaste data");
    }
  }

  //Education
  static Future<List<searcheducation>> fetcheducation() async {
    final response = await http.post(
      Uri.parse("$_baseUrl/get_data.php"),
      headers: _headers,
      body: jsonEncode({"type": "education"}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['dataout'];
      return data.map((e) => searcheducation.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load subcaste data");
    }
  }

  //Country
  static Future<List<searchcountry>> fetchcountry() async {
    final response = await http.post(
      Uri.parse("$_baseUrl/country_state_city.php"),
      headers: _headers,
      body: jsonEncode({"type": "country"}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((e) => searchcountry.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load subcaste data");
    }
  }

  static Future<List<ChatUser>> fetchChatMessage(String matriIdBy) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId = prefs.getString('matriId');
    final response = await http.post(
      Uri.parse("$_baseUrl/message.php"),
      headers: _headers,
      body: jsonEncode({
        "type": "messages",
        "matri_id_by": matriIdBy,
        "matri_id_to": matriId,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['dataout'];
      return data.map((e) => ChatUser.fromJson(e, _baseUrl)).toList();
    } else {
      throw Exception("Failed to load state data");
    }
  }

  static Future<List<ChatUser>> fetchChatUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId = prefs.getString('matriId');
    String? token = prefs.getString("token");
    final response = await http.post(
      Uri.parse("$_baseUrl/message.php"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"type": "chat_list", "matri_id": matriId}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['dataout'];
      return data.map((e) => ChatUser.fromJson(e, _baseUrl)).toList();
    } else {
      throw Exception("Failed to load state data");
    }
  }

  static Future<List<Messages>> fetchChats(String reciverId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId = prefs.getString('matriId');
    String? token = prefs.getString("token");
    final response = await http.post(
      Uri.parse("$_baseUrl/message.php"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "type": "messages",
        "matri_id_by": matriId,
        "matri_id_to": reciverId,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['dataout'];
      return data.map((e) => Messages.fromJson(e, _baseUrl)).toList();
    } else {
      throw Exception("Failed to load state data");
    }
  }

  static Future<String> initateChats(String reciverId, String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId = prefs.getString('matriId');
    String? token = prefs.getString("token");
    final response = await http.post(
      Uri.parse("$_baseUrl/message.php"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "type": "chat_initated",
        "matri_id_by": matriId,
        "matri_id_to": reciverId,
        "message": message,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["message"]["p_out_mssg_flg"] == "Y") {
        return "Y";
      } else if (data["message"]["p_out_mssg_flg"] == "N") {
        if (data["message"]["p_out_mssg"] == 'Max count') {
          return "Max";
        } else {
          return "N";
        }
      } else {
        return "N";
      }
    } else {
      throw Exception("Failed to load state data");
    }
  }

  //State

  static Future<List<searchstate>> fetchstate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedCountryId = prefs.getString("selected_country_id") ?? "";

    print(
      "Fetching states for Country ID: $selectedCountryId",
    ); // Debugging log

    final response = await http.post(
      Uri.parse("$_baseUrl/country_state_city.php"),
      headers: _headers,
      body: jsonEncode({
        "type": "state",
        "country": selectedCountryId, // Correctly pass the stored country ID
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((e) => searchstate.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load state data");
    }
  }

  //City
  static Future<List<searchcity>> fetchcity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedCountryId = prefs.getString("selected_country_id") ?? "";
    String? selectedStateId = prefs.getString("selected_state_id") ?? "";

    final response = await http.post(
      Uri.parse("$_baseUrl/country_state_city.php"),
      headers: _headers,
      body: jsonEncode({
        "type": "city",
        "country": selectedCountryId,
        "state": selectedStateId,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((e) => searchcity.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load state data");
    }
  }

  static Future<List<searchcategory>> fetchcategory(
    BuildContext context,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');

    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    // 🔹 Retrieve filter values from prefs
    List<String> selectedSubCasteList =
        prefs.getStringList("selected_sub_caste") ?? [];
    List<String> selectedEducationList =
        prefs.getStringList("selected_education") ?? [];
    int selectedMaritalStatus = prefs.getInt("selected_marital_status") ?? 1;
    double selectedMinAge = prefs.getDouble("selected_min_age") ?? 18.0;
    double selectedMaxAge = prefs.getDouble("selected_max_age") ?? 40.0;
    double selectedMinheight = prefs.getDouble("selected_min_height") ?? 50.0;
    double selectedMaxheight = prefs.getDouble("selected_max_height") ?? 250.0;

    searchcountry selectedCountry = searchcountry(
      country_id: prefs.getString("selected_country_id") ?? "",
      country_name: prefs.getString("selected_country_name") ?? "",
      country_code: "",
    );

    searchstate selectedState = searchstate(
      state_id: prefs.getString("selected_state_id") ?? "",
      state_name: prefs.getString("selected_state_name") ?? "",
      state_code: "",
      country_id: "",
    );

    searchcity selectedCity = searchcity(
      city_id: prefs.getString("selected_city_id") ?? "",
      city_name: prefs.getString("selected_city_name") ?? "",
      state_id: "",
      country_id: "",
    );

    final Map<String, dynamic> requestBody = {
      "matri_id": matriId1,
      "marital_status": selectedMaritalStatus,
      "sub_caste": selectedSubCasteList.join(","),
      "city": selectedCity.city_id,
      "country": selectedCountry.country_id,
      "state": selectedState.state_id,
      "education": selectedEducationList.join(","),
      "height_min": selectedMinheight,
      "height_max": selectedMaxheight,
      "min_age": selectedMinAge,
      "max_age": selectedMaxAge,
      "income_from": "",
      "income_to": "",
    };

    debugPrint("🔹 Search Preference Request Body: $requestBody");

    final response = await _post(
      context,
      "z_search_preference2.php",
      requestBody,
    );

    debugPrint("🔹 API Response (Search Category): ${response.body}");

    if (response.statusCode == 200) {
      try {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint("Token updated (Search Category)");
        }

        if (!decodedJson.containsKey('dataout')) {
          throw Exception("Invalid API response format (missing 'dataout')");
        }

        final List<dynamic> dataList = decodedJson['dataout'] ?? [];
        //String baseUrl = await searchcategory.getBaseUrl() ?? "";

        return dataList
            .map((e) => searchcategory.fromJson(e, baseUrl))
            .toList();
      } catch (e) {
        debugPrint(" Error parsing Search Category: $e");
        throw Exception("Error parsing Search Category");
      }
    } else {
      throw Exception(
        "Failed to load search categories. Status: ${response.statusCode}",
      );
    }
  }

  //Partner Preference

  static Future<List<searchpartner>> fetchpartner() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriIdnew = prefs.getString("matri_id_new");

      List<String> selectedSubCasteList =
          prefs.getStringList("selected_sub_caste") ?? [];
      List<String> selectedEducationList =
          prefs.getStringList("selected_education") ?? [];
      int selectedMaritalStatus = prefs.getInt("selected_marital_status") ?? 1;
      double selectedMinAge = prefs.getDouble("selected_min_age") ?? 18.0;
      double selectedMaxAge = prefs.getDouble("selected_max_age") ?? 40.0;
      double selectedMinheight = prefs.getDouble("selected_min_height") ?? 50.0;
      double selectedMaxheight =
          prefs.getDouble("selected_max_height") ?? 250.0;
      double selectedIncome = prefs.getDouble("selected_income") ?? 10.0;

      searchcountry selectedCountry = searchcountry(
        country_id: prefs.getString("selected_country_id") ?? "",
        country_name: prefs.getString("selected_country_name") ?? "",
        country_code: "",
      );

      searchstate selectedState = searchstate(
        state_id: prefs.getString("selected_state_id") ?? "",
        state_name: prefs.getString("selected_state_name") ?? "",
        state_code: "",
        country_id: "",
      );

      searchcity selectedCity = searchcity(
        city_id: prefs.getString("selected_city_id") ?? "",
        city_name: prefs.getString("selected_city_name") ?? "",
        state_id: "",
        country_id: "",
      );

      // 🔹 Prepare request body
      Map<String, dynamic> requestBody = {
        "height_min": selectedMinheight,
        "height_max": selectedMaxheight,
        "matri_id": matriIdnew,
        "marital_status": selectedMaritalStatus,
        "sub_caste": selectedSubCasteList.join(","),
        "city": selectedCity.city_id,
        "country": selectedCountry.country_id,
        "state": selectedState.state_id,
        "education": selectedEducationList.join(","),
        "min_age": selectedMinAge,
        "max_age": selectedMaxAge,
      };

      debugPrint("Sending API Request: ${jsonEncode(requestBody)}");

      // 🔹 Make API call (no Authorization header required)
      final response = await http.post(
        Uri.parse("$_baseUrl/search_preference.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      debugPrint("API Response Code: ${response.statusCode}");
      debugPrint("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // 🔹 Store token if present inside dataout[0]
        if (responseData.containsKey('dataout') &&
            responseData['dataout'] is List &&
            responseData['dataout'].isNotEmpty) {
          final firstItem = responseData['dataout'][0];
          final token = firstItem["token"];
          if (token != null) {
            await prefs.setString("token", token);
            debugPrint("Token stored after fetchpartner()");
          }
        }

        // 🔹 Parse partner list
        if (responseData.containsKey('dataout') &&
            responseData['dataout'] != null) {
          final List<dynamic> data = responseData['dataout'];
          return data.map((e) => searchpartner.fromJson(e, baseUrl)).toList();
        } else {
          debugPrint(
            "API response missing 'dataout' key or null: $responseData",
          );
          return [];
        }
      } else {
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Exception in fetchpartner: $e");
      return [];
    }
  }

  //Images
 static Future<List<searchimages>> fetchimages(String matriIdTo) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      throw Exception("Token not found. Please log in again.");
    }

    final response = await http.post(
      Uri.parse("$_baseUrl/edit_image.php"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "type": "get_image",
        "matri_id": matriIdTo,
      }),
    );

    print("API Response Code: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

     
      if (jsonData["token"] != null) {
        await prefs.setString("token", jsonData["token"]);
        await prefs.setString("token_expiry", jsonData["token_expiry"]);
      }

      final List<dynamic> data = jsonData["dataout"] ?? [];
     return await searchimages.fromJsonList(data);
    } else if (response.statusCode == 401) {
      throw Exception("Session expired. Please log in again.");
    } else {
      throw Exception("Failed to load image data. (${response.statusCode})");
    }
  } catch (e) {
    print("Error fetching images: $e");
    return [];
  }
}


  static Future<ShortlistData> fetchShortlistedProfiles(
    BuildContext context,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');

    if (matriId1 == null) {
      throw Exception("Matri ID not found in SharedPreferences");
    }

    final response = await _post(context, "z_shortlisted2.php", {
      "matri_id": matriId1,
      "type": "listed",
    });

    debugPrint(" API Response (Shortlisted): ${response.body}");

    if (response.statusCode == 200) {
      try {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint("✅ Token updated (Shortlisted Profiles)");
        }

        if (!decodedJson.containsKey('dataout')) {
          throw Exception("Invalid API response format — 'dataout' missing");
        }

        return ShortlistData.fromJson(decodedJson, _baseUrl);
      } catch (e) {
        debugPrint(" Error parsing Shortlisted profiles: $e");
        throw Exception("Error parsing shortlisted data");
      }
    } else {
      throw Exception(
        "Failed to load shortlisted profiles. Status: ${response.statusCode}",
      );
    }
  }

  //BLock or report

  static Future<Block> fetchBlockData(String matriIdTo, String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? mobile = prefs.getString("mobile") ?? "";
    String? matriId1 = prefs.getString('matriId');
    String? token = prefs.getString("token");
    final response = await http.post(
      Uri.parse("$_baseUrl/block_user.php"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "matri_id_by": matriId1,
        "matri_id_to": matriIdTo,
        "user_comment": comment,
        "type": "block", // You can adjust this if you need it to be dynamic
      }),
    );

    if (response.statusCode == 200) {
      debugPrint("status code 200");
      return Block.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load profile data");
    }
  }

  static Future<bool> updateAdditionalDetails(
    BuildContext context, {
    String? matriID,
    String? id,
    String? height,
    String? weight,
    String? bloodGroup,
    String? complexion,
    String? country,
    String? state,
    String? city,
    String? disability,
    String? address,
    String? remark,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId1 = prefs.getString('matriId');
      if (matriId1 == null) {
        throw Exception("Matri ID not found in SharedPreferences");
      }

      // Prepare request body
      Map<String, dynamic> requestBody = {
        "type": "physical_attributes",
        "matri_id": matriId1,
        "id": id,
        "height": height,
        "weight": weight,
        "blood_group": bloodGroup,
        "complexion": complexion,
        "country": country,
        "state": state,
        "city": city,
        "disability": disability,
        "address": address,
        "remark": remark,
      };

      debugPrint("Sending API Request: ${jsonEncode(requestBody)}");

      final response = await _post(context, "update_profile.php", requestBody);

      debugPrint("API Response Code: ${response.statusCode}");
      debugPrint("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);

        // 🔹 Save new token if received
        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint("Token updated after additional details update");
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
          "Failed to update additional details. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Error updating additional details: $e");
      return false;
    }
  }

  //register additional details:

  static Future<bool> registeredAdditionalDetails({
    String? matriID,
    String? id,
    String? height,
    String? weight,
    String? bloodGroup,
    String? complexion,
    String? country,
    String? state,
    String? city,
    String? disability,
    String? address,
    String? remark,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        "type": "physical_attributes",
        "matri_id": matriID,
        "id": id,
        "height": height,
        "weight": weight,
        "blood_group": bloodGroup,
        "complexion": complexion,
        "country": country,
        "state": state,
        "city": city,
        "disability": disability,
        "address": address,
        "remark": remark,
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
        print("Failed to save additional details: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error saving additional details: $e");
      return false;
    }
  }

  //Shortlist Add
  static Future<AddShortlist> fetchAddShortlistData(
    BuildContext context,
    String matriIdTo,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId1 = prefs.getString('matriId');

      if (matriId1 == null) {
        throw Exception("Matri ID not found in SharedPreferences");
      }

      final response = await _post(context, "shortlisted.php", {
        "matri_id_by": matriId1,
        "matri_id_to": matriIdTo,
        "type": "shortlisted",
      });

      debugPrint(" API Response (Add Shortlist): ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint("Token updated (Add Shortlist)");
        }

        if (!decodedJson.containsKey('message')) {
          throw Exception("Invalid API response format — 'message' missing");
        }

        return AddShortlist.fromJson(decodedJson);
      } else {
        throw Exception(
          "Failed to add shortlist. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(" Error adding shortlist: $e");
      rethrow;
    }
  }

  //Remove Shortlist

  static Future<RemoveShortlist> fetchRemoveShortlistData(
    BuildContext context,
    String matriIdTo,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId1 = prefs.getString('matriId');

      if (matriId1 == null) {
        throw Exception("Matri ID not found in SharedPreferences");
      }

      final response = await _post(context, "shortlisted.php", {
        "matri_id_by": matriId1,
        "matri_id_to": matriIdTo,
        "type": "unlist",
      });

      debugPrint("🔹 API Response (Remove Shortlist): ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint(" Token updated (Remove Shortlist)");
        }

        if (!decodedJson.containsKey('message')) {
          throw Exception("Invalid API response format — 'message' missing");
        }

        return RemoveShortlist.fromJson(decodedJson);
      } else {
        throw Exception(
          "Failed to remove shortlist. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(" Error removing shortlist: $e");
      rethrow;
    }
  }

  //Add like

  static Future<Addlike> fetchAddlikeData(
    BuildContext context,
    String matriIdTo,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId1 = prefs.getString('matriId');

      if (matriId1 == null) {
        throw Exception("Matri ID not found in SharedPreferences");
      }

      final response = await _post(context, "matri_liked.php", {
        "matri_id_by": matriId1,
        "matri_id_to": matriIdTo,
        "type": "liked",
      });

      debugPrint("🔹 API Response (Add Like): ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint("Token updated (Add Like)");
        }

        if (!decodedJson.containsKey('message')) {
          throw Exception("Invalid API response format — 'message' missing");
        }

        return Addlike.fromJson(decodedJson);
      } else {
        throw Exception(
          "Failed to like profile. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(" Error adding like: $e");
      rethrow;
    }
  }

  //Remiove Like

  static Future<Removelike> fetchRemovelikeData(
    BuildContext context,
    String matriIdTo,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId1 = prefs.getString('matriId');

      if (matriId1 == null) {
        throw Exception("Matri ID not found in SharedPreferences");
      }

      final response = await _post(context, "matri_liked.php", {
        "matri_id_by": matriId1,
        "matri_id_to": matriIdTo,
        "type": "disliked",
      });

      debugPrint("🔹 API Response (Remove Like): ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint(" Token updated (Remove Like)");
        }

        if (!decodedJson.containsKey('message')) {
          throw Exception("Invalid API response format — 'message' missing");
        }

        return Removelike.fromJson(decodedJson);
      } else {
        throw Exception(
          "Failed to dislike profile. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(" Error removing like: $e");
      rethrow;
    }
  }

  //likes
  static Future<Map<String, dynamic>> fetchLikedProfiles(
    BuildContext context,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId1 = prefs.getString('matriId');

      if (matriId1 == null) {
        throw Exception("Matri ID not found in SharedPreferences");
      }

      final response = await _post(context, "matri_liked.php", {
        "matri_id": matriId1,
        "type": "iliked",
      });

      debugPrint(" API Response (Liked Profiles): ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint(" Token updated (Liked Profiles)");
        }

        if (!decodedJson.containsKey('dataout')) {
          throw Exception("Invalid API response format — 'dataout' missing");
        }

        return decodedJson;
      } else {
        throw Exception(
          "Failed to fetch liked profiles. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(" Error fetching liked profiles: $e");
      rethrow;
    }
  }

  //Sharath
  static Future<Map<String, dynamic>> profileViewed(
    String candidateId,
    BuildContext context,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId = prefs.getString('matriId');

      if (matriId == null) {
        throw Exception("Matri ID not found in SharedPreferences");
      }

      final response = await _post(context, "profile_viewed.php", {
        "matri_id_by": matriId,
        "matri_id_to": candidateId,
        "type": "viewed",
      });

      debugPrint("🔹 Raw Response (Profile Viewed): ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint("Token updated (Profile Viewed)");
        }

        return decodedJson;
      } else {
        throw Exception(
          "Failed to view profile. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Error in profileViewed: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> masterCount(
    String candidateId,
    String type,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId = prefs.getString('matriId');
    final response = await http.post(
      Uri.parse("$_baseUrl/master_count.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "matri_id": matriId,
        "matri_id_to": candidateId,
        "type": type,
      }),
    );
    print("Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Parsed Response: $jsonResponse");
        return jsonResponse;
      } catch (e) {
        throw Exception("Invalid JSON response: ${response.body}");
      }
    } else {
      throw Exception(
        "Profile failed with status code: ${response.statusCode}",
      );
    }
  }

  static Future<Map<String, dynamic>> contactViewed(
    BuildContext context,
    String candidateId,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId = prefs.getString('matriId');

      if (matriId == null) {
        throw Exception("Matri ID not found in SharedPreferences");
      }

      final response = await _post(context, "contacted_profile.php", {
        "matri_id_by": matriId,
        "matri_id_to": candidateId,
        "type": "contacted",
      });

      debugPrint("🔹 Raw Response (Contact Viewed): ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        // Update token if new one is returned
        final newToken = decodedJson["newToken"] ?? decodedJson["token"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint("Token updated (Contact Viewed)");
        }

        if (!decodedJson.containsKey("message")) {
          throw Exception("Invalid API response format — 'message' missing");
        }

        return decodedJson;
      } else {
        throw Exception(
          "Failed to contact profile. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint(" Error in contactViewed: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> messageViewed(
    BuildContext context,
    String candidateId,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId = prefs.getString('matriId');

    final response = await _post(context, "contacted_profile.php", {
      "matri_id_by": matriId,
      "matri_id_to": candidateId,
      "type": "contacted",
    });

    print("Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Parsed Response: $jsonResponse");
        return jsonResponse;
      } catch (e) {
        throw Exception("Invalid JSON response: ${response.body}");
      }
    } else {
      throw Exception(
        "Contact failed with status code: ${response.statusCode}",
      );
    }
  }

  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/send_sms.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"type": "otp", "number": mobile}),
    );

    print("Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print("Parsed Response: $jsonResponse");
        return jsonResponse;
      } catch (e) {
        throw Exception("Invalid JSON response: ${response.body}");
      }
    } else {
      throw Exception("Login failed with status code: ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> changeStatus(
    BuildContext context,
    String statusId,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? matriId1 = prefs.getString('matriId');

      if (matriId1 == null) {
        throw Exception("Matri ID not found in SharedPreferences");
      }

      final response = await _post(context, "profile_status.php", {
        "matri_id": matriId1,
        "status": statusId,
      });

      debugPrint(" API Response (Change Status): ${response.body}");

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);

        final newToken = decodedJson["token"] ?? decodedJson["newToken"];
        if (newToken != null) {
          await prefs.setString("token", newToken);
          debugPrint("Token refreshed and saved (Change Status)");
        }

        return decodedJson;
      } else {
        throw Exception(
          "Failed to change status. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("⚠️ Error in changeStatus(): $e");
      rethrow;
    }
  }

  //Tickets
  static Future<AddTicket> fetchAddTicketData(
    String name,
    String matriId,
    String phone,
    String issues,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? matriId1 = prefs.getString('matriId');

    final response = await http.post(
      Uri.parse("$_baseUrl/master_ticket.php"),
      headers: _headers,
      body: jsonEncode({
        "name": name,
        "phone": phone,
        "matri_id": matriId1,
        "issues": issues,
        "type": "add_ticket",
      }),
    );

    if (response.statusCode == 200) {
      return AddTicket.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to submit ticket");
    }
  }

  //Support Number
  static Future<List<supportnumberdata>> fetchsupportnumber() async {
    final response = await http.post(
      Uri.parse("$_baseUrl/support_number.php"),
      headers: _headers,
      body: jsonEncode({"status": "1"}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['dataout'];
      return data.map((e) => supportnumberdata.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load subcaste data");
    }
  }

  //cash Free
  static Future<Map<String, dynamic>> fetchPaymentData(
    String selectedPlanId,
    String selectedAmount,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? matriId1 = prefs.getString('matriId');
    String? name = prefs.getString('name');
    String? phone = prefs.getString('creator_phone');

    if (matriId1 == null || phone == null) {
      throw Exception(" Missing matriId or phone in SharedPreferences");
    }

    DateTime today = DateTime.now();
    String planActivated = DateFormat('yyyy-MM-dd').format(today);

    DateTime expiryDate = today.add(Duration(days: 365));
    String planExpiry = DateFormat('yyyy-MM-dd').format(expiryDate);

    String transactionId =
        "${matriId1}${phone.substring(4, 8)}${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}${DateTime.now().second.toString().padLeft(2, '0')}";

    String paymentId = transactionId;

    final response = await http.post(
      Uri.parse("$_baseUrl/cashfree.php"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "phone": phone,
        "matri_id": matriId1,
        "type": "INITIATED",
        "payment_mode": "online",
        "amount": selectedAmount,
        "plan_name": selectedPlanId,
        "plan_activated": planActivated,
        "plan_expiery": planExpiry,
        "plan_amount": selectedAmount,
        "transaction_id": transactionId,
        "payment_id": paymentId,
      }),
    );

    print("Payment API Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception(" Invalid JSON response: ${response.body}");
      }
    } else {
      throw Exception(" API call failed with status: ${response.statusCode}");
    }
  }

  //Cashfree Captured

  static Future<Captured> fetchCapturedData(String transactionId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //String? paymentId = prefs.getString('payment_id');
      String? paymentId = transactionId; // Retrieve stored payment ID
      if (paymentId == null) {
        throw Exception("Payment ID not found in preferences.");
      }

      final response = await http.post(
        Uri.parse("$_baseUrl/token_cashfree.php"),
        headers: _headers,
        body: jsonEncode({
          "type": "UPDATE",
          "transaction_id": transactionId,
          "payment_id": paymentId,
          "transaction_status": "captured",
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("API Response: ${response.body}");
        return Captured.fromJson(json.decode(response.body));
      } else {
        debugPrint(" API Error Response: ${response.body}");
        throw Exception("Failed to update transaction status");
      }
    } catch (e) {
      debugPrint("Exception: $e");
      throw Exception("Error in fetchCapturedData: $e");
    }
  }

  //Sub plan

  static Future<List<SubscriptionData>> fetchSubscriptionData() async {
    final response = await http.post(
      Uri.parse("$_baseUrl/get_data.php"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"type": "subscription_plan"}),
    );

    print(" Subscription API Status Code: ${response.statusCode}");
    print(" Subscription API Response: ${response.body}");

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body.trim());

        if (!jsonResponse.containsKey("dataout") ||
            jsonResponse["dataout"] == null) {
          throw Exception("Missing 'dataout' key in response.");
        }

        List<dynamic> dataList = jsonResponse["dataout"];
        if (dataList.isEmpty) {
          throw Exception(" No subscription plans found.");
        }

        return dataList.map((item) => SubscriptionData.fromJson(item)).toList();
      } catch (e) {
        throw Exception(" Invalid JSON response: ${response.body}");
      }
    } else {
      throw Exception(" API call failed with status: ${response.statusCode}");
    }
  }
}
