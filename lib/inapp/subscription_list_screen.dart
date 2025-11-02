import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:practice/api_service.dart';
import 'package:practice/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isFeatureUnlocked = false;
  bool _isLoading = false;
  Color appcolor = Color(0xFFC3A38C);

  @override
  void initState() {
    super.initState();
    _initializeIAP();
    _subscription = _iap.purchaseStream.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    }, onError: (error) {
      print("⚠️ Error in purchase stream: $error");
    });
  }

  // Fetch products on screen load
  Future<void> _initializeIAP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseurl = prefs.getString("base_url").toString();
    int retryCount = 0;
    while (baseurl == null || baseurl.isEmpty) {
      baseurl = prefs.getString("base_url").toString();
      retryCount++;

      if (retryCount > 5) {
        print("Failed to retrieve baseUrl after multiple attempts.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await Future.delayed(Duration(milliseconds: 500)); // Wait before retrying
    }
    final matchedData = await ApiService.getInappProduct('app_store');

// Print the entire response
    print(matchedData);

    List<dynamic> dataout = matchedData['dataout'];
    print(dataout);

    Set<String> ids = {};

    dataout.forEach((plan) {
      print(plan['plan_name'].toString());
      ids.add(plan['plan_name'].toString());
    });

    final bool available = await _iap.isAvailable();
    if (!available) {
      print("⚠️ In-App Purchases not available");
      return;
    }

    // Replace with actual product ID
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      print("⚠️ Products not found: ${response.notFoundIDs}");
    } else {
      setState(() {
        _products = response.productDetails;
      });
    }
  }

  // Trigger on page load to ensure data is fetched when returning
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_products.isEmpty) {
      _initializeIAP(); // Ensure data is loaded when returning from another screen
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    print("_handlePurchaseUpdates");
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        print("⏳ Purchase Pending...");
        _verifyPurchase(purchase);
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        print("⏳ Purchase Paid...");
        _verifyPurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        print("❌ Purchase Error: ${purchase.error?.message}");
        if (purchase.error?.code == 'user_canceled') {
          print("❌ The user canceled the purchase.");
          _showCancelDialog((purchase.status)
              .toString()); // Show a cancel dialog or retry prompt.
        }
        _handlePurchaseError(purchase);
      } else if (purchase.status == PurchaseStatus.canceled) {
        _verifyPurchase(purchase);
        _showCancelDialog(('Cancelled').toString());
      } else {
        _verifyPurchase(purchase);
        _showCancelDialog((purchase.status).toString());
      }
    }
  }

  void _showCancelDialog(String status) {
    var localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status),
          content: Text(
              localizations.translate('retry_purchase')),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.translate('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseurl = prefs.getString("base_url");
    print("token $purchase");

    String? purchaseToken;
    if (purchase.verificationData.source == "google_play") {
      purchaseToken = purchase.verificationData.serverVerificationData;
    } else if (purchase.verificationData.source == "app_store") {
      purchaseToken = purchase.verificationData.localVerificationData;
    }

    var body = jsonEncode({
      "user_id": prefs.getString("matriId"),
      "purchase_token": purchaseToken,
      "product_id": purchase.productID,
      "platform": purchase.verificationData.source,
      "status": purchase.status.toString(),
      "title": purchase.productID,
      "transactionDate": purchase.transactionDate?.toString() ?? ""
    });

    print(body);

    final response = await http.post(
      Uri.parse('$baseurl/inappPurchase.php'),
      body: body,
      headers: {"Content-Type": "application/json"},
    );
    print(response.body);
    final result = jsonDecode(response.body);
    print(" Purchase Result !");
    print(result);
    print("❌ Purchase Result !");
    if (result["success"] == 'Y') {
      if (result["status"] == 'captured') {
        setState(() {
          _isFeatureUnlocked = true;
        });
      }
      _iap.completePurchase(purchase); // Mark the purchase as completed
      setState(() => _isLoading = false);
    } else {
      setState(() => _isLoading = false);
      print("❌ Purchase verification failed!");
    }
  }

  void _handlePurchaseError(PurchaseDetails purchase) {
    print("❌ Handling purchase error for ${purchase.productID}");
    // Optionally, show a message or take action depending on the error.
  }

  void _buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Pull-to-refresh handler
  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    // start();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          localizations.translate('plans'),
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  if (_products.isEmpty) Text(localizations.translate('no_products')),
                  ..._products.map((product) {
                    return ListTile(
                      title: Text(product.title),
                      subtitle: Text(product.price),
                      trailing: ElevatedButton(
                        onPressed: () => _buyProduct(product),
                        child: Text(localizations.translate('buy')),
                      ),
                    );
                  }),
                  // if (_isFeatureUnlocked)
                  //   Padding(
                  //     padding: EdgeInsets.all(20),
                  //     child: Text("🎉 Feature Unlocked!",
                  //         style: TextStyle(
                  //             fontSize: 18, fontWeight: FontWeight.bold)),
                  //   ),
                ],
              ),
      ),
    );
  }
}
