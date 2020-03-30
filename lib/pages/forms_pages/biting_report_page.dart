import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'components/biting_form.dart';
import 'components/biting_logation_form.dart';
import 'components/biting_questions_form.dart';
import 'components/mosquito_type_form.dart';

class BitingReportPage extends StatefulWidget {
  @override
  _BitingReportPageState createState() => _BitingReportPageState();
}

class _BitingReportPageState extends State<BitingReportPage> {
  final _pagesController = PageController();
  List _formsRepot;

  List<Questions> responses = [];

  Report report = new Report();

  @override
  Widget build(BuildContext context) {
    _formsRepot = [
      BitingForm(),
      // BitingLocationForm(setLocationType, setSelectedLocation),
      MosquitoTypeForm()
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
                      if (currentPage == 1.0) {
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

  // void addResponse(String question, String answer) {
  //   int currentIndex =
  //       responses.indexWhere((question) => responses.contains(question));
  //   if (currentIndex != -1) {
  //     responses[currentIndex].answer = answer;
  //   } else {
  //     setState(() {
  //       responses.add(new Questions(question: question, answer: answer));
  //     });
  //   }
  //   report.responses = responses;
  // }

  // Future<void> setLocationType(String type) async {
  //   report.location_choice = type;
  //   if(type == "current"){
  //     Position currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //     report.current_location_lat = currentPosition.latitude;
  //     report.current_location_lon = currentPosition.longitude;
  //   }
  // }

  // void setSelectedLocation(double lat, lon) {
  //   report.selected_location_lat = lat;
  //   report.selected_location_lon = lon;
  // }

  // Future<void> createReport() async {
  //   report.type = 'adult';
  //   report.report_id = randomAlphaNumeric(4).toString();
  //   report.version_number = 0;
  //   report.version_time = DateTime.now().toUtc().toString();
  //   report.creation_time = DateTime.now().toUtc().toString();
  //   report.phone_upload_time = DateTime.now().toUtc().toString();
  //   report.version_UUID = new Uuid().v4();

  //   report.user = await UserManager.getUUID();

  //   ApiSingleton().createReport(report);
  // }
}
