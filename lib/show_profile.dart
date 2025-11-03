import 'package:buntsmatrimony/dashboard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardStore {
  static DashboardData? dashboardData;
}

class PlanValidator {
  final DashboardData dashboardData;

  PlanValidator(this.dashboardData);

  Future<String> validateUserPlan(String userId) async {
    // Get myProfile list from loaded data
    List<Profile> myProfileList = dashboardData.myProfile;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? my_id = await prefs.getString('matriId');
    // Find the matching profile
    Profile? profile = myProfileList.firstWhere(
      (profile) => profile.myMatriId == my_id,
      // orElse: () => profile(planStatus: 'Not Paid', expiry_date: 'N/A'),
    );

    // Get plan status and subscription date
    String planStatus = profile.planStatus.toLowerCase();
    String subscriptionDate = profile.expiry_date;

    // Return status message
    if (planStatus == 'paid') {
      return 'Paid | Subscription Date: $subscriptionDate';
    } else if (planStatus == 'expired') {
      return 'Expired | Subscription Date: $subscriptionDate';
    } else {
      return 'Not Paid | Subscription Date: $subscriptionDate';
    }
  }
}
