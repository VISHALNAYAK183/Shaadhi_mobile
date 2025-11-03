import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

final Color _signColor = Color(0xFFea4a57);

Widget customElevatedButton(VoidCallback onPressed, String label) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: const Color(0xFFea4a57),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: Text(label, style: const TextStyle(color: Colors.white)),
  );
}

Widget customTextButton(VoidCallback onPressed, String label) {
  return TextButton(
    onPressed: onPressed,
    child: Text(
      label,
      style: TextStyle(
        fontSize: 16,
        color: _signColor,
        decoration: TextDecoration.underline,
        decorationColor: _signColor,
        decorationThickness: 2,
      ),
    ),
  );
}

Widget buildTextField(
  String label,
  TextEditingController controller, {
  TextInputType keyboardType = TextInputType.text,
  bool readOnly = false,
  VoidCallback? onTap,
  int maxLines = 1,
  String? errorText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(fontSize: 16, color: _signColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 16, color: _signColor),
          border: OutlineInputBorder(),
          errorText:
              (errorText != null && errorText.isNotEmpty) ? errorText : null,
          errorStyle: TextStyle(color: _signColor, fontSize: 14),
        ),
      ),
      SizedBox(height: 10),
    ],
  );
}

Widget buildDropdown(String label, List<String> options, String? selectedValue,
    Function(String?) onChanged,
    {String? errorText, bool? isEnabled}) {
  TextEditingController searchController = TextEditingController();

  return Padding(
    padding: const EdgeInsets.only(bottom: 1),
    child: DropdownButtonFormField2<String>(
      isExpanded: true,
      value: selectedValue != null && options.contains(selectedValue)
          ? selectedValue
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 16, color: _signColor),
        border: OutlineInputBorder(),
        errorText: errorText,
        helperText: errorText == null ? " " : null,
        helperStyle: const TextStyle(height: 0.7),
      ),
      items: options.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item,
              style: const TextStyle(fontSize: 16, color: Colors.blueAccent)),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownSearchData: DropdownSearchData(
        searchController: searchController,
        searchInnerWidgetHeight: 50,
        searchInnerWidget: Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        searchMatchFn: (item, searchValue) {
          return item.value!.toLowerCase().contains(searchValue.toLowerCase());
        },
      ),
      selectedItemBuilder: (context) {
        return options.map((item) {
          return Text(
            item,
            style: TextStyle(fontSize: 16, color: _signColor),
          );
        }).toList();
      },
    ),
  );
}

void showCustomDialog({
  required BuildContext context,
  required String title,
  required List<String> options,
  required List<String> selectedValues,
  required Function(List<String>) onSelected,
}) {
  List<String> tempSelectedValues = List.from(selectedValues);
  List<String> filteredOptions = List.from(options);
  TextEditingController searchController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          void _filterOptions(String query) {
            setDialogState(() {
              filteredOptions = options
                  .where((option) =>
                      option.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            });
          }

          searchController.addListener(() {
            _filterOptions(searchController.text);
          });

          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterOptions,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: filteredOptions.map((option) {
                        return CheckboxListTile(
                          title: Text(
                            option,
                            style: const TextStyle(
                                color: Colors.blueAccent, fontSize: 16),
                          ),
                          value: tempSelectedValues.contains(option),
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                tempSelectedValues.add(option);
                              } else {
                                tempSelectedValues.remove(option);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE"),
              ),
              TextButton(
                onPressed: () {
                  onSelected(tempSelectedValues);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    },
  );
}
