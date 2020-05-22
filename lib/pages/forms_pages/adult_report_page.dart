import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/could_see_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_parts_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_type_form.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'breeding_report_page.dart';
import 'components/biting_logation_form.dart';

class AdultReportPage extends StatefulWidget {
  final Report editReport;
  final Function loadData;

  AdultReportPage({this.editReport, this.loadData});
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
          "ca": "Quin tipus de mosquit creus que és?",
          "es": "¿Que tipo de mosquito crees que es?"
        }
      },
      "answers": [
        {
          "id": 61,
          "img": "assets/img/ic_aedes.png",
          "text": {
            "en": "Invasive Aedes",
            "ca": "Aedes Invasiu",
            "es": "Invasive Aedes"
          }
        },
        {
          "id": 62,
          "img": "assets/img/ic_cluex.png",
          "text": {
            "en": "Common mosquito",
            "ca": "Mosquit comú",
            "es": "Mosquito común"
          }
        },
        {
          "id": 63,
          "img": "assets/img/ic_other_mosquito.png",
          "text": {
            "en": "Other",
            "ca": "Altres",
            "es": "Otro",
          }
        }
      ]
    },
    {
      "question": {
        "id": 7,
        "text": {
          "en": "How does your mosquito look?",
          "ca": "Quin aspecte té el teu mosquit?",
          "es": "¿Que aspecto tiene tu mosquito?"
        }
      },
      "answers": [
        [
          {
            "id": 711,
            "img": "assets/img/torax_711.png",
            "text": {"en": "Thorax 1", "ca": "Tòrax 1", "es": "Tórax 1"}
          },
          {
            "id": 712,
            "img": "assets/img/torax_712.png",
            "text": {"en": "Thorax 2", "ca": "Tòrax 2", "es": "Tórax 21"}
          },
          {
            "id": 713,
            "img": "assets/img/torax_713.png",
            "text": {"en": "Thorax 3", "ca": "Tòrax 3", "es": "Tórax 3"}
          },
          {
            "id": 714,
            "img": "assets/img/torax_714.png",
            "text": {"en": "Thorax 4", "ca": "Tòrax 4", "es": "Tórax 1"}
          },
        ],
        [
          {
            "id": 721,
            "img": "assets/img/abdomen_721.png",
            "text": {"en": "Abdomen 1", "ca": "Abdomen 1", "es": "Abdomen 1"}
          },
          {
            "id": 722,
            "img": "assets/img/abdomen_722.png",
            "text": {"en": "Abdomen 2", "ca": "Abdomen 2", "es": "Abdomen 2"}
          },
          {
            "id": 723,
            "img": "assets/img/abdomen_723.png",
            "text": {"en": "Abdomen 3", "ca": "Abdomen 3", "es": "Abdomen 3"}
          },
          {
            "id": 724,
            "img": "assets/img/abdomen_724.png",
            "text": {"en": "Abdomen 4", "ca": "Abdomen 4", "es": "Abdomen 4"}
          },
        ],
        [
          {
            "id": 731,
            "img": "assets/img/leg_731.png",
            "text": {"en": "3d leg 1", "ca": "3a cama 1", "es": "Pierna 1"}
          },
          {
            "id": 732,
            "img": "assets/img/leg_732.png",
            "text": {"en": "3d leg 2", "ca": "3a cama 2", "es": "Pierna 2"}
          },
          {
            "id": 733,
            "img": "assets/img/leg_733.png",
            "text": {"en": "3d leg 3", "ca": "3a cama 3", "es": "Pierna 3"}
          },
          {
            "id": 734,
            "img": "assets/img/leg_734.png",
            "text": {"en": "3d leg 4", "ca": "3a cama 4", "es": "Pierna 4"}
          }
        ],
      ]
    },
    {
      "question": {
        "id": 8,
        "text": {
          "en": "Did this mosquito bite you?",
          "ca": "T'ha picat el mosquit?",
          "es": "¿Te ha picado el mosquito?"
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
        },
        {
          "id": 35,
          "text": {
            "en": "Not sure",
            "ca": "No ho tinc clar",
            "es": "No lo tengo claro"
          }
        },
      ]
    }
  ];

  bool skip3 = false;
  bool addBiting = false;
  bool validContent = false;
  String otherReport;

  @override
  void initState() {
    if (widget.editReport != null) {
      Utils.setEditReport(widget.editReport);
    }
    super.initState();
  }

  setSkip3(skip) {
    setState(() {
      skip3 = skip;
    });
  }

  addBitingReport(addReport) {
    setState(() {
      addBiting = addReport;
    });
  }

  addOtherReport(String reportType) {
    setState(() {
      otherReport = reportType;
    });
  }

  setValid(isValid) {
    setState(() {
      validContent = isValid;
    });
  }

  navigateOtherReport() {
    switch (otherReport) {
      case "bite":
        Utils.addOtherReport("bite");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BitingReportPage()),
        );
        break;
      case "site":
        Utils.addOtherReport("site");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BreedingReportPage()),
        );
        break;
      case "adult":
        Utils.addOtherReport("adult");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdultReportPage()),
        );
        break;
      default:
        Utils.createReport();
        if (widget.editReport != null) {
          widget.loadData();
        }
        Navigator.pop(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _formsRepot = [
      MosquitoTypeForm(setSkip3, displayQuestions.elementAt(0), setValid),
      MosquitoPartsForm(displayQuestions.elementAt(1), setValid),
      BitingLocationForm(setValid),
      CouldSeeForm(addBitingReport, displayQuestions.elementAt(2), setValid),
      AddOtherReportPage(addOtherReport, setValid),
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
              setValid(true);
              _pagesController.animateToPage(0,
                  duration: Duration(microseconds: 300), curve: Curves.ease);
            } else {
              setValid(true);
              addOtherReport(null);
              _pagesController.previousPage(
                  duration: Duration(microseconds: 300), curve: Curves.ease);
            }
          },
        ),
        title: Style.title(MyLocalizations.of(context, "adult_report_title"),
            fontSize: 16),
        actions: <Widget>[
          Style.noBgButton(
              _pagesController.hasClients &&
                      _pagesController.page == _formsRepot.length - 1 &&
                      otherReport == 'none'
                  ? MyLocalizations.of(context, "finish")
                  : MyLocalizations.of(context, "next"),
              validContent
                  ? () {
                      double currentPage = _pagesController.page;
                      if (currentPage == _formsRepot.length - 1 && !addBiting) {
                        navigateOtherReport();
                      } else if (currentPage == 3.0 && addBiting) {
                        Utils.addOtherReport('bite');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BitingReportPage()),
                        );
                      } else if (currentPage == 0.0 && skip3) {
                        setValid(false);
                        _pagesController.animateToPage(2,
                            duration: Duration(microseconds: 300),
                            curve: Curves.ease);
                      } else {
                        setValid(false);
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
