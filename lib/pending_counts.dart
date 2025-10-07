import 'package:flutter/material.dart';
import 'package:practice/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingCountsPage extends StatefulWidget {
  @override
  _PendingCountsPageState createState() => _PendingCountsPageState();
}

class _PendingCountsPageState extends State<PendingCountsPage> {
  int maxViewed = 0;
  int maxContacted = 0;
  int maxMessaged = 0;
  int usedViewed = 0;
  int usedContacted = 0;
  int usedMessaged = 0;
  Color appcolor = Color(0xFF8A2727);

  @override
  void initState() {
    super.initState();
    _loadPendingCounts();
  }

  Future<void> _loadPendingCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      maxViewed = int.tryParse(prefs.getString('maxProfile') ?? '0') ?? 0;
      maxContacted = int.tryParse(prefs.getString('maxContact') ?? '0') ?? 0;
      maxMessaged = int.tryParse(prefs.getString('maxMessage') ?? '0') ?? 0;
      usedViewed = int.tryParse(prefs.getString('usedProfile') ?? '0') ?? 0;
      usedContacted = int.tryParse(prefs.getString('usedContact') ?? '0') ?? 0;
      usedMessaged = int.tryParse(prefs.getString('usedMessage') ?? '0') ?? 0;

      print('Max Viewed: $maxViewed, Max Contacted: $maxContacted, Max Messaged: $maxMessaged');

    });
  }

  int _calculatePending(int max, int used) => max > used ? max - used : 0;

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appcolor,
        title: Text(
          localizations.translate('pending_counts'),
          style: TextStyle(color: Colors.white), 
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 5, 0, 10),
            child: Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 25),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCountTile(localizations.translate('profile_count'), _calculatePending(maxViewed, usedViewed)),
            _buildCountTile(localizations.translate('contact_count'), _calculatePending(maxContacted, usedContacted)),
            _buildCountTile(localizations.translate('message_count'), _calculatePending(maxMessaged, usedMessaged)),
          ],
        ),
      ),
    );
  }

  Widget _buildCountTile(String title, int count) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          count.toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
