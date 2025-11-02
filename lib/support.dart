import 'package:flutter/material.dart';
import 'package:practice/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practice/api_service.dart'; 
import 'package:practice/dashboard_model.dart'; 
class ContactFormPage extends StatefulWidget {
  @override
  _ContactFormPageState createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  Color appcolor = Color(0xFFC3A38C);
  final TextEditingController _nameController = TextEditingController();
   final TextEditingController _matriController= TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _issuesController = TextEditingController();
  final Color _signColor = Color(0xFFC3A38C);
  bool _isLoading = false;
  List<supportnumberdata> _supportNumbers=[];


void initState(){
  super.initState();
  _fetchSupportNumbers();
}
 Future<void> _fetchSupportNumbers() async {
    try {
      List<supportnumberdata> numbers = await ApiService.fetchsupportnumber();
      setState(() {
        _supportNumbers = numbers;
      });
    } catch (e) {
      print("Error fetching support numbers: $e");
    }
  }
  Future<void> _submitForm() async {
    var localizations = AppLocalizations.of(context);
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _issuesController.text.length < 10) {
      _showAlert("", localizations.translate('fill_info'));
      return;
    }

    setState(() => _isLoading = true);

    try {

      // API call
      AddTicket response = await ApiService.fetchAddTicketData(
        _nameController.text,
         _matriController.text,
        _phoneController.text,
       
        _issuesController.text,
      );

      setState(() => _isLoading = false);

      if (response.message.isNotEmpty) {
         _nameController.clear();
      _matriController.clear();
      _phoneController.clear();
      _issuesController.clear();
        _showAlert(localizations.translate('success'), localizations.translate('success_msg'));
      } else {
        _showAlert(localizations.translate('failed'), localizations.translate('failure_msg'));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showAlert("Error", "Failed to connect. Please try again.");
    }
  }

  void _showAlert(String title, String message) {
    var localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
         appBar: AppBar(
          backgroundColor: appcolor,
          title: Text(
            localizations.translate('support'),
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
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          localizations.translate('contact_us'),
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 20),
                      buildTextField('${localizations.translate('name')} *', controller: _nameController ),
                      buildTextField('${localizations.translate('phone_number')} *', controller: _phoneController, keyboardType: TextInputType.phone),
                        buildTextField('${localizations.translate('matri_id')} *', controller: _matriController),
                      buildTextField('${localizations.translate('name')} * ${localizations.translate('min_char')}', controller: _issuesController, maxLines: 4),
                      SizedBox(height: 10),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFC3A38C),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  localizations.translate('submit'),
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          localizations.translate('support_contact'),
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(localizations.translate('taralabalu'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('${localizations.translate('phone')}95356 06101 '),
                      // Text("Phone: 87624 19927"),
                      // Text("Phone: 96327 10656"),
                        ..._supportNumbers.map((number) => Text('${localizations.translate('phone')}${number.phone}')).toList(), 
                     
                      SizedBox(height: 10),
                      Text(localizations.translate('tb_address')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label,
      {TextEditingController? controller, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }
}
