import 'package:flutter/material.dart';
import 'package:buntsmatrimony/lang.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Color(0xFFea4a57),
      onTap: onTap, // Calls the function from the controller
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: (localizations.translate('dashboard')).toString(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: ((localizations.translate('matches')).toString()),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_outlined),
          label: (localizations.translate('chat')).toString(),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: (localizations.translate('search')).toString(),
        ),
      ],
    );
  }
}
