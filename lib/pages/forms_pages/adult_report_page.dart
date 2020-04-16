import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_parts_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/mosquito_type_form.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'components/biting_logation_form.dart';

class AdultReportPage extends StatefulWidget {
  @override
  _AdultReportPageState createState() => _AdultReportPageState();
}

class _AdultReportPageState extends State<AdultReportPage> {
  final List<Map<String, List<String>>> questions = [
    {
      "question": ["¿Cuándo te ha picado el mosquito?"],
      "answers": [
        "Por la mañana",
        "Al mediodia",
        "Por la tarde",
        "Por la noche",
        "no estoy seguro"
      ]
    },
    {
      "question": ["¿En que situación te ha picado?"],
      "answers": ["espacio cerrado", "espacio abierto"]
    },
    {
      "question": ["¿Dónde te ha picado?"],
      "answers": ["d"]
    },
  ];

  final _pagesController = PageController();
  List _formsRepot;


  @override
  Widget build(BuildContext context) {
    _formsRepot = [
      MosquitoTypeForm(),
      // TakePicturePage(),
      MosquitoPartsForm(),
      // BitingQuestionsForm(questions, addResponse, responses),
      BitingLocationForm(),
      // Te pico form()
      AddOtherReportPage(),
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
                      if (currentPage == _formsRepot.length-1) {
                        // createReport();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainVC()),
                        );
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
