import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/components/my_reports_map.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'components/reports_list_widget.dart';

class MyReportsPage extends StatefulWidget {
  @override
  _MyReportsPageState createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  int _currentIndex = 0;

  Map<int, Widget> _children;

  StreamController<int> selectedIndexStream =
      new StreamController<int>.broadcast();

  @override
  Widget build(BuildContext context) {
    _children = {
      0: Container(
        child: Text(MyLocalizations.of(context, "map_txt")),
      ),
      1: Container(
        child: Text(MyLocalizations.of(context, "list_txt")),
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<int>(
            stream: selectedIndexStream.stream,
            initialData: 0,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 100),
                    child: snapshot.hasData
                        ? snapshot.data == 0 ? MyReportsMap() : ReportsList()
                        : Container(
                            color: Colors.blue,
                          ),
                  ),
                  Container(
                    child: Card(
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      color: Colors.white,
                      elevation: 2,
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.arrow_back),
                                ),
                                Style.title(MyLocalizations.of(
                                    context, "your_reports_txt")),
                                SizedBox(
                                  width: 40,
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 15),
                              width: double.infinity,
                              child: MaterialSegmentedControl(
                                children: _children,
                                selectionIndex: snapshot.data,
                                borderColor: Style.colorPrimary,
                                selectedColor: Style.colorPrimary,
                                unselectedColor: Colors.white,
                                borderRadius: 5.0,
                                onSegmentChosen: (index) {
                                  _onItemTapped(index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  void _onItemTapped(int index) {
    _currentIndex = index;
    selectedIndexStream.add(_currentIndex);
  }
}
