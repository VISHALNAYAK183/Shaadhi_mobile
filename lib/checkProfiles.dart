import 'package:flutter/material.dart';
import 'package:buntsmatrimony/api_service.dart';
import 'package:buntsmatrimony/inapp/subscription_list_screen.dart';
import 'package:buntsmatrimony/lang.dart';
import 'package:buntsmatrimony/main.dart';
import 'package:buntsmatrimony/payment_gateway.dart';
import 'package:buntsmatrimony/profile_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaxLimit {
  checkProfileView(String candidateId, BuildContext context) async {
    if (!context.mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String max = prefs.getString('maxProfile') ?? "0";
    String used = prefs.getString('usedProfile') ?? "0";
    String planStatus = prefs.getString('planStatus') ?? "";
    String getResponse = "E";

    int maxProfile = int.tryParse(max) ?? 0;
    int usedProfile = int.tryParse(used) ?? 0;

    planStatus = planStatus.toLowerCase();

    if (planStatus == "expired") {
      print("expired");
      getResponse = await masterCount(candidateId, "profile");
    }

    if (planStatus == "paid" || planStatus == "not paid") {
      if (maxProfile > usedProfile) {
        getResponse = await profileViewed(candidateId, context);
      } else {
        getResponse = await masterCount(candidateId, "profile");
      }
    }
    if (!context.mounted) return; // Check again before using context

    if (getResponse == 'Y') {
      showProfiles(candidateId, context);
    } else if (getResponse == 'N') {
      showSubscriptionDialog(context);
    } else {}
  }

  Future<String> checkContactedProfiles(
    String candidateId,
    BuildContext context,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String max = prefs.getString('maxContact').toString();
    String used = prefs.getString('usedContact').toString();
    String planStatus = prefs.getString('planStatus').toString();

    int maxProfile = int.tryParse(max) ?? 0;
    int usedProfile = int.tryParse(used) ?? 0;

    planStatus = planStatus.toLowerCase();

    if (planStatus == "expired") {
      print("expired");
      return await masterCount(candidateId, "contact");
    }

    if (planStatus == "paid" || planStatus == "not paid") {
      if (maxProfile > usedProfile) {
        print("$planStatus maxProfile > usedProfile");
        return await contactViewed(candidateId, context);
      } else {
        print("$planStatus maxProfile < usedProfile");
        return await masterCount(candidateId, "contact");
      }
    }
    print("else3");
    return "N";
  }

  Future<void> setCounts(Map<String, dynamic> getProfileData) async {
    print("getProfileData $getProfileData");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'usedProfile',
      (getProfileData["profile_viewed"]).toString(),
    );
    await prefs.setString(
      'usedMessage',
      getProfileData["message_viewed"].toString(),
    );
    await prefs.setString(
      'usedContact',
      getProfileData["contact_viewed"].toString(),
    );

    await prefs.setString(
      'maxProfile',
      (getProfileData["max_profile"]).toString(),
    );
    await prefs.setString(
      'maxMessage',
      getProfileData["max_contact"].toString(),
    );
    await prefs.setString(
      'maxContact',
      getProfileData["max_message"].toString(),
    );
  }

  Future<String> masterCount(String candidateId, String type) async {
    print("max reached checkig for viewed before");
    Map<String, dynamic> response = await ApiService.masterCount(
      candidateId,
      type,
    );
    if (response.containsKey('message')) {
      var messageData = response['message'];
      String? statusFlag = '';
      if (messageData is Map<String, dynamic>) {
        statusFlag = messageData['p_out_mssg_flg']?.toString();
        String? messageText = messageData['p_out_mssg']?.toString();

        if (statusFlag == "Y") {
          if (response["type_count"] is List &&
              response["type_count"].isNotEmpty) {
            dynamic getProfileData = response;
            getProfileData = getProfileData['master_count'][0];
            print("getProfileData--++ ${response['master_count'][0]}");
            await setCounts(getProfileData);
            if (response["type_count"][0]['used_count'].toString() == "1") {
              return "Y";
            } else {
              return "N";
            }
          }
          return "E - flag Y but improper data";
        } else {
          return "E - flag N";
        }
      } else {
        return 'E - invalid format';
      }
    } else {
      return 'E - no message';
    }
  }

  Future<String> profileViewed(String candidateId, BuildContext context) async {
    Map<String, dynamic> response = await ApiService.profileViewed(
      candidateId,
      context,
    );

    if (response.containsKey('message')) {
      var messageData = response['message'];

      String? statusFlag = '';
      if (messageData is Map<String, dynamic>) {
        statusFlag = messageData['p_out_mssg_flg']?.toString();
        String? messageText = messageData['p_out_mssg']?.toString();

        if (statusFlag == "Y") {
          if (response["dataout"] is List && response["dataout"].isNotEmpty) {
            print("getProfileData--++ ${response['dataout'][0]}");
            dynamic getProfileData = response['dataout'][0];
            getProfileData = {
              "profile_viewed": getProfileData['viewed_count'],
              "contact_viewed": getProfileData['contact_count'],
              "message_viewed": getProfileData['message_count'],
              "max_profile": getProfileData['max_profile'],
              "max_contact": getProfileData['max_contact'],
              "max_message": getProfileData['max_message'],
            };

            await setCounts(getProfileData);
          }
          return "Y";
        } else {
          return "N - flag N";
        }
      } else {
        return 'E - invalid format';
      }
    } else {
      return 'E - no message';
    }
  }

  Future<String> contactViewed(String candidateId, BuildContext context) async {
    print("contact viewed");
    Map<String, dynamic> response = await ApiService.contactViewed(
      context,
      candidateId,
    );

    if (response.containsKey('message')) {
      var messageData = response['message'];
      String? statusFlag = '';
      if (messageData is Map<String, dynamic>) {
        statusFlag = messageData['p_out_mssg_flg']?.toString();
        String? messageText = messageData['p_out_mssg']?.toString();

        print("Status Flag: $statusFlag");
        print("Message Text: $messageText");

        if (statusFlag == "Y") {
          if (response["dataout"] is List && response["dataout"].isNotEmpty) {
            print("getProfileData--++ ${response['dataout'][0]}");
            dynamic getProfileData = response['dataout'][0];
            getProfileData = {
              "profile_viewed": getProfileData['viewed_count'],
              "contact_viewed": getProfileData['contact_count'],
              "message_viewed": getProfileData['message_count'],
              "max_profile": getProfileData['max_profile'],
              "max_contact": getProfileData['max_contact'],
              "max_message": getProfileData['max_message'],
            };
            print("getProfileData--++$getProfileData");
            await setCounts(getProfileData);
          }
          return "Y";
        } else {
          return "N - flag N";
        }
      } else {
        return 'N - invalid format';
      }
    } else {
      return 'N - no message';
    }
  }

  showProfiles(String profileId, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage(matriId: profileId)),
    );
  }

  showSubscriptionDialog(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('buy_premium')),
          content: Text(localizations.translate('need_premium')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(localizations.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionPaymentPage(),
                  ),
                );
              },
              child: Text(localizations.translate('subscribe_now')),
            ),
          ],
        );
      },
    );
  }
}
