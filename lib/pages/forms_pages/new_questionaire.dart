
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/biting_location_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/could_see_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/questions_breeding_form.dart';

class Questionnaire extends StatefulWidget {
  final List<File> photos;
  const Questionnaire({key, required this.photos});

  @override
  State<Questionnaire> createState() => _QuestionnaireState(photos: photos);
}

class _QuestionnaireState extends State<Questionnaire>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;
  StreamController<bool> validStream = StreamController<bool>.broadcast();
  final List<File> photos;

  _QuestionnaireState({required this.photos});

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 4, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PageView Sample')),
        backgroundColor: Colors.white,
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
              /*CouldSeeForm(
                addBitingReport, displayQuestions.elementAt(2), setValid, goNextPage),*/
            ],
          ),
        ],
      )
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }
}