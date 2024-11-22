import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/main/home_page.dart';
import 'package:mosquito_alert_app/pages/map/public_map.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/my_reports_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/settings_page.dart';


class NewUIDesign extends StatefulWidget {
  @override
  _NewUIDesignState createState() => _NewUIDesignState();
}

class _NewUIDesignState extends State<NewUIDesign> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = <Widget>[
    HomePage(),
    PublicMap(),
    MyReportsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, -4),
                blurRadius: 8,
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.black),
                activeIcon: Icon(Icons.home, color: Colors.orange),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map, color: Colors.black),
                activeIcon: Icon(Icons.map, color: Colors.orange),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.file_copy, color: Colors.black),
                activeIcon: Icon(Icons.file_copy, color: Colors.orange),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.black),
                activeIcon: Icon(Icons.person, color: Colors.orange),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.grey[350],
          ),
        ),
      ),
    );
  }
}
