import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BitingForm extends StatefulWidget {
  @override
  _BitingFormState createState() => _BitingFormState();
}

class _BitingFormState extends State<BitingForm> {
  StreamController<List<dynamic>> streamData =
      new StreamController<List<String>>.broadcast();

  List<Question> questions; //

  @override
  void initState() {
    Utils.createNewReport('bite');
    super.initState();
    // streamData.add(questions);
    questions = new List();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 35,
              ),
              Style.title(
                  MyLocalizations.of(context, "need_more_information_txt")),
              Style.bodySmall(MyLocalizations.of(context, "lets_go_txt")),
              SizedBox(
                height: 25,
              ),
              Style.titleMedium('¿Cuántas picaduras quieres reportar y dónde?',
                  fontSize: 16),
              Container(
                alignment: Alignment.topLeft,
                child: Stack(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Image.asset('assets/img/ic_full_body_off.png'),
                        questions.any((question) => question.answer_id == '6')
                            ? Image.asset('assets/img/ic_left_leg_on.png')
                            : Image.asset("assets/img/ic_left_leg_off.png"),
                        questions.any((question) => question.answer_id == '5')
                            ? Image.asset('assets/img/ic_right_leg_on.png')
                            : Image.asset('assets/img/ic_right_leg_off.png'),
                        questions.any((question) => question.answer_id == '4')
                            ? Image.asset('assets/img/ic_left_hand_on.png')
                            : Image.asset('assets/img/ic_left_hand_off.png'),
                        questions.any((question) => question.answer_id == '3')
                            ? Image.asset('assets/img/ic_right_hand_on.png')
                            : Image.asset('assets/img/ic_right_hand_off.png'),
                        questions.any((question) => question.answer_id == '1')
                            ? Image.asset('assets/img/ic_head_on.png')
                            : Image.asset('assets/img/ic_head_off.png'),
                        questions.any((question) => question.answer_id == '2')
                            ? Image.asset('assets/img/ic_chest_on.png')
                            : Image.asset('assets/img/ic_chest_off.png'),
                        Positioned(
                          top: mediaQuery.height * 0.05,
                          left: mediaQuery.width * 0.37,
                          child: questions
                                  .any((question) => question.answer_id == '1')
                              ? Style.body(getIndexAnswer('1'))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.18,
                          left: mediaQuery.width * 0.21,
                          child: questions
                                  .any((question) => question.answer_id == '3')
                              ? Style.body(getIndexAnswer('3'))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.18,
                          left: mediaQuery.width * 0.70,
                          child: questions
                                  .any((question) => question.answer_id == '4')
                              ? Style.body(getIndexAnswer('4'))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.23,
                          left: mediaQuery.width * 0.56,
                          child: questions
                                  .any((question) => question.answer_id == '2')
                              ? Style.body(getIndexAnswer('2'))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.37,
                          left: mediaQuery.width * 0.28,
                          child: questions
                                  .any((question) => question.answer_id == '5')
                              ? Style.body(getIndexAnswer('5'))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.37,
                          left: mediaQuery.width * 0.63,
                          child: questions
                                  .any((question) => question.answer_id == '6')
                              ? Style.body(getIndexAnswer('6'))
                              : Container(),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        //HEAD
                        GestureDetector(
                          onTap: () {
                            addToList('donde pico', "head",
                                question_id: '2', answer_id: '1');
                          },
                          child: Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 40),
                              color: Colors.transparent,
                              height: mediaQuery.height * 0.08,
                              width: mediaQuery.width * 0.15,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            //ARM
                            GestureDetector(
                              onTap: () {
                                addToList('donde pico', "right arm",
                                    question_id: '2', answer_id: '3');
                              },
                              child: Container(
                                color: Colors.blue.withOpacity(0.0),
                                height: mediaQuery.height * 0.1,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                            //CHEST
                            GestureDetector(
                              onTap: () {
                                addToList('donde pico', "chest",
                                    question_id: '2', answer_id: '2');
                              },
                              child: Container(
                                // margin: EdgeInsets.only(top: 5),
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.13,
                                width: mediaQuery.width * 0.15,
                              ),
                            ),
                            //ARM
                            GestureDetector(
                              onTap: () {
                                addToList('donde pico', "left arm",
                                    question_id: '2', answer_id: '4');
                              },
                              child: Container(
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.1,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            //LEG
                            GestureDetector(
                              onTap: () {
                                addToList('donde pico', "right leg",
                                    question_id: '2', answer_id: '5');
                              },
                              child: Container(
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.15,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                            //LEG
                            GestureDetector(
                              onTap: () {
                                addToList('donde pico', "left leg",
                                    question_id: '2', answer_id: '6');
                              },
                              child: Container(
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.15,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Center(
                child: Style.body(
                  MyLocalizations.of(context, 'tap_image_biting_txt'),
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Style.titleMedium('¿Cuándo te ha picado el mosquito?',
                  fontSize: 16),
              SizedBox(
                height: 10,
              ),
              Row(children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      addToList('cuando pico', "amanecer",
                          question_id: '3', answer_id: '7');
                    },
                    child: SmallQuestionOption(
                      'Amanecer',
                      selected: questions.any((q) => q.answer_id == '7'),
                      index: getIndexAnswer('7'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      addToList('cuando pico', "Mediodia",
                          question_id: '3', answer_id: '8');
                    },
                    child: SmallQuestionOption(
                      'Mediodía',
                      selected: questions.any((q) => q.answer_id == '8'),
                      index: getIndexAnswer('8'),
                    ),
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
              Row(children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      addToList('cuando pico', "atardeser",
                          question_id: '3', answer_id: '9');
                    },
                    child: SmallQuestionOption(
                      'Atardecer',
                      selected: questions.any((q) => q.answer_id == '9'),
                      index: getIndexAnswer('9'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      addToList('cuando pico', 'noshe',
                          question_id: '3', answer_id: '10');
                    },
                    child: SmallQuestionOption(
                      'Noche',
                      selected: questions.any((q) => q.answer_id == '10'),
                      index: getIndexAnswer('10'),
                    ),
                  ),
                ),
              ]),
              SizedBox(
                height: 15,
              ),
              canContinue()
                  // false
                  ? GestureDetector(
                      onTap: () {
                        // Utils.getReportResponses(snapshot.data);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Style.colorPrimary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Style.body(
                            MyLocalizations.of(context, "continue_txt"),
                            textAlign: TextAlign.center,
                            color: Colors.white),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Style.body(
                          MyLocalizations.of(context, "complete_all_txt"),
                          textAlign: TextAlign.center,
                          color: Colors.white),
                    ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getIndexAnswer(String answer_id) {
    int index =
        questions.indexWhere((question) => question.answer_id == answer_id);

    if (index != -1) {
      return questions[index].answer_value;
    }
  }

  addToList(String question, String answer, {question_id, answer_id}) {
    // TODO: fix question_id!

    List _questions = questions;
    if (question_id != '1') {
      int currentIndex = _questions.indexWhere((question) =>
          // question.question_id == question_id &&
          question.answer_id == answer_id.toString());
      if (currentIndex == -1) {
        _questions.add(Question(
          question: question.toString(),
          answer: answer.toString(),
          answer_id: answer_id.toString(),
          question_id: question_id.toString(),
          answer_value: '1',
        ));
      } else {
        int value = int.parse(_questions[currentIndex].answer_value);
        value = value + 1;

        _questions[currentIndex].answer_value = value.toString();
      }
      if (question_id == '2') {
        int bitesIndex =
            _questions.indexWhere((question) => question.question_id == '1');

        if (bitesIndex == -1) {
          _questions.add(Question(
              question: 'Cuantas picads',
              answer: '',
              question_id: '1',
              answer_value: '1'));
        } else {
          int value = int.parse(_questions[bitesIndex].answer_value);
          value = value + 1;
          _questions[bitesIndex].answer_value = value.toString();
        }
      }
    }

    setState(() {
      questions = _questions;
    });
  }

  bool canContinue() {
    if (questions.length > 1) {
      int totalIndex = questions.indexWhere((q) => q.question_id == '1');
      int totalValues = int.parse(questions[totalIndex].answer_value);
      bool canContinue = false;
      for (int j = 2; j <= 3; j++) {
        int questionValue = 0;
        for (int i = 0; i < questions.length; i++) {
          // 2 = first questions on screen; 3 = only 3 questions in this screen (2 shown + 1 auto)
          if (questions[i].question_id == j.toString()) {
            questionValue =
                questionValue + int.parse(questions[i].answer_value);
          }
        }
        if (questionValue == totalValues) {
          canContinue = true;
        } else {
          canContinue = false;
        }
      }
      return canContinue;
    }
    return true;
  }
}
