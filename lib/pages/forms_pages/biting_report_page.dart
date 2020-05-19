import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'adult_report_page.dart';
import 'breeding_report_page.dart';
import 'components/biting_form.dart';
import 'components/biting_logation_form.dart';

class BitingReportPage extends StatefulWidget {
  final Report editReport;
  final Function loadData;

  BitingReportPage({this.editReport, this.loadData});
  @override
  _BitingReportPageState createState() => _BitingReportPageState();
}

class _BitingReportPageState extends State<BitingReportPage> {
  final _pagesController = PageController();
  List _formsRepot;
  String otherReport;

  List<Map> displayQuestions = [
    // {
    //   "question": {
    //     "id": 1,
    //     "text": {
    //       "en": "How many bites did you get?",
    //       "ca": "Quantes vegades t'han picat?"
    //     }
    //   },
    //   "answers": [
    //     //Number of bites - value equals TOTAL number of bites
    //     {
    //       "id": 11,
    //       "text": {"en": "", "ca": ""}
    //     }
    //   ]
    // },
    // {
    //   "question": {
    //     "id": 2,
    //     "text": {"en": "Where have you been bitten?", "ca": "On t'han picat?"}
    //   },
    //   "answers": [
    //     //Bites by body are - value equals number of bites in each area, must be = to total number of bites
    //     {
    //       "id": 21,
    //       "text": {"en": "Head", "ca": "Cap"}
    //     },
    //     {
    //       "id": 22,
    //       "text": {"en": "Left arm", "ca": "Braç esquerre"}
    //     },
    //     {
    //       "id": 23,
    //       "text": {"en": "Right arm", "ca": "Braç dret"}
    //     },
    //     {
    //       "id": 24,
    //       "text": {"en": "Chest", "ca": "Tronc"}
    //     },
    //     {
    //       "id": 25,
    //       "text": {"en": "Left leg", "ca": "Cama esquerra"}
    //     },
    //     {
    //       "id": 26,
    //       "text": {"en": "Right leg", "ca": "Cama dreta"}
    //     }
    //   ]
    // },
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
    // {
    //   "question": {
    //     "id": 5,
    //     "text": {
    //       "en": "Where were you when you were bitten?",
    //       "ca": "On estaves quan et van picar?"
    //     }
    //   },
    //   "answers": [
    //     {
    //       "id": 51, //Location - value equals WKT of point
    //       "text": {"en": "", "ca": ""}
    //     }
    //   ]
    // }
  ];

  @override
  void initState() {
    if (widget.editReport != null) {
      Utils.setEditReport(widget.editReport);
    }
    super.initState();
  }

  addOtherReport(String reportType) {
    setState(() {
      otherReport = reportType;
    });
  }

  navigateOtherReport() {
    Utils.addOtherReport(otherReport);
    switch (otherReport) {
      case "bite":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BitingReportPage()),
        );
        break;
      case "site":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BreedingReportPage()),
        );
        break;
      case "adult":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdultReportPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _formsRepot = [
      BitingForm(displayQuestions),
      BitingLocationForm(),
      AddOtherReportPage(addOtherReport),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            double currentPage = _pagesController.page;
            if (currentPage == 0.0) {
              Utils.resetReport();
              Navigator.pop(context);
            } else {
              _pagesController.previousPage(
                  duration: Duration(microseconds: 300), curve: Curves.ease);
            }
          },
        ),
        title: Style.title(MyLocalizations.of(context, "biting_report_txt"),
            fontSize: 16),
        actions: <Widget>[
          Style.noBgButton(
              false //TODO: show finish in last page
                  ? MyLocalizations.of(context, "finish")
                  : MyLocalizations.of(context, "next"),
              true
                  ? () {
                      double currentPage = _pagesController.page;
                      if (currentPage == _formsRepot.length - 1) {
                        if (otherReport != null) {
                          navigateOtherReport();
                        } else {
                          Utils.createReport();
                          if (widget.editReport != null) {
                            widget.loadData();
                          }
                          Navigator.pop(context);
                        }
                      } else {
                        _pagesController.nextPage(
                            duration: Duration(microseconds: 300),
                            curve: Curves.ease);
                      }
                    }
                  : null)
        ],
      ),
      body: PageView.builder(
          controller: _pagesController,
          itemCount: _formsRepot.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _formsRepot[index];
          }),
    );
  }
}
