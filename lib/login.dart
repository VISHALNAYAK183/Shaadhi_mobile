import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:practice/dashboard_model.dart';
import 'package:practice/lang.dart';
import 'package:practice/language_provider.dart';
import 'package:practice/register_main.dart';
import 'package:practice/support.dart';
import 'package:practice/tearms.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'custom_button.dart'; // Import your custom button widget
import 'api_service.dart'; // Import the API service
import 'main_screen.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  bool _showOtpSection = false;
  bool _termsAccepted = true;
  bool _isOffline = false;
  bool _otpGenerated = false;
  bool _isLoginLoading = false;
  bool _isOtpLoading = false;
  int _countdown = 30; // Initial countdown value
  Timer? _timer; // Timer instance
  bool _canResendOtp = false; // To track if resend is allowed

  String? _storedOtpHash;
  List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());
  List<FocusNode> _otpFocusNodes = List.generate(4, (index) => FocusNode());

  final Color _signColor = Color(0xFF8A2727);
  final Color _backgroundColor = Color(0xFFF1F1F1);

  Future<void> _saveLoginData(String mobile, String password, String matriId1,
      int id, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile', mobile);
    await prefs.setString('password', password);
    await prefs.setString('matriId', matriId1);
    await prefs.setInt('id', id);
    await prefs.setString('phone', phone);
    print(
        "Saved to SharedPreferences: Mobile=$mobile, Password=$password, MatriId=$matriId1, ID=$id, Phone=$phone");
  }

  @override
  void initState() {
    super.initState();
    _checkInternet(); // Check internet on startup

    // Listen for network changes
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      setState(() {
        _isOffline = !result.contains(ConnectivityResult.mobile) &&
            !result.contains(ConnectivityResult.wifi);
      });
    });
  }

  void _startCountdown() {
    setState(() {
      _countdown = 30;
      _canResendOtp = false;
    });

    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResendOtp = true; // Enable resend OTP button
        });
      }
    });
  }

  Future<void> _checkInternet() async {
    List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = !connectivityResult.contains(ConnectivityResult.mobile) &&
          !connectivityResult.contains(ConnectivityResult.wifi);
    });
  }

  void _showPopup(String title, String message) {
    var localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  Text(localizations.translate('ok'), style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    var localizations = AppLocalizations.of(context);
    if (_isOffline) {
      _showPopup(localizations.translate('no_internet'), localizations.translate('no_internet_msg'));
      return;
    }
    if (!_termsAccepted) {
      _showMessage(localizations.translate('accept_terms'));
      return;
    }

    String mobile = _mobileController.text.trim();
    String password = _passwordController.text.trim();

    if (mobile.isEmpty || password.isEmpty) {
      _showMessage(localizations.translate('login_validation'));
      return;
    }

    setState(() {
      _isLoginLoading = true;
    });

   try {
  Map<String, dynamic> response = await ApiService.loginUser(mobile, password);
  print("Final API Response in Login: $response");

  if (response.containsKey('token')) {
 
    _showMessage("Login successful");

    int id = response['id'] ?? 0;
    String matriId1 = response['matri_id'] ?? '';
    String phone = response['phone']?.toString() ?? '';

    await _saveLoginData(mobile, password, matriId1, id, phone);
    loginEntry(matriId1);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  } else {
    _showMessage("Invalid credentials or response format");
  }
} catch (e) {
  _showMessage("Error: ${e.toString()}");
} finally {
  setState(() {
    _isLoginLoading = false;
  });
}

  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void loginEntry(String id) {
    ApiService.loginEntry(id);
  }


  void _loginWithOtp() async {
    String enteredOtp = _otpControllers.map((c) => c.text).join();
    if (enteredOtp.length != 4) {
      _showMessage("Please enter a valid 4-digit OTP.");
      return;
    }

    if (_storedOtpHash == null) {
      _showMessage("OTP verification failed. Please request a new OTP.");
      return;
    }


    setState(() => _isOtpLoading = true); // ✅ Start loading only for OTP button

    try {
      Map<String, dynamic> loginResponse =
          await ApiService.checkNumber(_phoneController.text.trim());

      print("Login API Response: $loginResponse"); // Debugging

      if (loginResponse['message']['p_out_mssg_flg'] == "Y") {
        if (loginResponse.containsKey('dataout') &&
            loginResponse['dataout'] != null &&
            loginResponse['dataout'].isNotEmpty) {
          CheckNumberData userData =
              CheckNumberData.fromJson(loginResponse['dataout'][0]);

          // Save data to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id', userData.id);
          await prefs.setString('matriId', userData.matriId);
          await prefs.setString('phone', userData.phone);
          //call login
          loginEntry(userData.matriId);
          _showMessage("Login successful!");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainScreen()));
        } else {
          _showMessage("Login failed: No user data received.");
        }
      } else {
        _showMessage("Login failed: Invalid response.");
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    } finally {
      setState(
          () => _isOtpLoading = false); // ✅ Stop loading only for OTP button
    }
  }

  void _generateOtp() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      _showMessage("Please enter a valid 10-digit phone number.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> response = await ApiService.checkNumber(phone);
      if (response['message']['p_out_mssg_flg'] == "Y") {
        await _sendOtp(phone);

        setState(() {
          _showOtpSection = true;
          _otpGenerated = true;
        });

        _startCountdown();
      } else {
        _showMessage("This number is not registered.");
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp(String phone) async {
    try {
      Map<String, dynamic> response = await ApiService.SendOtp(phone);
      print("Send OTP API Response: $response");

      if (response.containsKey('message') &&
          response['message']['p_out_mssg_flg']?.toString() == "Y") {
        if (response.containsKey('data') && response['data'] is Map) {
          _storedOtpHash = response['data']['Otp']?.toString();
          print("Stored OTP Hash: $_storedOtpHash");
        } else {
          _showMessage("OTP data is missing in response.");
          return;
        }

        setState(() {
          _showOtpSection = true;
          _otpGenerated = true;
        });

        _showMessage("OTP sent successfully!");
      } else {
        _showMessage("Failed to send OTP. Try again.");
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    var localizations = AppLocalizations.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/icon-144x144.png',
                  height: screenHeight * 0.15,
                  width: screenHeight * 0.15,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                // Align to the right
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: _signColor, width: 2), // Border color & width
                    borderRadius:
                        BorderRadius.circular(8), // Optional: Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButton<String>(
                    value: languageProvider.locale.languageCode,
                    icon: Icon(Icons.arrow_drop_down, color: _signColor),
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
              // SizedBox(height: screenHeight * 0.02),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: _signColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(localizations.translate('login_otp'),
                        style: TextStyle(color: _signColor, fontSize: 18)),
                    SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: localizations.translate('phone_number'),
                        labelStyle: TextStyle(color: _signColor),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_showOtpSection) ...[
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 50,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _otpFocusNodes[index],
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: _signColor)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: _signColor)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: _signColor)),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 3) {
                                  FocusScope.of(context)
                                      .requestFocus(_otpFocusNodes[index + 1]);
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context)
                                      .requestFocus(_otpFocusNodes[index - 1]);
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 10),
                      _canResendOtp
                          ? GestureDetector(
                              onTap: _generateOtp, // Allow re-generating OTP
                              child: Text(
                                localizations.translate('resend_otp'),
                                style: TextStyle(
                                  color: _signColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          : Text(
                              localizations.translate('otp_resend').replaceAll('{seconds}', _countdown.toString()),
                              style: TextStyle(color: _signColor, fontSize: 12),
                            ),
                    ],
                    SizedBox(height: 10),
                    _isOtpLoading
                        ? CircularProgressIndicator(color: _signColor)
                        : CustomButton(
                            text: _otpGenerated
                                ? localizations.translate('login_otp')
                                : localizations.translate('get_otp'),
                            onPressed:
                                _otpGenerated ? _loginWithOtp : _generateOtp,
                            isLoading:
                                _isOtpLoading, // ✅ Shows loader only for OTP button
                          ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              // Login Form
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: _signColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(localizations.translate('login_other'),
                        maxLines: 1, // Limits text to one line
                        // overflow: TextOverflow.ellipsis, // Adds "
                        style: TextStyle(color: _signColor, fontSize: 18)),
                    SizedBox(height: 10),
                    TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: localizations.translate('login'),
                        labelStyle: TextStyle(color: _signColor),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: _signColor),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: localizations.translate('password'),
                        labelStyle: TextStyle(color: _signColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: _signColor,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: _signColor),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _isLoginLoading
                        ? CircularProgressIndicator(color: _signColor)
                        : CustomButton(
                            text: localizations.translate('login'),
                            onPressed: _login,
                            isLoading:
                                _isLoginLoading, // ✅ Shows loader only for Login button
                          ),
                    SizedBox(height: 5),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgetPasswordPage()));
                      },
                      child: Text('${localizations.translate('forgot_password')}?',
                          style: TextStyle(color: _signColor)),
                    ),
                  ],
                ),
              ),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                title: RichText(
                  text: TextSpan(
                    text: localizations.translate('agree'),
                    style: TextStyle(color: _signColor),
                    children: [
                      TextSpan(
                        text:localizations.translate('terms_and_conditions'),
                        style: TextStyle(decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to the Terms and Conditions page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TermsAndConditionsPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                value: _termsAccepted,
                onChanged: (value) {
                  setState(() {
                    _termsAccepted = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => (SignUpPage())),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(localizations.translate('new_account'),
                    style: TextStyle(
                      color: _signColor,
                    )),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ContactFormPage()), // Wrap in MaterialPageRoute
                  );
                },
                child: Text(localizations.translate('query_support'),
                    style: TextStyle(color: _signColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
