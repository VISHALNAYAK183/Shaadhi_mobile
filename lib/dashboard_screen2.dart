import 'package:flutter/material.dart';
import 'dashboard_model.dart';
import 'api_service.dart';

class DashboardScreen2 extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen2> {
  late Future<DashboardData> dashboardData;

  @override
  void initState() {
    super.initState();
    dashboardData =
        ApiService.fetchDashboardData(); // Call API once when screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: FutureBuilder<DashboardData>(
        future: dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}")); // Show error message
          } else if (!snapshot.hasData ||
              snapshot.data!.recentlyJoined.isEmpty) {
            return Center(child: Text("No users found"));
          }

          // Display user data in a ListView
          return ListView.builder(
            itemCount: snapshot.data!.recentlyJoined.length,
            itemBuilder: (context, index) {
              final user = snapshot.data!.recentlyJoined[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                      child: Text(user.name[0])), // Show first letter
                  title: Text(user.name),
                  subtitle: Text("Age: ${user.age}, :  ${user.matriId}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
