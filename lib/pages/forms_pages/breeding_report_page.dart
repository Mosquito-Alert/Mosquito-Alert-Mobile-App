import 'dart:async';

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
  final Function loadData;

  BreedingReportPage({this.editReport, this.loadData});
  @override
  _BreedingReportPageState createState() => _BreedingReportPageState();
}

class _BreedingReportPageState extends State<BreedingReportPage> {
  final _pagesController = PageController();
  List _formsRepot;
  StreamController<bool> loadingStream = new StreamController<bool>.broadcast();

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
            "es": "Propiedad privada"
          }
        }
      ]
    },
    {
      "question": {
        "id": 10,
        "text": {
          "en": "Does it have water?",
          "ca": "Hi ha aigua?",
          "es": "¿Hay agua?"
        },
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
  bool validContent = false;
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

  setSkipReport(skip) {
    setState(() {
      skipReport = skip;
    });
  }

  addAdultReport(addReport) {
    setState(() {
      addMosquito = addReport;
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

  navigateOtherReport() async {
    switch (otherReport) {
      case "bite":
        Utils.addOtherReport('bite');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BitingReportPage()),
        );
        break;
      case "site":
        Utils.addOtherReport('site');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BreedingReportPage()),
        );
        break;
      case "adult":
        Utils.addOtherReport('adult');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdultReportPage()),
        );
        break;
      default:
        loadingStream.add(true);
        bool res = await Utils.createReport();

        !res ? _showAlertKo() : _showAlertOk();
        if (widget.editReport != null) {
          widget.loadData();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _formsRepot = [
      PublicBreedingForm(setSkipReport, displayQuestions.elementAt(0), setValid,
          widget.editReport != null),
      QuestionsBreedingForm(displayQuestions.elementAt(1), setValid),
      BitingLocationForm(setValid),
      CouldSeeForm(addAdultReport, displayQuestions.elementAt(2), setValid),
      AddOtherReportPage(addOtherReport, setValid),
    ];

    return Stack(
      children: <Widget>[
        Scaffold(
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
                  addOtherReport(null);
                  _pagesController.previousPage(
                      duration: Duration(microseconds: 300),
                      curve: Curves.ease);
                }
              },
            ),
            title: Style.title(
                MyLocalizations.of(context, "breeding_report_title"),
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
                          if (skipReport) {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => MainVC()),
                            // );
                            Navigator.pop(context);
                          } else {
                            if (currentPage == _formsRepot.length - 1) {
                              navigateOtherReport();
                            } else if (currentPage == 3.0 && addMosquito) {
                              Utils.addOtherReport('adult');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdultReportPage()),
                              );
                            } else {
                              setValid(false);
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
        Navigator.pop(context);
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
        Navigator.pop(context);
      },
      barrierDismissible: false,
    );
  }
}
