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
import 'package:crypto/crypto.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Page
  final PageController _controller = PageController();
  int _currentIndex = 0;

  // Colors
  final Color _signColor = const Color(0xFFea4a57);
  final Color _backgroundColor = const Color.fromARGB(255, 255, 255, 255);

  // Common
  bool _isOffline = false;
  bool _termsAccepted = true;

  // Password Login
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoginLoading = false;

  // OTP Login
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());
  bool _showOtpSection = false;
  bool _otpGenerated = false;
  bool _isOtpLoading = false;
  bool _isSendingOtp = false;
  String? _storedOtpHash; // server returns actual OTP in your response['data']['Otp']

  // Countdown
  int _countdown = 30;
  Timer? _timer;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    _checkInternet();
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> res) {
      setState(() {
        _isOffline =
            !res.contains(ConnectivityResult.mobile) &&
            !res.contains(ConnectivityResult.wifi);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  // ================== Helpers ==================

  Future<void> _checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline =
          !result.contains(ConnectivityResult.mobile) &&
          !result.contains(ConnectivityResult.wifi);
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
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.translate('ok'),
                style: TextStyle(color: _signColor, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

    final mobile = _mobileController.text.trim();
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
     
      final response = await ApiService.checkNumber(_phoneController.text.trim());
    
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
        final message = (response['dataout'] != null &&
                response['dataout'].isNotEmpty)
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

 
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/buntslogo.jpg',
                  height: screenHeight * 0.20,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // PageView: Password / OTP
              SizedBox(
                height: screenHeight * 0.52,
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  children: [
                    _buildPasswordLogin(localizations),
                    _buildOtpLogin(localizations),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Toggle
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 100),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: _signColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _currentIndex = 0);
                          _controller.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _currentIndex == 0 ? _signColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              "Password",
                              style: TextStyle(
                                color: _currentIndex == 0 ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _currentIndex = 1);
                          _controller.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _currentIndex == 1 ? _signColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              "OTP",
                              style: TextStyle(
                                color: _currentIndex == 1 ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Terms
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  title: RichText(
                    text: TextSpan(
                      text: localizations.translate('agree'),
                      style: TextStyle(color: _signColor),
                      children: [
                        TextSpan(
                          text: localizations.translate('terms_and_conditions'),
                          style: const TextStyle(decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TermsAndConditionsPage(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  value: _termsAccepted,
                  onChanged: (v) => setState(() => _termsAccepted = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),

              // Bottom links
              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    //Flexible(
      // child: Text(
      //   localizations.translate('dont have account'),
      //   textAlign: TextAlign.center,
      //   overflow: TextOverflow.visible,
      // ),
  //  ),
    const SizedBox(width: 6),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SignUpPage()),
        );
      },
      child: Flexible(
        child: Text(
          localizations.translate('new_account'),
          style: TextStyle(
            color: _signColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
        ),
      ),
    ),
  ],
),


              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ContactFormPage()),
                  );
                },
                child: Text(localizations.translate('query_support'),
                    style: TextStyle(color: _signColor)),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPasswordLogin(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localizations.translate('login_other'),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _signColor)),
          const SizedBox(height: 16),

          TextField(
            controller: _mobileController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: localizations.translate('login'),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: _signColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: _signColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              hintText: localizations.translate('password'),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off,
                    color: _signColor),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: _signColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: _signColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),

          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ForgetPasswordPage()));
              },
              child: Text(localizations.translate('forgot_password') + '?',
                  style: TextStyle(color: _signColor, fontWeight: FontWeight.w500)),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _signColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              onPressed: _isLoginLoading ? null : _login,
              child: _isLoginLoading
                  ? const SizedBox(
                      width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Login",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildOtpLogin(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Login with OTP",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _signColor,
              )),
          const SizedBox(height: 16),

          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: localizations.translate('phone_number'),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: _signColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: _signColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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

          if (_showOtpSection) ...[
            const SizedBox(height: 18),
            Row(
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
                        borderSide: BorderSide(color: _signColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _signColor),
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
            ),

            const SizedBox(height: 10),

            _canResendOtp
                ? GestureDetector(
                    onTap: _isSendingOtp ? null : _generateOtp,
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
                    localizations
                        .translate('otp_resend')
                        .replaceAll('{seconds}', _countdown.toString()),
                    style: TextStyle(color: _signColor, fontSize: 12),
                  ),
          ],

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _signColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              onPressed: _otpGenerated
                  ? (_isOtpLoading ? null : _loginWithOtp)
                  : (_isSendingOtp ? null : _generateOtp),
              child: (_otpGenerated
                      ? _isOtpLoading
                      : _isSendingOtp)
                  ? const SizedBox(
                      width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      _otpGenerated
                          ? localizations.translate('login_otp')
                          : localizations.translate('get_otp'),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
