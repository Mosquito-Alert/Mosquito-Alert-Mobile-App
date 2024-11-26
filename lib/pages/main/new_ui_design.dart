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
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        child: BottomAppBar(
          color: Colors.grey[350],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildIconButton(Icons.home, 0),
              _buildIconButton(Icons.map, 1),
              _buildIconButton(Icons.file_copy, 2),
              _buildIconButton(Icons.person, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 30,
            color: _selectedIndex == index ? Colors.orange : Colors.black,
          ),
          SizedBox(height: 5),
          Container(
            width: 30,
            height: 2,
            color: _selectedIndex == index ? Colors.orange : Colors.transparent,
          )
        ],
      )
    );
  }
}
