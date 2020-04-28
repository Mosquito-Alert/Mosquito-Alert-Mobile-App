import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/biting_logation_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/could_see_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/public_breeding_site_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/questions_breeding_form.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
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

  bool skipReport = false;
  bool addMosquito = false;

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

  @override
  Widget build(BuildContext context) {
    _formsRepot = [
      PublicBreedingForm(setSkipReport),
      // TakePicturePage(),
      QuestionsBreedingForm(),
      BitingLocationForm(),
      CouldSeeForm(addAdultReport),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainVC()),
                        );
                      } else {
                        if (currentPage == _formsRepot.length - 1) {
                          Utils.createReport();
                          Navigator.pop(context);
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
