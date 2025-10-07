import 'package:flutter/material.dart';
import 'package:practice/lang.dart';
import 'package:practice/main_screen.dart';
import 'api_service.dart';
import 'dashboard_model.dart';
class BlockReportCard extends StatefulWidget {
  final String matriIdTo;

  const BlockReportCard({super.key, required this.matriIdTo});

  @override
  _BlockReportCardState createState() => _BlockReportCardState();
}

class _BlockReportCardState extends State<BlockReportCard> {
  String _selectedOption = "Block"; // Default selection
  bool isExpanded = false;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _handleSubmit() async {
    String comment = _commentController.text;

    // Get matriIdTo passed from ProfilePage
    String matriIdTo = widget.matriIdTo;

    // Call the API service for reporting or blocking
    try {
      Block blockResponse = await ApiService.fetchBlockData(matriIdTo, comment);
      //print("Hlo ${matriIdTo}");
      // Handle the response, show success message, or further logic
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(blockResponse.message)),
        
      );
          Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(),
                ),
              );
    } catch (e) {
      // Handle failure scenario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 4.0, horizontal: 8.0), // Reduced padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.black,
                  size: 20,
                ),
                SizedBox(width: 6),
                Text(
                  localizations.translate('info'),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ],
            ),
          ),

          // Animated Expandable Content
          AnimatedSize(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${localizations.translate('block')}:',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold), // Bold "Block"
                          ),
                          TextSpan(
                            text:
                                localizations.translate('block_user'),
                            style: TextStyle(fontSize: 13), // Normal text
                          ),
                          TextSpan(
                            text: '${localizations.translate('report')}:',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold), // Bold "Report"
                          ),
                          TextSpan(
                            text:
                                localizations.translate('report_user'),
                            style: TextStyle(fontSize: 13), // Normal text
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink(), // Hide content when collapsed
          ),
          Row(
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: "Block",
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value!;
                      });
                    },
                    activeColor: Colors.redAccent,
                  ),
                  Text(localizations.translate('block')),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: "Report",
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value!;
                      });
                    },
                    activeColor: Colors.redAccent,
                  ),
                  Text(localizations.translate('report')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 1), // Reduced height
          Text(
            localizations.translate('comment'),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 1), // Reduced height
          TextField(
            controller: _commentController,
            maxLines: 1, // Reduced height
            decoration: InputDecoration(
              hintText: localizations.translate('reason'),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 10.0), // Compact padding
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(6.0)), // Smaller border radius
            ),
          ),
          const SizedBox(height: 1), // Reduced height
          SizedBox(
            width: double.infinity,
            height: 36, // Reduced button height
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8A2727),
                padding: const EdgeInsets.symmetric(
                    vertical: 2.0), // Reduced button padding
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0)),
              ),
              child: Text(localizations.translate('submit'),
                  style: TextStyle(fontSize: 13,color: Colors.white)), // Slightly smaller text
            ),
          ),
        ],
      ),
    );
  }
}
