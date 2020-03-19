import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'components/reports_list_widget.dart';

class MyReportsPage extends StatefulWidget {
  @override
  _MyReportsPageState createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  int _currentIndex = 0;

  Map<int, Widget> _children = {
    0: Container(
      child: Text('Mapa'),
    ),
    1: Container(
      child: Text('Lista'),
    ),
  };

  StreamController<int> selectedIndexStream =
      new StreamController<int>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<int>(
            stream: selectedIndexStream.stream,
            initialData: 0,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return Stack(
                children: <Widget>[
                  snapshot.hasData
                      ? snapshot.data == 0
                          ? Container(
                              color: Colors.green,
                            )
                          : Container(margin: EdgeInsets.only(top: 110),child: ReportsList())
                      : Container(
                          color: Colors.blue,
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
                                Style.title("Tus reportes"),
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
