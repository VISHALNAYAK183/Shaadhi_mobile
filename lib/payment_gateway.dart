import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupi.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfupipayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:practice/api_service.dart';
import 'package:practice/dashboard_model.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SubscriptionPaymentPage extends StatefulWidget {
  @override
  _SubscriptionPaymentPageState createState() =>
      _SubscriptionPaymentPageState();
}

class _SubscriptionPaymentPageState extends State<SubscriptionPaymentPage> {
  late Future<List<SubscriptionData>> subscriptionFuture;
  CFPaymentGatewayService cfPaymentGatewayService = CFPaymentGatewayService();
  CFEnvironment environment = CFEnvironment.PRODUCTION;

  var isLoading = false;
  String? selectedPlanId;
  String? selectedAmount;
  bool isPlanSelected = false;
  String orderId = "";
  String paymentSessionId = "";
  Color appcolor = Color(0xFF8A2727);

  @override
  void initState() {
    super.initState();

    cfPaymentGatewayService.setCallback(verifyPayment, onError);
    subscriptionFuture = ApiService.fetchSubscriptionData();
  }

  void verifyPayment(String orderId) async {
    print("SANDBOX${environment}");
    print("Payment Successful: Order ID: $orderId");
    try {
      Captured capturedResponse = await ApiService.fetchCapturedData(orderId);
      print("Transaction Updated Successfully: ${capturedResponse.message}");
      Alert(
        context: context,
        type: AlertType.success,
        title: "Payment Successful!",
        //desc: "Your transaction was completed successfully!",
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => Navigator.pop(context),
            color: Colors.green,
          ),
        ],
        style: AlertStyle(
          animationType: AnimationType.fromTop,
          isCloseButton: false,
          isOverlayTapDismiss: false,
          backgroundColor: Colors.white,
          titleStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          descStyle: TextStyle(fontSize: 16),
          alertBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ).show();
    } catch (e) {
      print("Error Updating Transaction: $e");
      Alert(
        context: context,
        type: AlertType.error, // Red Error Icon
        title: "Transaction Failed",
        desc: "Something went wrong. Please try again!",
        buttons: [
          DialogButton(
            child: Text(
              "Try Again",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => Navigator.pop(context),
            color: Colors.red,
          ),
        ],
        style: AlertStyle(
          animationType: AnimationType.fromTop,
          isCloseButton: false,
          isOverlayTapDismiss: false,
          backgroundColor: Colors.white,
          titleStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          descStyle: TextStyle(fontSize: 16),
          alertBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ).show();
    }
  }

  void onError(error, String orderId) {
    print("Payment Failed: $error");
    Alert(
      context: context,
      type: AlertType.error, // Red Error Icon
      title: "Transaction Failed",
      desc: "Something went wrong. Please try again!",
      buttons: [
        DialogButton(
          child: Text(
            "Try Again",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.red,
        ),
      ],
      style: AlertStyle(
        animationType: AnimationType.fromTop,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        backgroundColor: Colors.white,
        titleStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        descStyle: TextStyle(fontSize: 16),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ).show();
  }

  CFSession? createSession() {
    try {
      CFSession session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();
      return session;
    } on CFException catch (e) {
      print("Session Creation Failed: ${e.message}");
      return null;
    }
  }

  void startWebCheckout() async {
    try {
      var session = createSession();
      if (session == null) return;
      CFTheme theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#000000")
          .setNavigationBarTextColor("#FFFFFF")
          .build();
      CFWebCheckoutPayment webCheckoutPayment = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .setTheme(theme)
          .build();
      cfPaymentGatewayService.doPayment(webCheckoutPayment);
    } catch (e) {
      print("Web Checkout Failed: $e");
    }
  }

  Future<void> getcfToken() async {
    try {
      Map<String, dynamic> response =
          await ApiService.fetchPaymentData(selectedPlanId!, selectedAmount!);
      PaymentData paymentData = PaymentData.fromJson(response);
        String backendEnvironment = response['environment'] ?? "SANDBOX";
        print("RESponse${ response['environment']}");
     
     environment = backendEnvironment.toUpperCase() == "PRODUCTION"
        ? CFEnvironment.PRODUCTION
        : CFEnvironment.SANDBOX;

      makePayment(paymentData.paymentSessionId, paymentData.orderId);
      print("SANDBOX${environment}");
    } catch (e) {
      print("API Call Failed: $e");
    }
  }

  makePayment(String paymentSessionID, String orderID) async {
    setState(() {
      isLoading = false;
    });
    orderId = orderID;
    paymentSessionId = paymentSessionID;
    startWebCheckout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          "Subscription & Payment",
          style: TextStyle(color: Colors.white),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
            child: Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 25), // Back button icon
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<SubscriptionData>>(
              future: subscriptionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No subscriptions available"));
                }
                List<SubscriptionData> subscriptions = snapshot.data!;
                return ListView.builder(
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final plan = subscriptions[index];
                    return ListTile(
                      title: Text(plan.planName,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text("₹${plan.amount}",
                          style: TextStyle(fontSize: 16, color: Colors.green)),
                      trailing: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedPlanId = plan.id;
                            selectedAmount = plan.amount.toString();
                            isPlanSelected = true;
                          });
                          if (isPlanSelected) {
                            getcfToken();
                          }
                        },
                        child: Text("Pay"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
