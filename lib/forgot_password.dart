import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:practice/lang.dart';
import 'dart:convert';
import 'api_service.dart';
import 'dashboard_model.dart';

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final Color _signColor = Color(0xFFC3A38C);
  bool showOtpSection = false;
  bool showPasswordSection = false;
    Color appcolor = Color(0xFFC3A38C);
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String matriId = '';
  String sentOtp = '';

  void _checkNumberAndSendOtp() async {
    String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter a valid phone number")),
      );
      return;
    }

    try {
      var response = await ApiService.checkNumber(phoneNumber);
      print("Check Number API Response: $response");

      if (response['message']['p_out_mssg_flg'] == 'Y' &&
          response['dataout'] != null) {
        setState(() {
          showOtpSection = true;
          matriId = response['dataout'][0]['matri_id'];
        });
        _sendOtp(phoneNumber);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone Number Not Found")),
        );
      }
    } catch (e) {
      print("Error in _checkNumberAndSendOtp: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _sendOtp(String phoneNumber) async {
    try {
      var response = await ApiService.sendOtp(phoneNumber);
      print("Send OTP API Response: $response");

      if (response['message']['p_out_mssg_flg'] == 'Y' &&
          response['data'] != null) {
        sentOtp = response['data']['Otp'].toString().trim();
        print("Stored OTP (hashed): $sentOtp");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP Sent Successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to Retrieve OTP")),
        );
      }
    } catch (e) {
      print("Error in _sendOtp: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _verifyOtp() {
    String enteredOtp = otpController.text.trim();
    String hashedEnteredOtp = md5.convert(utf8.encode(enteredOtp)).toString();

    print("Entered OTP: $enteredOtp");
    print("Hashed Entered OTP: $hashedEnteredOtp");
    print("Stored OTP (from API): $sentOtp");

    if (hashedEnteredOtp == sentOtp) {
      setState(() {
        showPasswordSection = true;
        showOtpSection = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verified Successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP")),
      );
    }
  }

  void _changePassword() async {
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      var response = await ApiService.updatePassword(matriId, newPassword);
      print("Change Password API Response: $response");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message']['p_out_mssg'])),
      );

      if (response['message']['p_out_mssg_flg'] == 'Y') {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error in _changePassword: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
       appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          localizations.translate('forgot_password'),
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
            child: Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 25), // Back button icon
          ),
        ),
      ),
      body: Stack(
        children: [
        

          // Back Button
          // Positioned(
          //   top: 40,
          //   left: 20,
          //   child: CircleAvatar(
          //     backgroundColor: Colors.white.withOpacity(0.6),
          //     child: IconButton(
          //       icon: Icon(Icons.arrow_back, color: Colors.grey),
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //     ),
          //   ),
          // ),

          // Form Section
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Title

                
                 // SizedBox(height: 10),

                  // Logo Image
                  Image.asset(
                    'assets/shiva_linga.png',
                    height: 100,
                  ),

                 SizedBox(height: 20),

                  // Phone Number Input
                  if (!showPasswordSection) ...[
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('phone_number'),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 20),

                if (!showOtpSection && !showPasswordSection) ...[
                      SizedBox(
                        width: 200, // Decreased width
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _signColor,
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Adjust padding
                            minimumSize: Size(50, 50), // Smaller button size
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Reduced border radius
                            ),
                          ),
                          onPressed: _checkNumberAndSendOtp,
                          child: Text(
                            localizations.translate('reset_password'),
                            style: TextStyle(fontSize: 14, color: Colors.white), // Smaller font
                          ),
                        ),
                      ),
                    ],


                  if (showOtpSection) ...[
                    SizedBox(height: 10),
                    if (showOtpSection && !showPasswordSection) ...[
                      TextField(
                        controller: otpController,
                        onChanged: (value) {
                          if (value.length == 4) {
                            // Only call verify function when OTP is fully entered
                            _verifyOtp();
                          }
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: localizations.translate('enter_otp'),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ],

                  if (showPasswordSection) ...[
                    SizedBox(height: 10),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: localizations.translate('new_password'),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: localizations.translate('confirm_password'),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _signColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _changePassword,
                        child: Text(
                          localizations.translate('change_password'),
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
