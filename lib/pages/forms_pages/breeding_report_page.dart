import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/biting_logation_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/could_see_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/public_breeding_site_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/questions_breeding_form.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BreedingReportPage extends StatefulWidget {
  final Report editReport;

  BreedingReportPage({this.editReport});
  @override
  _BreedingReportPageState createState() => _BreedingReportPageState();
}

class _BreedingReportPageState extends State<BreedingReportPage> {
  final _pagesController = PageController();
  List _formsRepot;

  List<Map> displayQuestions = [
    {
      "question": {
        "id": 9,
        "text": {
          "en": "It's a public or a private location?",
          "ca": "Estàs a un lloc públic o propietat privada?",
          "es": "¿Estas en un sitio público o es propiedad privada?",
        }
      },
      "answers": [
        {
          "id": 91,
          "text": {
            "en": "Public place",
            "ca": "Lloc públic",
            "es": "Sitio público"
          }
        },
        {
          "id": 92,
          "text": {
            "en": "Private location",
            "ca": "Propietat privada",
            "es": "Propiedad pirvada"
          }
        }
      ]
    },
    {
      "question": {
        "id": 10,
        "text": {"en": "Does it have water?", "ca": "Hi ha aigua?", "es": "¿Hay agua?"},
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
    },
    {
      "question": {
        "id": 11,
        "text": {
          "en": "Have you seen mosquitoes around?",
          "ca": "Has vist mosquits a la vora?", 
          "es": "¿Has visto mosquitos alrededor?"
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

  bool skipReport = false;
  bool addMosquito = false;
  String otherReport;

  @override
  void initState() {
    if (widget.editReport != null) {
      Utils.setEditReport(widget.editReport);
    } else {
      Utils.createNewReport('site');
    }
    super.initState();
  }

  setSkipReport() {
    setState(() {
      skipReport = !skipReport;
    });
  }

  addAdultReport() {
    setState(() {
      addMosquito = !addMosquito;
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
      PublicBreedingForm(setSkipReport, displayQuestions.elementAt(0)),
      // TakePicturePage(),
      QuestionsBreedingForm(displayQuestions.elementAt(1)),
      BitingLocationForm(),
      CouldSeeForm(addAdultReport, displayQuestions.elementAt(2)),
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
              Navigator.pop(context);
              Utils.resetReport();
            } else {
              _pagesController.previousPage(
                  duration: Duration(microseconds: 300), curve: Curves.ease);
            }
          },
        ),
        title: Style.title(MyLocalizations.of(context, "breeding_report_title"),
            fontSize: 16),
        actions: <Widget>[
          Style.noBgButton(
              false //TODO: show finish in last page
                  ? MyLocalizations.of(context, "finish")
                  : MyLocalizations.of(context, "next"),
              true
                  ? () {
                      double currentPage = _pagesController.page;
                      if (skipReport) {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => MainVC()),
                        // );
                        Navigator.pop(context);
                      } else {
                        if (currentPage == _formsRepot.length - 1) {
                          if (otherReport != null) {
                            navigateOtherReport();
                          } else {
                            Utils.createReport();
                            Navigator.pop(context);
                          }
                        } else if (currentPage == 3.0 && addMosquito) {
                          Utils.addOtherReport('adult');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdultReportPage()),
                          );
                        } else {
                          _pagesController.nextPage(
                              duration: Duration(microseconds: 300),
                              curve: Curves.ease);
                        }
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
