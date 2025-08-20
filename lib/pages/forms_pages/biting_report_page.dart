import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/settings_pages/campaign_tutorial_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'adult_report_page.dart';
import 'components/biting_form.dart';
import 'components/location_form.dart';

class BitingReportPage extends StatefulWidget {
  @override
  _BitingReportPageState createState() => _BitingReportPageState();
}

class _BitingReportPageState extends State<BitingReportPage> {
  PageController? _pagesController;
  late List<Widget> _formsReport;
  String? otherReport;
  bool seeButton = false;
  bool addMosquito = false;
  StreamController<bool> loadingStream = StreamController<bool>.broadcast();
  StreamController<bool> validStream = StreamController<bool>.broadcast();
  StreamController<double> percentStream = StreamController<double>.broadcast();
  double index = 0;

  // Define the events to log
  final List<Map<String, dynamic>> _pageEvents = [
    {
      'name': 'report_add_bites',
      'parameters': {'type': 'bite'}
    },
    {
      'name': 'report_add_location',
      'parameters': {'type': 'bite'}
    },
    {
      'name': 'report_add_note',
      'parameters': {'type': 'bite'}
    }
  ];

  List<Map> displayQuestions = [
    {
      'question': {'id': 1, 'text': 'question_1'},
      'answers': [
        //Number of bites - value equals TOTAL number of bites
        {'id': 11, 'text': 'question_1_answer_11'}
      ]
    },
    {
      'question': {'id': 2, 'text': 'question_2'},
      'answers': [
        //Bites by body are - value equals number of bites in each area, must be = to total number of bites
        {'id': 21, 'text': 'question_2_answer_21'},
        {'id': 22, 'text': 'question_2_answer_22'},
        {'id': 23, 'text': 'question_2_answer_23'},
        {'id': 24, 'text': 'question_2_answer_24'},
        {'id': 25, 'text': 'question_2_answer_25'},
        {'id': 26, 'text': 'question_2_answer_26'}
      ]
    },
    {
      'question': {'id': 4, 'text': 'question_4'},
      'answers': [
        {'id': 41, 'text': 'question_4_answer_41'},
        {'id': 42, 'text': 'question_4_answer_42'},
        {'id': 43, 'text': 'question_4_answer_43'},
        {'id': 44, 'text': 'question_4_answer_44'},
      ]
    },
    {
      'question': {'id': 5, 'text': 'question_5'},
      'answers': [
        {'id': 51, 'text': 'question_5_answer_51'},
        {'id': 52, 'text': 'question_5_answer_52'},
      ]
    },
    {
      'question': {'id': 3, 'text': 'question_3'},
      'answers': [
        {'id': 31, 'text': 'question_3_answer_31'},
        {'id': 32, 'text': 'question_3_answer_32'},
        {'id': 33, 'text': 'question_3_answer_33'},
        {'id': 34, 'text': 'question_3_answer_34'},
      ]
    },
    {
      'question': {'id': 14, 'text': 'question_14'},
    },
  ];
  late Report toEditReport;

