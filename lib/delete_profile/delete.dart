import 'package:buntsmatrimony/auth_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buntsmatrimony/api_service.dart';
import 'package:buntsmatrimony/dashboard_model.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:buntsmatrimony/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ChangeStatusPage extends StatefulWidget {
  @override
  _ChangeStatusPageState createState() => _ChangeStatusPageState();
}

class _ChangeStatusPageState extends State<ChangeStatusPage> {
  String? _selectedStatus;
  TextEditingController _otpController = TextEditingController();
  bool _showOtpField = false;
  bool _otpVerified = false;
  bool isLoading = false;
  Color appcolor = Color(0xFFea4a57);
  String otp = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileStatus();
  }

  void _sendOtp() {
    // Simulate an API call to send OTP

    setState(() async {
      setState(() {
        isLoading = true;
      });
      // try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? creatorPhone = prefs.getString('creatorPhone');

      if (creatorPhone == null) {
        throw Exception("creatorPhone is null");
      }
      Map<String, dynamic> response = await ApiService.sendOtp(creatorPhone);
      print("Final API Response in Login: $response");

      if (response.containsKey('message')) {
        var messageData = response['message'];
        if (messageData is Map<String, dynamic>) {
          String? statusFlag = messageData['p_out_mssg_flg']?.toString();
          String? messageText = messageData['p_out_mssg']?.toString();

          print("Status Flag: $statusFlag");
          print("Message Text: $messageText");
          String lastFour = creatorPhone.substring(creatorPhone.length - 4);
          if (statusFlag == "Y") {
            _showMessage(
              "OTP Sent To Registered Number Ending with : $lastFour",
            );

            if (response.containsKey('data')) {
              setState(() {
                otp = response['data']["Otp"].toString();
                _otpController.clear();
                isLoading = false;
                _showOtpField = true;
              });
            }
          } else {
            _showMessage(messageText ?? "Unable to process ");
          }
        } else {
          _showMessage("Unexpected response format");
        }
      } else {
        _showMessage("Unable to process");
      }
    });
  }

  Future<String> _changeStatus(String data) async {
    // Simulate an API call to send OTP
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> response = await ApiService.changeStatus(
      context,
      data,
    );
    print("Final API Response in Login: $response");

    if (response.containsKey('message')) {
      var messageData = response['message'];
      String? statusFlag = '';
      if (messageData is Map<String, dynamic>) {
        statusFlag = messageData['p_out_mssg_flg']?.toString();
        String? messageText = messageData['p_out_mssg']?.toString();

        print("Status Flag: $statusFlag");
        print("Message Text: $messageText");

        if (statusFlag == "Y") {
          _showMessage("Profile Status Changed");

          return "Y";
        } else {
          _showMessage(messageText ?? "Unable to process ");
          return "N";
        }
      } else {
        _showMessage("Unexpected response format");
      }
    } else {
      _showMessage("Unable to process");
    }
    return 'N';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  void _verifyOtp() {
    // Simulate an API call to verify OTP
    if (generateMd5(_otpController.text.trim()) == otp.trim()) {
      // Mock OTP verification
      setState(() {
        _otpVerified = true;
        _showOtpField = false;
      });
    } else {
      _showMessage("Invalid OTP ");
    }
  }

  Future<void> _fetchProfileStatus() async {
    try {
      myProfileData profileData = await ApiService.fetchmyProfileData(context);
      if (profileData.dataout.isNotEmpty) {
        setState(() {
          _selectedStatus = profileData.dataout[0].profileStatus;
          print("Profile status:$_selectedStatus");
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile status: $e");
    }
  }

  Future<void> _handleSubmit() async {
    var localizations = AppLocalizations.of(context);
    if (_selectedStatus == '4') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.translate('confirm_deletion')),
            content: Text(localizations.translate('delete_dialog')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: Text(localizations.translate('cancel')),
              ),
              TextButton(
                onPressed: () async {
                  // Log out
                  String response = await _changeStatus(_selectedStatus!);
                  Navigator.of(context).pop(); // Close dialog first

                  if (response == 'Y') {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen()),
                    );
                  } else {
                    _showMessage("Error changing profile status.");
                  }
                },
                child: Text(
                  localizations.translate('delete'),
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    } else {
      String responce = await _changeStatus(_selectedStatus!);
      setState(() {
        isLoading = false;
      });
    }
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => StatusDetailPage(data: data),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    print("Vi${localizations.locale.languageCode}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          localizations.translate('change_status'),
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(20),
            // ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 25,
            ), // Back button icon
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (localizations.locale.languageCode == "en")
                  ? Text(
                      "Change status as you require:\n\n"
                      "• Active: Your profile is visible to all users, and they can connect with you through the app.\n\n"
                      "• Married: Congratulations! Since you are married, your profile will no longer be visible to anyone.\n\n"
                      "• Not Interested: Your profile will be hidden from others, but you can log in anytime and change your status to make it visible again.\n\n"
                      "• Delete: Your account and all associated data will be permanently deleted. You will no longer be able to log in.",
                      style: TextStyle(fontSize: 14),
                    )
                  : Text(
                      "ಸ್ಥಿತಿಯನ್ನು ನಿಮ್ಮ ಅಗತ್ಯಕ್ಕೆ ತಕ್ಕಂತೆ ಬದಲಾಯಿಸಿ:\n\n"
                      "• ಸಕ್ರಿಯ (Active): ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಎಲ್ಲಾ ಬಳಕೆದಾರರಿಗೆ ಗೋಚರಿಸಲಿದೆ, ಮತ್ತು ಅವರು ಅಪ್ಲಿಕೇಶನ್ ಮೂಲಕ ನಿಮ್ಮೊಂದಿಗೆ ಸಂಪರ್ಕ ಸಾಧಿಸಬಹುದು.\n\n"
                      "•ವಿವಾಹಿತ (Married): ಅಭಿನಂದನೆಗಳು! ನೀವು ವಿವಾಹಿತರಾಗಿರುವುದರಿಂದ, ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಯಾರಿಗೂ ಗೋಚರಿಸದು.\n\n"
                      "•ಆಸಕ್ತಿಯಿಲ್ಲ (Not Interested): ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಇತರರಿಗೆ ಮರೆಮಾಡಲಾಗುತ್ತದೆ, ಆದರೆ ನೀವು ಯಾವಾಗ ಬೇಕಾದರೂ ಲಾಗಿನ್ ಮಾಡಿ, ನಿಮ್ಮ ಸ್ಥಿತಿಯನ್ನು ಬದಲಾಯಿಸಿ ಮತ್ತು ಮತ್ತೆ ಗೋಚರಿಸಬಹುದು.\n\n"
                      "• ಅಕೌಂಟ್ ಅಳಿಸಿ (Delete): ನಿಮ್ಮ ಖಾತೆ ಮತ್ತು ಅದರ ಸಂಬಂಧಿತ ಎಲ್ಲಾ ಡೇಟಾ ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಲಿದೆ. ನೀವು ಮತ್ತೆ ಲಾಗಿನ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುವುದಿಲ್ಲ.",
                      style: TextStyle(fontSize: 14),
                    ),
              SizedBox(height: 10),
              Column(
                children: [
                  RadioListTile<String>(
                    title: Text(localizations.translate('active')),
                    value: "1",
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _showOtpField = false;
                        _otpVerified = false;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(localizations.translate('married')),
                    value: "2",
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _showOtpField = false;
                        _otpVerified = false;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(localizations.translate('not_interested')),
                    value: "3",
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _showOtpField = false;
                        _otpVerified = false;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(localizations.translate('delete')),
                    value: "4",
                    groupValue: _selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _showOtpField = false;
                        _otpVerified = false;
                      });
                    },
                  ),
                ],
              ),
              if (_selectedStatus == "4" && !_otpVerified) ...[
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: appcolor, // Text color
                    ),
                    onPressed: _sendOtp,
                    child: Text(localizations.translate('send_otp')),
                  ),
                ),
              ],
              if (isLoading) ...[
                const SizedBox(height: 10),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_showOtpField) ...[
                SizedBox(height: 10),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: localizations.translate('enter_otp'),
                    counterText: "",
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: appcolor, // Text color
                    ),
                    onPressed: _verifyOtp,
                    child: Text(localizations.translate('verify_otp')),
                  ),
                ),
              ],
              if (_otpVerified || _selectedStatus != "4") ...[
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: appcolor, // Text color
                    ),
                    onPressed: _handleSubmit,
                    child: Text(localizations.translate('submit')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
