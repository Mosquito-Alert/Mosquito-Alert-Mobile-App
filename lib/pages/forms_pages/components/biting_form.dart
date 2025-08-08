import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

enum BodyPart {
  head(21),
  left_arm(22),
  right_arm(23),
  body(24),
  left_leg(25),
  right_leg(26);

  final int id;
  const BodyPart(this.id);
}

enum BiteQuestion {
  how_many(1),
  bitten_body_part(2),
  what_time(3),
  vehicle_or_building(4),
  when(5),
  what_does_it_look_like(7);

  final int id;
  const BiteQuestion(this.id);
}

enum Answer {
  just_now(51),
  last_24h(52),
  inside_vehicle(131);

  final int id;
  const Answer(this.id);
}

class BitingForm extends StatefulWidget {
  final List<Map> displayQuestions;
  final Function setValid, nextPage;

  BitingForm(this.displayQuestions, this.setValid, this.nextPage);
  @override
  _BitingFormState createState() => _BitingFormState();
}

class _BitingFormState extends State<BitingForm> {
  List<Question?>? questions;
  List<Map> displayQuestions = [];
  Map bodyQuestion = {};
  int bites = 0;

  bool showDaytime = false;
  bool valid = false;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    questions = [];

    if (Utils.report != null) {
      for (var q in Utils.report!.responses!) {
        if (q!.question_id == BiteQuestion.how_many.id) {
          bites = int.parse(q.answer_value!);
        }
        if (q.question_id! <= BiteQuestion.vehicle_or_building.id ||
            q.question_id == BiteQuestion.when.id) {
          questions!.add(q);
        }
        if (q.answer_id == Answer.last_24h.id) {
          showDaytime = true;
        }
      }
    }
    var isValid = canContinue();
    setState(() {
      valid = isValid;
    });
    _textController.text = bites.toString();
    displayQuestions = widget.displayQuestions
        .where((q) => q['question']['id'] > BiteQuestion.bitten_body_part.id)
        .toList();
    bodyQuestion = widget.displayQuestions
        .where((q) => q['question']['id'] == BiteQuestion.bitten_body_part.id)
        .toList()[0];
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
                height: 24,
              ),
              Style.titleMedium(
                  MyLocalizations.of(context, 'bytes_and_place_report_txt'),
                  fontSize: 16),
              SizedBox(
                height: 12,
              ),
              Row(
                children: <Widget>[
                  Style.button(
                    '-',
                    () {
                      bites = max(bites - 1, 0);
                      _textController.text = bites.toString();
                      var question = widget.displayQuestions
                          .where((q) => q['question']['id'] == 1)
                          .toList();

                      removeBite();

                      setState(() {
                        questions = Utils.report!.responses;
                      });
                      addToList(question[0]['question']['text'], '',
                          question_id: BiteQuestion.how_many.id,
                          //answer_id: 11, // TODO: It's an empty string, deprecate?
                          answer_value: _textController.text);

                      var isValid = canContinue();
                      Utils.resetBitingQuestion();
                      setState(() {
                        valid = isValid;
                        questions = Utils.report!.responses;
                      });
                    },
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                      flex: 1,
                      child: Style.textField(
                        'a',
                        _textController,
                        context,
                        enabled: false,
                      )),
                  SizedBox(
                    width: 12,
                  ),
                  Style.button(
                    '+',
                    () {
                      bites = min(bites = bites + 1, 20);
                      _textController.text = bites.toString();
                      var question = widget.displayQuestions
                          .where((q) => q['question']['id'] == 1)
                          .toList();
                      addToList(question[0]['question']['text'], '',
                          question_id: BiteQuestion.how_many.id,
                          //answer_id: 11, // TODO: Empty value, deprecate?
                          answer_value: _textController.text);
                      var isValid = canContinue();
                      setState(() {
                        valid = isValid;
                      });
                    },
                  ),
                ],
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Stack(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Image.asset(
                          'assets/img/ic_full_body_off.webp',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions!.any((question) =>
                                  question!.answer_id == BodyPart.left_leg.id)
                              ? 'assets/img/ic_left_leg_on.webp'
                              : 'assets/img/ic_left_leg_off.webp',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions!.any((question) =>
                                  question!.answer_id == BodyPart.right_leg.id)
                              ? 'assets/img/ic_right_leg_on.webp'
                              : 'assets/img/ic_right_leg_off.webp',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions!.any((question) =>
                                  question!.answer_id == BodyPart.left_arm.id)
                              ? 'assets/img/ic_left_hand_on.webp'
                              : 'assets/img/ic_left_hand_off.webp',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions!.any((question) =>
                                  question!.answer_id == BodyPart.right_arm.id)
                              ? 'assets/img/ic_right_hand_on.webp'
                              : 'assets/img/ic_right_hand_off.webp',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions!.any((question) =>
                                  question!.answer_id == BodyPart.head.id)
                              ? 'assets/img/ic_head_on.webp'
                              : 'assets/img/ic_head_off.webp',
                          width: mediaQuery.width,
                        ),
                        Image.asset(
                          questions!.any((question) =>
                                  question!.answer_id == BodyPart.body.id)
                              ? 'assets/img/ic_chest_on.webp'
                              : 'assets/img/ic_chest_off.webp',
                          width: mediaQuery.width,
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.05,
                          left: mediaQuery.width * 0.37,
                          child: questions!.any((question) =>
                                  question!.answer_id == BodyPart.head.id)
                              ? Style.body(getIndexBody(BodyPart.head.id))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.18,
                          left: mediaQuery.width * 0.21,
                          child: questions!.any((question) =>
                                  question!.answer_id == BodyPart.right_arm.id)
                              ? Style.body(getIndexBody(BodyPart.right_arm.id))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.18,
                          left: mediaQuery.width * 0.70,
                          child: questions!.any((question) =>
                                  question!.answer_id == BodyPart.left_arm.id)
                              ? Style.body(getIndexBody(BodyPart.left_arm.id))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.23,
                          left: mediaQuery.width * 0.56,
                          child: questions!.any((question) =>
                                  question!.answer_id == BodyPart.body.id)
                              ? Style.body(getIndexBody(BodyPart.body.id))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.37,
                          left: mediaQuery.width * 0.28,
                          child: questions!.any((question) =>
                                  question!.answer_id == BodyPart.right_leg.id)
                              ? Style.body(getIndexBody(BodyPart.right_leg.id))
                              : Container(),
                        ),
                        Positioned(
                          top: mediaQuery.height * 0.37,
                          left: mediaQuery.width * 0.63,
                          child: questions!.any((question) =>
                                  question!.answer_id == BodyPart.left_leg.id)
                              ? Style.body(getIndexBody(BodyPart.left_leg.id))
                              : Container(),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        //HEAD
                        GestureDetector(
                          onTap: _validateAddBite()
                              ? () {
                                  addToList(bodyQuestion['question']['text'],
                                      bodyQuestion['answers'][0]['text'],
                                      question_id:
                                          BiteQuestion.bitten_body_part.id,
                                      answer_id: BodyPart.head.id);
                                }
                              : null,
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
                              onTap: _validateAddBite()
                                  ? () {
                                      addToList(
                                          bodyQuestion['question']['text'],
                                          bodyQuestion['answers'][2]['text'],
                                          question_id:
                                              BiteQuestion.bitten_body_part.id,
                                          answer_id: BodyPart.right_arm.id);
                                    }
                                  : null,
                              child: Container(
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.1,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                            //CHEST
                            GestureDetector(
                              onTap: _validateAddBite()
                                  ? () {
                                      addToList(
                                          bodyQuestion['question']['text'],
                                          bodyQuestion['answers'][3]['text'],
                                          question_id:
                                              BiteQuestion.bitten_body_part.id,
                                          answer_id: BodyPart.body.id);
                                    }
                                  : null,
                              child: Container(
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.13,
                                width: mediaQuery.width * 0.15,
                              ),
                            ),
                            //ARM
                            GestureDetector(
                              onTap: _validateAddBite()
                                  ? () {
                                      addToList(
                                          bodyQuestion['question']['text'],
                                          bodyQuestion['answers'][1]['text'],
                                          question_id:
                                              BiteQuestion.bitten_body_part.id,
                                          answer_id: BodyPart.left_arm.id);
                                    }
                                  : null,
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
                              onTap: _validateAddBite()
                                  ? () {
                                      addToList(
                                          bodyQuestion['question']['text'],
                                          bodyQuestion['answers'][5]['text'],
                                          question_id:
                                              BiteQuestion.bitten_body_part.id,
                                          answer_id: BodyPart.right_leg.id);
                                    }
                                  : null,
                              child: Container(
                                color: Colors.transparent,
                                height: mediaQuery.height * 0.15,
                                width: mediaQuery.width * 0.18,
                              ),
                            ),
                            //LEG
                            GestureDetector(
                              onTap: _validateAddBite()
                                  ? () {
                                      addToList(
                                          bodyQuestion['question']['text'],
                                          bodyQuestion['answers'][4]['text'],
                                          question_id:
                                              BiteQuestion.bitten_body_part.id,
                                          answer_id: BodyPart.left_leg.id);
                                    }
                                  : null,
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
                  textAlign: TextAlign.center,
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Center(
                child: Style.button(MyLocalizations.of(context, 'reset'), () {
                  Utils.resetBitingQuestion();

                  var isValid = canContinue();
                  Utils.resetBitingQuestion();
                  setState(() {
                    valid = isValid;
                    questions = Utils.report!.responses;
                  });
                }),
              ),
              SizedBox(
                height: 24,
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: showDaytime
                    ? displayQuestions.length
                    : displayQuestions.length - 1,
                itemBuilder: (context, i) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Style.titleMedium(
                          MyLocalizations.of(
                              context, displayQuestions[i]['question']['text']),
                          fontSize: 16),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: displayQuestions[i]['answers'].length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 5 / 2,
                            ),
                            itemBuilder: (context, index) {
                              String? answerTxt =
                                  displayQuestions[i]['answers'][index]['text'];
                              String? questionTxt =
                                  displayQuestions[i]['question']['text'];
                              int? questionId =
                                  displayQuestions[i]['question']['id'];
                              int? answerId =
                                  displayQuestions[i]['answers'][index]['id'];
                              return Container(
                                padding: EdgeInsets.all(5),
                                child: InkWell(
                                  onTap: () {
                                    if (answerId == Answer.last_24h.id) {
                                      setState(() {
                                        showDaytime = true;
                                      });
                                    } else if (answerId == Answer.just_now.id) {
                                      setState(() {
                                        showDaytime = false;
                                      });
                                    }
                                    addToList(questionTxt, answerTxt,
                                        question_id: questionId,
                                        answer_id: answerId);
                                  },
                                  child: SmallQuestionOption(
                                    answerTxt,
                                    selected: questions!
                                        .any((q) => q!.answer_id == answerId),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                height: 54,
                child: Style.button(
                    MyLocalizations.of(context, 'continue_txt'),
                    valid
                        ? () {
                            widget.nextPage();
                          }
                        : null),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? getIndexBody(int answer_id) {
    var index = Utils.report!.responses!
        .indexWhere((question) => question!.answer_id == answer_id);

    if (index != -1) {
      return Utils.report!.responses![index]!.answer_value;
    }
    return null;
  }

  String? getIndexAnswer(int answer_id) {
    var index = 0;

    questions!.map((q) {
      if (q!.answer_id == answer_id) {
        index = index + 1;
      }
    }).toList();

    if (index > 0) {
      return index.toString();
    }
    return null;
  }

  addToList(String? question, String? answer,
      {question_id, answer_id, answer_value}) {
    if ((question_id != BiteQuestion.how_many.id &&
            int.parse(_textController.text) > 0) ||
        question_id == BiteQuestion.how_many.id) {
      Utils.addBiteResponse(
        question,
        answer,
        question_id: question_id,
        answer_id: answer_id,
        answer_value: answer_value,
      );

      setState(() {
        questions = Utils.report!.responses;
      });
      var isValid = canContinue();
      setState(() {
        valid = isValid;
      });
    }
  }

  bool _validateAddBite() {
    var totalParts = 0;
    questions!.forEach((q) {
      if (q!.question_id == BiteQuestion.bitten_body_part.id) {
        totalParts = totalParts + int.parse(q.answer_value!);
      }
    });
    return totalParts < bites;
  }

  bool canContinue() {
    if (questions!.length > 1 && questions!.isNotEmpty) {
      var totalBites = _validateAddBite();
      var totalQ3 = 0;
      var totalQ4 = 0;
      var totalQ5 = 0;

      questions!.forEach((q) {
        if (q!.question_id == BiteQuestion.vehicle_or_building.id) totalQ3++;
        if (q.question_id == BiteQuestion.when.id) totalQ4++;
        if (q.question_id == BiteQuestion.what_time.id) totalQ5++;
      });

      if (questions!.any((q) => q!.answer_id == Answer.last_24h.id)) {
        if (bites > 0 &&
            !totalBites &&
            totalQ3 == 1 &&
            totalQ4 == 1 &&
            totalQ5 == 1) {
          return true;
        }
      } else {
        if (bites > 0 && !totalBites && totalQ3 == 1 && totalQ4 == 1) {
          return true;
        }
      }
      return false;
    }
    return false;
  }

  void removeBite() {
    var bodyParts = Utils.report!.responses!
        .where((element) =>
            element!.question_id == BiteQuestion.bitten_body_part.id)
        .toList();
    if (bodyParts.isNotEmpty) {
      if (int.parse(bodyParts.last!.answer_value!) > 1) {
        bodyParts.last!.answer_value =
            (int.parse(bodyParts.last!.answer_value!) - 1).toString();
      } else {
        bodyParts.removeLast();
      }
    }

    Utils.report!.responses = <dynamic>{
      ...?Utils.report!.responses,
      ...bodyParts
    }.cast<Question?>().toList();
  }
}
