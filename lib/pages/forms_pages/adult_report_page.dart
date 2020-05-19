import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/could_see_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_parts_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_type_form.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'breeding_report_page.dart';
import 'components/biting_logation_form.dart';

class AdultReportPage extends StatefulWidget {
  final Report editReport;

  AdultReportPage({this.editReport});
  @override
  _AdultReportPageState createState() => _AdultReportPageState();
}

class _AdultReportPageState extends State<AdultReportPage> {
  final _pagesController = PageController();
  List _formsRepot;

  List<Map> displayQuestions = [
    {
      "question": {
        "id": 6,
        "text": {
          "en": "What kind of mosquito do you think it is?",
          "ca": "Quin tipus de mosquit creus que és?"
        }
      },
      "answers": [
        {
          "id": 61,
          "text": {"en": "Invasive Aedes", "ca": "Aedes Invasiu"}
        },
        {
          "id": 62,
          "text": {"en": "Common mosquito", "ca": "Mosquit comú"}
        },
        {
          "id": 63,
          "text": {"en": "Other", "ca": "Altres"}
        }
      ]
    },
    {
      "question": {
        "id": 7,
        "text": {
          "en": "How does your mosquito look?",
          "ca": "Quin aspecte té el teu mosquit?"
        }
      },
      "answers": [
        {
          "id": 711,
          "text": {"en": "Thorax 1", "ca": "Tòrax 1"}
        },
        {
          "id": 712,
          "text": {"en": "Thorax 2", "ca": "Tòrax 2"}
        },
        {
          "id": 713,
          "text": {"en": "Thorax 3", "ca": "Tòrax 3"}
        },
        {
          "id": 714,
          "text": {"en": "Thorax 4", "ca": "Tòrax 4"}
        },
        {
          "id": 721,
          "text": {"en": "Abdomen 1", "ca": "Abdomen 1"}
        },
        {
          "id": 722,
          "text": {"en": "Abdomen 2", "ca": "Abdomen 2"}
        },
        {
          "id": 723,
          "text": {"en": "Abdomen 3", "ca": "Abdomen 3"}
        },
        {
          "id": 724,
          "text": {"en": "Abdomen 4", "ca": "Abdomen 4"}
        },
        {
          "id": 731,
          "text": {"en": "3d leg 1", "ca": "3a cama 1"}
        },
        {
          "id": 732,
          "text": {"en": "3d leg 2", "ca": "3a cama 2"}
        },
        {
          "id": 733,
          "text": {"en": "3d leg 3", "ca": "3a cama 3"}
        },
        {
          "id": 734,
          "text": {"en": "3d leg 4", "ca": "3a cama 4"}
        }
      ]
    },
    {
      "question": {
        "id": 8,
        "text": {
          "en": "Did this mosquito bite you?",
          "ca": "T'ha picat el mosquit?"
        }
      },
      "answers": [
        {
          "id": 81,
          "text": {"en": "No", "ca": "No"}
        },
        {
          "id": 35,
          "text": {"en": "Not sure", "ca": "No ho tinc clar"}
        }
      ]
    }
  ];

  bool skip3 = false;
  bool addBiting = false;
  String otherReport;

  @override
  void initState() {
    if (widget.editReport != null) {
      Utils.setEditReport(widget.editReport);
    }
    super.initState();
  }

  setSkip3() {
    setState(() {
      skip3 = !skip3;
    });
  }

  addBitingReport() {
    setState(() {
      addBiting = !addBiting;
    });
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
      MosquitoTypeForm(setSkip3),
      // TakePicturePage(),
      MosquitoPartsForm(),
      BitingLocationForm(),
      CouldSeeForm(addBitingReport, displayQuestions.elementAt(2)),
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
            } else if (currentPage == 2.0 && skip3) {
              _pagesController.animateToPage(0,
                  duration: Duration(microseconds: 300), curve: Curves.ease);
            } else {
              _pagesController.previousPage(
                  duration: Duration(microseconds: 300), curve: Curves.ease);
            }
          },
        ),
        title: Style.title(MyLocalizations.of(context, "adult_report_title"),
            fontSize: 16),
        actions: <Widget>[
          Style.noBgButton(
              false //TODO: show finish in last page
                  ? MyLocalizations.of(context, "finish")
                  : MyLocalizations.of(context, "next"),
              true
                  ? () {
                      double currentPage = _pagesController.page;
                      if (currentPage == _formsRepot.length - 1 && !addBiting) {
                        Utils.createReport();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainVC()),
                        );
                      } else if (currentPage == 3.0 && addBiting) {
                        Utils.addOtherReport('bite');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BitingReportPage()),
                        );
                      } else if (currentPage == 0.0 && skip3) {
                        _pagesController.animateToPage(2,
                            duration: Duration(microseconds: 300),
                            curve: Curves.ease);
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
