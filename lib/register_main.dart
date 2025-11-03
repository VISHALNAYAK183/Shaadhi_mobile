import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:buntsmatrimony/api_services.dart';
import 'package:buntsmatrimony/custom_widget.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:buntsmatrimony/language_provider.dart';
import 'package:buntsmatrimony/login.dart';
import 'package:buntsmatrimony/register_personal_details.dart';
import 'package:buntsmatrimony/tearms.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? selectedProfile;
  bool isChecked = false;
  bool showOTPField = false;
  bool showBottom = true;
  bool isResendEnabled = false;
  bool showOTPButton = true;

  int resendTimer = 30;
  Timer? _timer;
  Color appcolor = Color(0xFFea4a57);

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? passwordError;
  String? confirmPasswordError;
  String? nameError;

  TextEditingController creatorName = TextEditingController();
  TextEditingController creatorPhone = TextEditingController();
  final TextEditingController otp1 = TextEditingController();
  final TextEditingController otp2 = TextEditingController();
  final TextEditingController otp3 = TextEditingController();
  final TextEditingController otp4 = TextEditingController();
  bool showPasswordFields = false;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? receivedOtp;

  final FocusNode otp1Focus = FocusNode();
  final FocusNode otp2Focus = FocusNode();
  final FocusNode otp3Focus = FocusNode();
  final FocusNode otp4Focus = FocusNode();

  final Color _signColor = Color(0xFFea4a57);

  Map<String, String> profileCreatorMap = {
    "1": "1",
    "2": "2",
    "3": "2",
    "4": "3",
    "5": "3",
  };

  @override
  void initState() {
    super.initState();
    showBottom = true;
  }

  String? _validateName(String name) {
    if (name.isEmpty) {
      return "Name is required";
    } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(name)) {
      return "Only alphabets are allowed";
    }
    return null;
  }

  Future<void> ConfirmPersonalDetailsPage() async {
    setState(() {
      if (passwordController.text.isEmpty) {
        passwordError = "Enter Password";
      } else {
        passwordError = null;
      }

      if (confirmPasswordController.text.isEmpty) {
        confirmPasswordError = "Confirm your Password";
      } else if (confirmPasswordController.text != passwordController.text) {
        confirmPasswordError = "Passwords do not match";
      } else {
        confirmPasswordError = null;
      }

      if (!isChecked) {
        showSnackBar("Please agree to the Terms & Policy to continue.");
      }

      nameError = _validateName(creatorName.text);
    });

    if (passwordError == null &&
        confirmPasswordError == null &&
        isChecked &&
        nameError == null) {
      if (selectedProfile != null) {
        String profileCreator = profileCreatorMap[selectedProfile] ?? "1";

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPersonalDetails(
              profileType: selectedProfile!,
              profileCreator: profileCreator,
              creatorName: creatorName.text,
              creatorPhone: creatorPhone.text,
              password: passwordController.text,
            ),
          ),
        );
      } else {
        showSnackBar("Please select a profile before proceeding.");
      }
    }
  }

  Future<void> getOtp() async {
    if (RegExp(r'^[0-9]{10}$').hasMatch(creatorPhone.text)) {
      bool isValid = await ApiService.validatePhoneNumber(creatorPhone.text);
      if (isValid) {
        String? encryptedOTP = await ApiService.generateOTP(creatorPhone.text);
        print("received otp:$encryptedOTP");
        if (encryptedOTP != null) {
          setState(() {
            showOTPField = true;
            receivedOtp = encryptedOTP;
            startResendTimer();
            showOTPButton = false;
            Future.delayed(Duration(milliseconds: 100), () {
              FocusScope.of(context).requestFocus(otp1Focus);
            });
          });
        } else {
          showSnackBar("Failed to generate OTP. Try again.");
        }
      } else {
        showSnackBar("Phone number already exists!");
      }
    } else {
      showSnackBar("Enter a valid 10-digit number");
    }
  }

  void checkOTP() {
    String enteredOTP =
        otp1.text.trim() +
        otp2.text.trim() +
        otp3.text.trim() +
        otp4.text.trim();
    String encryptedEnteredOTP = md5
        .convert(utf8.encode(enteredOTP))
        .toString();
    if (receivedOtp == encryptedEnteredOTP) {
      setState(() {
        showPasswordFields = true;
        showOTPField = false;
        showOTPButton = false;
      });
    } else {
      showSnackBar("Incorrect OTP! Please try again.");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void startResendTimer() {
    setState(() {
      isResendEnabled = false;
      resendTimer = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTimer > 0) {
          resendTimer--;
        } else {
          isResendEnabled = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    var languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          localizations.translate('sign_up'),
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
        actions: [
          Align(
            alignment: Alignment.centerRight,
            // Align to the right
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _signColor,
                  width: 2,
                ), // Border color & width
                borderRadius: BorderRadius.circular(
                  8,
                ), // Optional: Rounded corners
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<String>(
                value: languageProvider.locale.languageCode,
                icon: Icon(Icons.arrow_drop_down, color: _signColor),
                dropdownColor: const Color.fromARGB(255, 210, 114, 114),
                style: TextStyle(color: Colors.white),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    languageProvider.changeLanguage(newValue);
                  }
                },
                items: [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'kn', child: Text('ಕನ್ನಡ')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedProfile,
                items:
                    {
                          "1": "Self",
                          "2": "Son",
                          "3": "Daughter",
                          "4": "Brother",
                          "5": "Sister",
                        }.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              style: TextStyle(fontSize: 16, color: _signColor),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProfile = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: localizations.translate('creating_profile_for'),
                  labelStyle: TextStyle(fontSize: 16, color: _signColor),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: creatorName,
                style: TextStyle(fontSize: 16, color: _signColor),
                decoration: InputDecoration(
                  labelText: localizations.translate('your_name'),
                  labelStyle: TextStyle(fontSize: 16, color: _signColor),
                  border: OutlineInputBorder(),
                  errorText: nameError,
                ),
                onChanged: (value) {
                  setState(() {
                    nameError = _validateName(value);
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: creatorPhone,
                style: TextStyle(fontSize: 16, color: _signColor),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: localizations.translate('phone_number'),
                  labelStyle: TextStyle(fontSize: 16, color: _signColor),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              if (showOTPButton) ...[
                customElevatedButton(
                  getOtp,
                  localizations.translate('get_otp'),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        localizations.translate('already_have_account'),
                        style: TextStyle(
                          fontSize: 14,
                          color: _signColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          localizations.translate('login'),
                          style: TextStyle(
                            color: _signColor,
                            decoration: TextDecoration.underline,
                            decorationColor: _signColor,
                            decorationThickness: 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (showOTPField) ...[
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    localizations.translate('enter_otp'),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    otpBox(otp1, otp1Focus, otp2Focus),
                    otpBox(otp2, otp2Focus, otp3Focus),
                    otpBox(otp3, otp3Focus, otp4Focus),
                    otpBox(otp4, otp4Focus, null),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: isResendEnabled ? getOtp : null,
                    child: Text(
                      isResendEnabled
                          ? localizations.translate('resend_otp')
                          : localizations
                                .translate('otp_resend')
                                .replaceAll(
                                  '{seconds}',
                                  resendTimer.toString(),
                                ),
                      style: TextStyle(
                        color: isResendEnabled ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ),
                alreadyHaveAccount(context, localizations),
              ],
              if (showPasswordFields) ...[
                // const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(fontSize: 16, color: _signColor),
                  onChanged: (value) {
                    setState(() {
                      passwordError = null;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: localizations.translate('set_password'),
                    labelStyle: TextStyle(fontSize: 16, color: _signColor),
                    border: OutlineInputBorder(),
                    errorText: passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: TextStyle(fontSize: 16, color: _signColor),
                  onChanged: (value) {
                    setState(() {
                      confirmPasswordError = null;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: localizations.translate('confirm_password'),
                    labelStyle: TextStyle(fontSize: 16, color: _signColor),
                    border: OutlineInputBorder(),
                    errorText:
                        confirmPasswordController.text !=
                            passwordController.text
                        ? "Passwords do not match"
                        : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                if (showBottom) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                      ),
                      Text(
                        localizations.translate('agree'),
                        style: TextStyle(
                          fontSize: 14,
                          color: _signColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TermsAndConditionsPage(),
                            ),
                          );
                        },
                        child: Text(
                          localizations.translate('terms_and_conditions'),
                          style: TextStyle(
                            color: _signColor,
                            decoration: TextDecoration.underline,
                            decorationColor: _signColor,
                            decorationThickness: 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  customElevatedButton(
                    ConfirmPersonalDetailsPage,
                    localizations.translate('next'),
                  ),
                  const SizedBox(height: 10),
                  Center(child: Text(localizations.translate('or'))),
                  const SizedBox(height: 10),
                  alreadyHaveAccount(context, localizations),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget otpBox(
    TextEditingController controller,
    FocusNode focusNode,
    FocusNode? nextFocus,
  ) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            } else {
              focusNode.unfocus();
              checkOTP();
            }
          }
        },
      ),
    );
  }

  Widget alreadyHaveAccount(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localizations.translate('already_have_account'),
            style: TextStyle(
              fontSize: 14,
              color: _signColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text(
              localizations.translate('login'),
              style: TextStyle(
                color: _signColor,
                decoration: TextDecoration.underline,
                decorationColor: _signColor,
                decorationThickness: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
