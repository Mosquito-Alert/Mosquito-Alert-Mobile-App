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

  bool skip3 = false;
  bool addBiting = false;

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

  adBitingdReport() {
    setState(() {
      addBiting = !addBiting;
    });
  }

  @override
  Widget build(BuildContext context) {
    _formsRepot = [
      MosquitoTypeForm(setSkip3),
      // TakePicturePage(),
      MosquitoPartsForm(),
      BitingLocationForm(),
      CouldSeeForm(adBitingdReport),
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
