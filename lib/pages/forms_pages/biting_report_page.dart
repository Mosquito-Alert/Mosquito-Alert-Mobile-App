import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'adult_report_page.dart';
import 'components/biting_form.dart';
import 'components/biting_location_form.dart';

class BitingReportPage extends StatefulWidget {
  final Report editReport;
  final Function loadData;

  BitingReportPage({this.editReport, this.loadData});
  @override
  _BitingReportPageState createState() => _BitingReportPageState();
}

class _BitingReportPageState extends State<BitingReportPage> {
  PageController _pagesController;
  List<Widget> _formsRepot;
  String otherReport;
  bool seeButton = false;
  bool addMosquito = false;
  bool validContent = false;
  StreamController<bool> loadingStream = new StreamController<bool>.broadcast();
  StreamController<bool> validStream = new StreamController<bool>.broadcast();
  StreamController<double> percentStream =
      new StreamController<double>.broadcast();
  double index = 0;

  List<Map> displayQuestions = [
    {
      "question": {
        "id": 1,
        "text": {
          "en": "How many bites did you get?",
          "ca": "Quantes vegades t'han picat?",
          "es": "¿Cuantas veces te han picado?"
        }
      },
      "answers": [
        //Number of bites - value equals TOTAL number of bites
        {
          "id": 11,
          "text": {
            "en": "",
            "ca": "",
            "es": "",
          }
        }
      ]
    },
    {
      "question": {
        "id": 2,
        "text": {
          "en": "Where have you been bitten?",
          "ca": "On t'han picat?",
          "es": "¿Donde te han picado?"
        }
      },
      "answers": [
        //Bites by body are - value equals number of bites in each area, must be = to total number of bites
        {
          "id": 21,
          "text": {"en": "Head", "ca": "Cap", "es": "Cap"}
        },
        {
          "id": 22,
          "text": {
            "en": "Left arm",
            "ca": "Braç esquerre",
            "es": "Braç esquerre"
          }
        },
        {
          "id": 23,
          "text": {"en": "Right arm", "ca": "Braç dret", "es": "Braç dret"}
        },
        {
          "id": 24,
          "text": {"en": "Chest", "ca": "Tronc", "es": "Tronc"}
        },
        {
          "id": 25,
          "text": {
            "en": "Left leg",
            "ca": "Cama esquerra",
            "es": "Cama esquerra"
          }
        },
        {
          "id": 26,
          "text": {"en": "Right leg", "ca": "Cama dreta", "es": "Cama dreta"}
        }
      ]
    },
    {
      "question": {
        "id": 4,
        "text": {
          "en": "Were you indoors or outdoors when you were bitten?",
          "ca": "Estaves a dins o a fora quan et van picar?",
          "es": "¿Estabas en el interior o en el exterior cuando te picaron?"
        }
      },
      "answers": [
        {
          "id": 41,
          "text": {
            "en": "Indoors",
            "ca": "A dins",
            "es": "Interior",
          }
        },
        {
          "id": 42,
          "text": {
            "en": "Outdoors",
            "ca": "A fora",
            "es": "Exterior",
          }
        },
        // {
        //   "id": 35,
        //   "text": {"en": "Not sure", "ca": "No ho tinc clar"}
        // }
      ]
    },
    {
      "question": {
        "id": 13,
        "text": {
          "en": "When did the mosquiti bite you?",
          "ca": "Quan et va picar el mosquit?",
          "es": "¿Cuando te picó el mosquito?"
        }
      },
      "answers": [
        {
          "id": 131,
          "text": {
            "en": "Just now",
            "ca": "Ara mateix",
            "es": "Ahora mismo",
          }
        },
        {
          "id": 132,
          "text": {
            "en": "in the last 24h",
            "ca": "Les darreres 24h",
            "es": "Las ultimas 24h",
          }
        },
      ]
    },
    {
      "question": {
        "id": 3,
        "text": {
          "en": "At what time of the day were you bitten?",
          "ca": "A quina hora et van picar?",
          "es": "¿A que hora te picaron?"
        }
      },
      "answers": [
        {
          "id": 31,
          "text": {
            "en": "Sunrise",
            "ca": "Sortida de sol",
            "es": "Salida del sol",
          }
        },
        {
          "id": 32,
          "text": {
            "en": "Mid-day",
            "ca": "Migdia",
            "es": "Mediodía",
          }
        },
        {
          "id": 33,
          "text": {
            "en": "Sunset",
            "ca": "Posta de sol",
            "es": 'Puesta de sol',
          }
        },
        {
          "id": 34,
          "text": {
            "en": "Night",
            "ca": "Nit",
            "es": "Noche",
          }
        },
        // {
        //   "id": 35,
        //   "text": {"en": "Not sure", "ca": "No ho tinc clar"}
        // }
      ]
    },
    {
      "question": {
        "id": 6,
        "text": {
          "en": "Where were you when you were bitten?",
          "ca": "On estaves quan et van picar?",
          "es": "On estaves quan et van picar?"
        }
      },
      "answers": [
        {
          "id": 61, //Location - value equals WKT of point
          "text": {"en": "", "ca": ""}
        }
      ]
    },
    {
      "question": {
        "id": 11,
        "text": {
          "en": "Did you see any of the mosquitoes that have bitten you?",
          "ca": "Has vist algun dels mosquits que t'han picat?",
          "es": "¿Has visto alguno de los mosquitos que te han picado?"
        }
      },
      "answers": [
        {
          "id": 101,
          "text": {"en": "Yes", "ca": "Sí", "es": "Si"}
        },
        {
          "id": 81,
          "text": {"en": "No", "ca": "No", "es": "No"}
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editReport != null) {
      Utils.setEditReport(widget.editReport);
    }
    _pagesController = PageController();
    _formsRepot = [
      BitingForm([
        displayQuestions.elementAt(0),
        displayQuestions.elementAt(1),
        displayQuestions.elementAt(2),
        displayQuestions.elementAt(3),
        displayQuestions.elementAt(4),
      ], setValid, goNextPage),
      BitingLocationForm(
        setValid,
        displayQuestions.elementAt(5)['question']['text'][Utils.getLanguage()],
      ),
      // CouldSeeForm(addAdultReport, displayQuestions.elementAt(6), setValid),
      AddOtherReportPage(_saveData, setValid, percentStream),
    ];

    // if (widget.editReport != null ||
    //     Utils.reportsList.isNotEmpty && Utils.reportsList.length == 1) {
    //   _formsRepot.removeAt(2);
    // }
  }

  addOtherReport(String reportType) {
    setState(() {
      otherReport = reportType;
    });
  }

  addAdultReport(addReport) {
    setState(() {
      addMosquito = addReport;
    });
  }

  setValid(isValid) {
    validStream.add(isValid);
  }

  _saveData() async {
    setState(() {
      percentStream.add(0.8);
    });
    loadingStream.add(true);
    bool res = await Utils.createReport();

    if (widget.editReport != null) {
      widget.loadData();
    }
    if (!res) {
      _showAlertKo();
    } else {
      _showAlertOk();
      setState(() {
        percentStream.add(1.0);
      });
    }
  }

  goNextPage() {
    _pagesController
        .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
        .then((value) {
      setState(() {
        seeButton = true;
      });
    });
    setState(() {
      index = _pagesController.page + 1;
    });
  }

  @override
  void dispose() {
    _pagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onWillPop();
        return false;
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              leading: IconButton(
                icon: Style.iconBack,
                onPressed: () {
                  double currentPage = _pagesController.page;

                  if (currentPage == 0.0) {
                    if (Utils.reportsList != null &&
                        Utils.reportsList.isNotEmpty &&
                        widget.editReport == null) {
                      Utils.deleteLastReport();
                    } else {
                      Utils.resetReport();
                    }

                    Navigator.pop(context);
                  } else if (currentPage == 1) {
                    _pagesController
                        .previousPage(
                            duration: Duration(microseconds: 300),
                            curve: Curves.ease)
                        .then((value) {});
                  } else {
                    addOtherReport(null);
                    _pagesController.previousPage(
                        duration: Duration(microseconds: 300),
                        curve: Curves.ease);
                  }
                  setState(() {
                    index = currentPage - 1;
                  });
                },
              ),
              title: Style.title(
                  MyLocalizations.of(context, "biting_report_txt"),
                  fontSize: 16),
              actions: <Widget>[],
            ),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                PageView(
                  controller: _pagesController,
                  physics: NeverScrollableScrollPhysics(),
                  children: _formsRepot,
                ),
                index == 0.0
                    ? Container()
                    : index != _formsRepot.length.toDouble() - 1
                        ? SafeArea(
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: StreamBuilder<bool>(
                                    stream: validStream.stream,
                                    initialData: false,
                                    builder: (BuildContext ctxt,
                                        AsyncSnapshot<bool> snapshot) {
                                      return snapshot.data
                                          ? Container(
                                              width: double.infinity,
                                              height: 54,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 6, horizontal: 12),
                                              child: Style.button(
                                                  MyLocalizations.of(
                                                      context, "continue_txt"),
                                                  () {
                                                double currentPage =
                                                    _pagesController.page;

                                                if (currentPage == 2 &&
                                                    addMosquito) {
                                                  Utils.addOtherReport('adult');
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AdultReportPage()),
                                                  );
                                                } else {
                                                  setState(() {
                                                    index = currentPage + 1;
                                                  });
                                                  _pagesController
                                                      .nextPage(
                                                          duration: Duration(
                                                              microseconds:
                                                                  300),
                                                          curve: Curves.ease)
                                                      .then((value) => setValid(
                                                          widget.editReport !=
                                                              null));
                                                }
                                              }),
                                            )
                                          : Container(
                                              width: double.infinity,
                                              height: 54,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 6, horizontal: 12),
                                              child: Style.button(
                                                  MyLocalizations.of(
                                                      context, "continue_txt"),
                                                  null),
                                            );
                                    })),
                          )
                        : Container(
                            width: double.infinity,
                            height: 54,
                            margin: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            child: Style.button(
                              MyLocalizations.of(context, "send_data"),
                              () {
                                _saveData();
                              },
                            ),
                          ),
              ],
            ),
          ),
          StreamBuilder<bool>(
            stream: loadingStream.stream,
            initialData: false,
            builder: (BuildContext ctxt, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData == false || snapshot.data == false) {
                return Container();
              }
              return Utils.loading(
                snapshot.data,
              );
            },
          )
        ],
      ),
    );
  }

  _showAlertOk() {
    loadingStream.add(false);
    Utils.showAlert(
      MyLocalizations.of(context, "app_name"),
      MyLocalizations.of(context, 'save_report_ok_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        if (widget.editReport != null) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      barrierDismissible: false,
    );
  }

  _showAlertKo() {
    loadingStream.add(false);
    Utils.showAlert(
      MyLocalizations.of(context, "app_name"),
      MyLocalizations.of(context, 'save_report_ko_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        if (widget.editReport != null) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      barrierDismissible: false,
    );
  }

  _onWillPop() {
    Utils.showAlertYesNo(MyLocalizations.of(context, 'app_name'),
        MyLocalizations.of(context, 'close_report_no_save_txt'), () {
      if (Utils.reportsList != null && Utils.reportsList.isNotEmpty) {
        Utils.deleteLastReport();
      } else {
        Utils.resetReport();
        Utils.imagePath = null;
      }
      Navigator.pop(context);
    }, context);
  }
}
