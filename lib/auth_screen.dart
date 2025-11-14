// auth_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:buntsmatrimony/api_service.dart';
import 'package:buntsmatrimony/forgot_password.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:buntsmatrimony/main_screen.dart';
import 'package:buntsmatrimony/register_main.dart';
import 'package:buntsmatrimony/support.dart';
import 'package:buntsmatrimony/tearms.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // UI toggles
  bool _showPassword = false;
  bool _showOtpSection = false;

  // Inputs
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // OTP inputs: 4 boxes as requested
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  // Colors
  Color primary = const Color(0xFFE3425B);
  Color primaryDark = const Color(0xFFea4a57);

  // Network / state
  bool _isOffline = false;
  bool _termsAccepted = true;
  bool _isLoginLoading = false;
  bool _isSendingOtp = false;
  bool _otpGenerated = false;
  bool _isOtpLoading = false;

  // OTP storage (server returns OTP in response['data']['Otp'])
  String? _storedOtpHash;

  // Countdown
  int _countdown = 30;
  Timer? _timer;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    _checkInternet();
    // Listen for connectivity changes
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      setState(() {
        _isOffline = !(results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi));
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ================== Helpers ==================
  Future<void> _checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = !(result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi);
    });
  }

  void _showPopup(String title, String message) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.translate('ok'),
                style: TextStyle(color: primaryDark, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveLoginData(
    String mobile,
    String password,
    String matriId1,
    int id,
    String phone,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile', mobile);
    await prefs.setString('password', password);
    await prefs.setString('matriId', matriId1);
    await prefs.setInt('id', id);
    await prefs.setString('phone', phone);
    // debug
    // ignore: avoid_print
    print(
      "Saved to SharedPreferences: Mobile=$mobile, Password=$password, MatriId=$matriId1, ID=$id, Phone=$phone",
    );
  }

  void loginEntry(String id) {
    ApiService.loginEntry(id);
  }

  // ================== Countdown ==================
  void _startCountdown() {
    setState(() {
      _countdown = 30;
      _canResendOtp = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        t.cancel();
        setState(() => _canResendOtp = true);
      }
    });
  }

  // ================== Password Login ==================
  Future<void> _login() async {
    final localizations = AppLocalizations.of(context);

    if (_isOffline) {
      _showPopup(
        localizations.translate('no_internet'),
        localizations.translate('no_internet_msg'),
      );
      return;
    }
    if (!_termsAccepted) {
      _showMessage(localizations.translate('accept_terms'));
      return;
    }

    final mobile = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (mobile.isEmpty || password.isEmpty) {
      _showMessage(localizations.translate('login_validation'));
      return;
    }

    setState(() => _isLoginLoading = true);

    try {
      final response = await ApiService.loginUser(mobile, password);
      // ignore: avoid_print
      print("Final API Response in Login: $response");

      if (response.containsKey('token')) {
        _showMessage("Login successful");

        final int id = response['id'] ?? 0;
        final String matriId1 = response['matri_id'] ?? '';
        final String phone = response['phone']?.toString() ?? '';

        await _saveLoginData(mobile, password, matriId1, id, phone);
        loginEntry(matriId1);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        _showMessage("Invalid credentials or response format");
      }
    } catch (e) {
      _showMessage("Login Failed");
    } finally {
      setState(() => _isLoginLoading = false);
    }
  }

  // ================== OTP Flow ==================
  Future<void> _generateOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      _showMessage("Please enter a valid 10-digit phone number.");
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    try {
      // Verify if number exists
      final response = await ApiService.checkNumber(phone);

      if (response['dataout'] != null &&
          response['dataout'].isNotEmpty &&
          response['dataout'][0]['p_out_mssg_flg'] == "Y") {
        // Send OTP
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
      // ignore: avoid_print
      print("Error: $e");
      _showMessage("Login Failed");
    } finally {
      setState(() {
        _isSendingOtp = false;
      });
    }
  }

  Future<void> _sendOtp(String phone) async {
    try {
      final response = await ApiService.SendOtp(phone);
      // ignore: avoid_print
      print("Send OTP API Response: $response");

      if (response.containsKey('message') &&
          response['message']['p_out_mssg_flg']?.toString() == "Y") {
        if (response.containsKey('data') && response['data'] is Map) {
          _storedOtpHash = response['data']['Otp']?.toString();
          // ignore: avoid_print
          print("Stored OTP from server: $_storedOtpHash");
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

  Future<void> _loginWithOtp() async {
    if (!_termsAccepted) {
      _showMessage(AppLocalizations.of(context).translate('accept_terms'));
      return;
    }

    final enteredOtp = _otpControllers.map((c) => c.text).join();
    if (enteredOtp.length != 4) {
      _showMessage("Please enter a valid 4-digit OTP.");
      return;
    }

    if (_storedOtpHash == null) {
      _showMessage("OTP verification failed. Please request a new OTP.");
      return;
    }

    setState(() => _isOtpLoading = true);

    try {
      final response =
          await ApiService.checkNumber(_phoneController.text.trim());

      print("OTP Login API Response: $response");

      if (response.containsKey('dataout') &&
          response['dataout'].isNotEmpty &&
          response['dataout'][0]['p_out_mssg_flg'] == "Y") {
        final token = response['dataout'][0]['token'] ?? '';
        if (token.isEmpty) {
          _showMessage("Token not received from server.");
          return;
        }

        // Decode JWT
        final parts = token.split('.');
        if (parts.length != 3) {
          throw Exception("Invalid JWT token format");
        }

        final payloadMap = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );

        final data = payloadMap["data"] ?? {};
        final int id = data["id"] ?? 0;
        final String matriId = data["matri_id"] ?? '';
        final String phone = data["phone"].toString();

        // Save token & user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setInt("id", id);
        await prefs.setString("matriId", matriId);
        await prefs.setString("phone", phone);

        loginEntry(matriId);

        _showMessage("Login successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        final message =
            (response['dataout'] != null && response['dataout'].isNotEmpty)
                ? (response['dataout'][0]['p_out_mssg'] ??
                    "OTP verification failed.")
                : "OTP verification failed.";
        _showMessage(message);
      }
    } catch (e) {
      print("OTP Login Error: $e");
      _showMessage("Error: $e");
    } finally {
      setState(() => _isOtpLoading = false);
    }
  }

  // Helper to clear OTP fields
  void _clearOtpFields() {
    for (final c in _otpControllers) c.clear();
    _otpFocusNodes[0].requestFocus();
  }

  Widget _buildOtpInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 55,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            maxLength: 1,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primary),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primary),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
              }
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
                alignment: Alignment(-0.4, 0),
              ),
            ),
          ),

          /// Light overlay
          Container(color: Colors.white.withOpacity(0.55)),

          /// Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// Header (centered logo)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.98),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Image.asset("assets/buntslogo.jpg", height: 80),
                  ),

                  /// Body
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05, vertical: 20),
                    child: Column(
                      children: [
                        /// Login Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.88),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Login with Password",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Sign in to your account",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 14),

                              /// Phone / Matri ID
                              TextField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  hintText: "Enter your phone / Matri ID",
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.black12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              /// Password
                              TextField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                decoration: InputDecoration(
                                  hintText: "Enter your password",
                                  filled: true,
                                  fillColor: Colors.white,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: primary,
                                    ),
                                    onPressed: () => setState(
                                        () => _showPassword = !_showPassword),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.black12),
                                  ),
                                ),
                              ),

                              /// Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                ForgetPasswordPage()));
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              /// LOGIN Button
                              SizedBox(
                                width: width * 0.5,
                                child: ElevatedButton(
                                  onPressed: _isLoginLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 6,
                                  ),
                                  child: _isLoginLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          "LOGIN",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 12),
                              Row(
                                children: const [
                                  Expanded(child: Divider(color: Colors.black)),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("OR"),
                                  ),
                                  Expanded(child: Divider(color: Colors.black)),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Text(
                                "Login with OTP",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Quick and secure access",
                                style: TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 14),

                              /// OTP Phone Input
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: "Enter 10-digit phone number",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.black12),
                                  ),
                                ),
                                onChanged: (_) {
                                  setState(() {
                                    _showOtpSection = false;
                                    _otpGenerated = false;
                                    _storedOtpHash = null;
                                    for (final c in _otpControllers) c.clear();
                                  });
                                },
                              ),
                              const SizedBox(height: 10),

                              SizedBox(
                                width: width * 0.5,
                                child: ElevatedButton(
                                  onPressed: (_isSendingOtp || _isOtpLoading)
                                      ? null
                                      : (_otpGenerated
                                          ? _loginWithOtp
                                          : _generateOtp),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: (_isSendingOtp || _isOtpLoading)
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.white)),
                                        )
                                      : Text(
                                          _otpGenerated
                                              ? "Verify & Login"
                                              : "Generate OTP",
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              if (_showOtpSection) ...[
                                const SizedBox(height: 14),
                                _buildOtpInputs(),
                                const SizedBox(height: 10),

                                // Resend / timer
                                _canResendOtp
                                    ? GestureDetector(
                                        onTap:
                                            _isSendingOtp ? null : _generateOtp,
                                        child: Text(
                                          "Resend OTP",
                                          style: TextStyle(
                                            color: primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        "Resend OTP in ${_countdown}s",
                                        style: TextStyle(
                                            color: primary, fontSize: 12),
                                      ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// "Don't have an account?" Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => SignUpPage()),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primary, // button background color
                                  borderRadius: BorderRadius.circular(
                                      20), // rounded button
                                ),
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors
                                        .white, // white text inside button
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Terms & Support
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _termsAccepted,
                                onChanged: (val) => setState(
                                    () => _termsAccepted = val ?? false),
                                activeColor: primary,
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: "I agree to the ",
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: "terms and privacy policy",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: primary,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    TermsAndConditionsPage(),
                                              ),
                                            );
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            text: "For any Query / Support ",
                            style: TextStyle(
                                fontFamily: 'Inter', color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Click here",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ContactFormPage()),
                                    );
                                  },
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
   SizedBox(
  height: height * 0.27,
  child: Row(
    children: [
      /// Kannada text (unchanged)
      Padding(
        padding: const EdgeInsets.only(left: 0),
        child: Image.asset(
          "assets/kannadaText.png",
          height: height * 0.15,
          fit: BoxFit.contain,
        ),
      ),

      /// BuntsLove shifted to the RIGHT
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment.centerRight,
            child: Transform.translate(
              offset: const Offset(80, 0),   // ⬅️ SHIFT RIGHT (increase if needed)
              child: Transform.rotate(
                angle: 4.6,
                child: Image.asset(
                  "assets/Buntslove.png",
                  height: height * 6.35,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),





                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
