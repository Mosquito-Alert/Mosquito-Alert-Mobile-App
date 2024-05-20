
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/owcampaing.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/biting_location_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/could_see_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/questions_breeding_form.dart';
import 'package:mosquito_alert_app/pages/settings_pages/campaign_tutorial_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';

class Questionnaire extends StatefulWidget {
  final Report? editReport;
  final Function? loadData;
  final List<File> photos;
  const Questionnaire({key, required this.photos, this.editReport, this.loadData});

  @override
  State<Questionnaire> createState() => _QuestionnaireState(photos: photos);
}

class _QuestionnaireState extends State<Questionnaire>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;
  StreamController<bool> validStream = StreamController<bool>.broadcast();
  StreamController<bool> loadingStream = StreamController<bool>.broadcast();
  StreamController<double> percentStream = StreamController<double>.broadcast();
  final List<File> photos;

  _QuestionnaireState({required this.photos});

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  void setValid(isValid) {
    validStream.add(isValid);
  }

  List<Map> displayQuestions = [
    {
      'question': {'id': 13, 'text': 'question_13'},
      'answers': [
        {'id': 131, 'text': 'question_13_answer_131'},
        {'id': 132, 'text': 'question_13_answer_132'},
        {'id': 133, 'text': 'question_13_answer_133'},
      ]
    },
    {
      'question': {'id': 15, 'text': 'question_15'},
    },
    {
      'question': {'id': 8, 'text': 'question_8'},
      'answers': [
        {'id': 82, 'text': 'question_8_answer_82'},
        {'id': 81, 'text': 'question_8_answer_81'},
      ]
    },
  ];

  void addBitingReport(addReport) {

  }

  void goNextPage() {

  }

  _showAlertKo() {
    loadingStream.add(false);
    Utils.showAlert(
      MyLocalizations.of(context, 'app_name'),
      MyLocalizations.of(context, 'save_report_ko_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        if (widget.editReport != null) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
          Utils.resetReport();
        }
      },
      barrierDismissible: false,
    );
  }

  void _createReport() async {
    loadingStream.add(true);
    setState(() {
      percentStream.add(0.8);
    });
    var res = await Utils.createReport();

    if (res!=null && !res) {
      _showAlertKo();
    } else {
      if (Utils.savedAdultReport != null &&
          Utils.savedAdultReport!.country != null) {
        List<Campaign> campaignsList =
            await ApiSingleton().getCampaigns(Utils.savedAdultReport!.country);
        var now = DateTime.now().toUtc();
        if (campaignsList.any((element) =>
            DateTime.parse(element.startDate!).isBefore(now) &&
            DateTime.parse(element.endDate!).isAfter(now))) {
          var activeCampaign = campaignsList.firstWhere((element) =>
              DateTime.parse(element.startDate!).isBefore(now) &&
              DateTime.parse(element.endDate!).isAfter(now));

          await Utils.showAlertCampaign(
            context,
            activeCampaign,
            (ctx) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => CampaignTutorialPage(
                          fromReport: true,
                        )),
              );
              Utils.resetReport();
            },
          );
        } else {
          _showAlertOk();
        }
      } else {
        _showAlertOk();
      }

      setState(() {
        percentStream.add(1.0);
      });
    }
    loadingStream.add(false);
    if (widget.editReport != null) {
      widget.loadData!();
    }

    Navigator.pop(context);
  }

  _showAlertOk() {
    loadingStream.add(false);

    Utils.showAlert(
      MyLocalizations.of(context, 'app_name'),
      widget.editReport == null
          ? MyLocalizations.of(context, 'save_report_ok_txt')
          : MyLocalizations.of(context, 'edited_report_ok_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        if (widget.editReport != null) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
          Utils.resetReport();
        }
      },
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report mosquito'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            controller: _pageViewController,
            onPageChanged: _handlePageViewChanged,
            children: <Widget>[
              BitingLocationForm(
                setValid, displayQuestions.elementAt(1)['question']['text']),
              QuestionsBreedingForm(
                displayQuestions.elementAt(0), setValid, false, null, ''),
              CouldSeeForm(
                addBitingReport, displayQuestions.elementAt(2), setValid, goNextPage),
              AddOtherReportPage(_createReport, setValid, percentStream),
            ],
          ),
          Positioned(
            bottom: 20,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPageIndex < _tabController.length - 1) {
                  _pageViewController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }
}