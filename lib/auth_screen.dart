import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 70),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/buntslogo.jpg',
                height: screenHeight * 0.2,
                width: screenHeight * 1,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: [
                  LoginWithPassword(),
                  LoginWithOTP(),
                ],
              ),
            ),
            // 🔹 Toggle Switch (replaces SmoothPageIndicator)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 100),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Color(0xFFea4a57))),
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
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _currentIndex == 0
                              ? const Color(
                                  0xFFea4a57) // same as your theme color
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            "Password",
                            style: TextStyle(
                                color: _currentIndex == 0
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
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
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _currentIndex == 1
                              ? const Color(0xFFea4a57)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            "OTP",
                            style: TextStyle(
                                color: _currentIndex == 1
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w800,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Don’t have an account? "),
                Text("Sign Up",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
/*return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                children: [
                  LoginWithPassword(),
                  LoginWithOTP(),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SmoothPageIndicator(
              controller: _controller,
              count: 2,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                spacing: 8,
                activeDotColor: Colors.redAccent,
                dotColor: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );*/

class LoginWithPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Positioned(
        //   top: -80,
        //   left: -80,
        //   child: Container(
        //     width: 250,
        //     height: 250,
        //     decoration: const BoxDecoration(
        //       shape: BoxShape.circle,
        //       gradient: LinearGradient(
        //         colors: [Color(0xFFea4a57), Color(0xFFea4a57)],
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //       ),
        //     ),
        //   ),
        // ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Login",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFea4a57),
                  )),
              const SizedBox(height: 20),
              customField("Enter phone number / Matri ID"),
              const SizedBox(height: 15),
              customField("Enter password", obscureText: true),
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // Aligns to right
                children: const [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Center(
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFea4a57), Color(0xFFea4a57)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

Widget customField(String hint, {bool obscureText = false}) {
  return TextField(
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: Color(0xFFea4a57),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: Color(0xFFea4a57),
        ),
      ),
    ),
  );
}

class LoginWithOTP extends StatefulWidget {
  @override
  State<LoginWithOTP> createState() => _LoginWithOTPState();
}

class _LoginWithOTPState extends State<LoginWithOTP> {
  bool showOtpField = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Login with OTP",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFea4a57),
              )),
          const SizedBox(height: 20),
          customField("Enter phone number"),
          const SizedBox(height: 20),
          if (showOtpField)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (i) => SizedBox(
                  width: 55,
                  child: TextField(
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(counterText: ''),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              setState(() {
                showOtpField = true;
              });
            },
            child: Container(
              width: 180,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFea4a57),
                    Color(0xFFea4a57),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  showOtpField ? "Verify OTP" : "Request OTP",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