  void _onPageChanged(int index) async {
    // Check if the index is valid and log the event
    if (index >= 0 && index < _pageEvents.length) {
      final event = _pageEvents[index];
      await FirebaseAnalytics.instance.logEvent(
        name: event['name'],
        parameters: event['parameters'],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _logFirebaseAnalytics();
    _pagesController = PageController();
    _formsReport = [
      BitingForm(
        [
          displayQuestions.elementAt(0),
          displayQuestions.elementAt(1),
          displayQuestions.elementAt(2),
          displayQuestions.elementAt(3),
          displayQuestions.elementAt(4),
        ],
        setValid,
        goNextPage,
      ),
      LocationForm(
        setValid,
        displayQuestions.elementAt(5)['question']['text'],
      ),
      AddOtherReportPage(_saveData, setValid, percentStream),
    ];
  }

  Future<void> _logFirebaseAnalytics() async {
    await FirebaseAnalytics.instance
        .logEvent(name: 'start_report', parameters: {'type': 'bite'});
  }

  void addOtherReport(String? reportType) {
    setState(() {
      otherReport = reportType;
    });
  }

  void addAdultReport(addReport) {
    setState(() {
      addMosquito = addReport;
    });
  }

  void setValid(isValid) {
    validStream.add(isValid);
  }

  void _saveData() async {
    setState(() {
      percentStream.add(0.8);
    });
    loadingStream.add(true);
    await FirebaseAnalytics.instance
        .logEvent(name: 'submit_report', parameters: {'type': 'bite'});
    var res = await Utils.createReport();

    if (!res!) {
      _showAlertKo();
      return;
    }

    if (Utils.savedAdultReport == null) {
      return showSuccess();
    }

    List<Campaign> campaigns =
        await ApiSingleton().getCampaigns(Utils.savedAdultReport!.country);

    final activeCampaign = findActiveCampaign(campaigns);
    if (activeCampaign != null) {
      await Utils.showAlertCampaign(
        context,
        activeCampaign,
        (ctx) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignTutorialPage(fromReport: true),
            ),
          );
        },
      );
    }
    return showSuccess();
  }

  void showSuccess() {
    _showAlertOk();
    Utils.resetReport();
    setState(() {
      percentStream.add(1.0);
    });
  }

  Campaign? findActiveCampaign(List<Campaign> campaigns) {
    final now = DateTime.now().toUtc();
    final filtered = campaigns.where((element) {
      final start = DateTime.tryParse(element.startDate ?? '');
      final end = DateTime.tryParse(element.endDate ?? '');
      if (start == null || end == null) return false;
      return start.isBefore(now) && end.isAfter(now);
    }).toList();

    if (filtered.isEmpty) return null;
    return filtered.first;
  }

  void goNextPage() {
    _pagesController!
        .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
        .then((value) {
      setState(() {
        seeButton = true;
      });
    });
    setState(() {
      index = _pagesController!.page! + 1;
    });
  }

  @override
  void dispose() {
    _pagesController!.dispose();
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
                  var currentPage = _pagesController!.page;

                  if (currentPage == 0.0) {
                    _onWillPop();
                  } else if (currentPage == 1) {
                    _pagesController!
                        .previousPage(
                            duration: Duration(microseconds: 300),
                            curve: Curves.ease)
                        .then((value) {});
                  } else {
                    addOtherReport(null);
                    _pagesController!.previousPage(
                        duration: Duration(microseconds: 300),
                        curve: Curves.ease);
                  }
                  setState(() {
                    index = currentPage! - 1;
                  });
                },
              ),
              title: Style.title(
                  MyLocalizations.of(context, 'biting_report_txt'),
                  fontSize: 16),
              actions: <Widget>[],
            ),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                PageView(
                  controller: _pagesController,
                  onPageChanged: _onPageChanged,
                  physics: NeverScrollableScrollPhysics(),
                  children: _formsReport,
                ),
                index == 0.0
                    ? Container()
                    : index != _formsReport.length.toDouble() - 1
                        ? SafeArea(
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: StreamBuilder<bool>(
                                    stream: validStream.stream,
                                    initialData: false,
                                    builder: (BuildContext ctxt,
                                        AsyncSnapshot<bool> snapshot) {
                                      return snapshot.data!
                                          ? Container(
                                              width: double.infinity,
                                              height: 54,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 6, horizontal: 12),
                                              child: Style.button(
                                                  MyLocalizations.of(
                                                      context, 'continue_txt'),
                                                  () {
                                                var currentPage =
                                                    _pagesController!.page;

                                                if (currentPage == 2 &&
                                                    addMosquito) {
                                                  Utils.addOtherReport(
                                                      'adult', context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AdultReportPage()),
                                                  );
                                                } else {
                                                  setState(() {
                                                    index = currentPage! + 1;
                                                  });
                                                  _pagesController!.nextPage(
                                                      duration: Duration(
                                                          microseconds: 300),
                                                      curve: Curves.ease);
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
                                                      context, 'continue_txt'),
                                                  null),
                                            );
                                    })),
                          )
                        : SafeArea(
                            child: Container(
                              width: double.infinity,
                              height: 54,
                              margin: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12),
                              child: Style.button(
                                MyLocalizations.of(context, 'send_data'),
                                () {
                                  _saveData();
                                },
                              ),
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
      MyLocalizations.of(context, 'app_name'),
      MyLocalizations.of(context, 'save_report_ok_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        Navigator.of(context).popUntil((r) => r.isFirst);
        Utils.resetReport();
        Utils.requestInAppReview();
      },
      barrierDismissible: false,
    );
  }

  _showAlertKo() {
    loadingStream.add(false);
    Utils.showAlert(
      MyLocalizations.of(context, 'app_name'),
      MyLocalizations.of(context, 'save_report_ko_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        Navigator.of(context).popUntil((r) => r.isFirst);
        Utils.resetReport();
      },
      barrierDismissible: false,
    );
  }

  _onWillPop() {
    var responses = Utils.report?.responses ?? [];
    if (responses.isNotEmpty) {
      Utils.showAlertYesNo(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'close_report_no_save_txt'), () {
        if (Utils.reportsList != null && Utils.reportsList!.isNotEmpty) {
          Utils.deleteLastReport();
        } else {
          Utils.resetReport();
          Utils.imagePath = null;
        }
        Navigator.pop(context);
      }, context);
    } else {
      if (Utils.reportsList!.isNotEmpty) {
        Utils.deleteLastReport();
      }
      Navigator.pop(context);
    }
  }
}
