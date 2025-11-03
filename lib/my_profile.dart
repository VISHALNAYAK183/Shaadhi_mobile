import 'package:flutter/material.dart';

class MyProfileUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF283593);
    final Color textColor = Color(0xFF333333);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(primaryColor),
            SizedBox(height: 20),
            _buildSection(
              title: 'Self',
              content: Column(
                children: [
                  _buildProfileImageSection(),
                  _buildField('Name:', 'John Doe'),
                  _buildField('Age:', '28'),
                  // Add other fields...
                ],
              ),
              primaryColor: primaryColor,
            ),
            // Add other sections...
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(primaryColor),
    );
  }

  Widget _buildProfileHeader(Color primaryColor) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage('assets/images/profile_icon.png'),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile For:',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    Text('John Doe',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 75,
          backgroundImage: AssetImage('assets/images/profile_photo.jpg'),
        ),
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                spreadRadius: 2,
              )
            ],
          ),
          child: Icon(Icons.edit, color: Colors.blue[800], size: 24),
        ),
      ],
    );
  }

  Widget _buildSection(
      {required String title,
      required Widget content,
      required Color primaryColor}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Icon(Icons.edit, color: primaryColor),
              ],
            ),
            Divider(color: Colors.grey[300]),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color:  Color(0xFF2d2d2d),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color:  Color(0xFF2d2d2d)),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavBar(Color primaryColor) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Matches'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    );
  }
}
