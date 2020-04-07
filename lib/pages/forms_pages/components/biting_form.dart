import 'dart:async';

import 'package:flutter/material.dart';
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

  List questions = new List(); // TODO: list<Questions>

  @override
  void initState() {
    Utils.createNewReport('bite');
    // TODO: implement initState
    super.initState();
    // streamData.add(questions);
    questions = [
      List.of({
        // "leftHand",
        // "leftHand",
        // "chest",
      }),
      List.of({
        // '1'
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: StreamBuilder<List<dynamic>>(
            stream: streamData.stream,
            initialData: questions,
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              // if(!snapshot.hasData){
              //   return Container(color: Colors.grey,);
              // }
              return Column(
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
                  Style.titleMedium(
                      '¿Cuántas picaduras quieres reportar y dónde?',
                      fontSize: 16),
                  Container(
                    alignment: Alignment.topLeft,
                    child: Stack(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Image.asset('assets/img/ic_full_body_off.png'),
                            snapshot.data[0].contains('leftLeg')
                                ? Image.asset('assets/img/ic_left_leg_on.png')
                                : Image.asset("assets/img/ic_left_leg_off.png"),
                            snapshot.data[0].contains('rightLeg')
                                ? Image.asset('assets/img/ic_right_leg_on.png')
                                : Image.asset(
                                    'assets/img/ic_right_leg_off.png'),
                            snapshot.data[0].contains('leftHand')
                                ? Image.asset('assets/img/ic_left_hand_on.png')
                                : Image.asset(
                                    'assets/img/ic_left_hand_off.png'),
                            snapshot.data[0].contains('rightHand')
                                ? Image.asset('assets/img/ic_right_hand_on.png')
                                : Image.asset(
                                    'assets/img/ic_right_hand_off.png'),
                            snapshot.data[0].contains('head')
                                ? Image.asset('assets/img/ic_head_on.png')
                                : Image.asset('assets/img/ic_head_off.png'),
                            snapshot.data[0].contains('chest')
                                ? Image.asset('assets/img/ic_chest_on.png')
                                : Image.asset('assets/img/ic_chest_off.png'),
                            Positioned(
                              top: mediaQuery.height * 0.05,
                              left: mediaQuery.width * 0.37,
                              child: snapshot.data[0].contains('head')
                                  ? Style.body(getIndexAnswer(0, "head"))
                                  : Container(),
                            ),
                            Positioned(
                              top: mediaQuery.height * 0.18,
                              left: mediaQuery.width * 0.21,
                              child: snapshot.data[0].contains('rightHand')
                                  ? Style.body(getIndexAnswer(0, "rightHand"))
                                  : Container(),
                            ),
                            Positioned(
                              top: mediaQuery.height * 0.18,
                              left: mediaQuery.width * 0.70,
                              child: snapshot.data[0].contains('leftHand')
                                  ? Style.body(getIndexAnswer(0, "leftHand"))
                                  : Container(),
                            ),
                            Positioned(
                              top: mediaQuery.height * 0.23,
                              left: mediaQuery.width * 0.56,
                              child: snapshot.data[0].contains('chest')
                                  ? Style.body(getIndexAnswer(0, "chest"))
                                  : Container(),
                            ),
                            Positioned(
                              top: mediaQuery.height * 0.37,
                              left: mediaQuery.width * 0.28,
                              child: snapshot.data[0].contains('rightLeg')
                                  ? Style.body(getIndexAnswer(0, "rightLeg"))
                                  : Container(),
                            ),
                            Positioned(
                              top: mediaQuery.height * 0.37,
                              left: mediaQuery.width * 0.63,
                              child: snapshot.data[0].contains('leftLeg')
                                  ? Style.body(getIndexAnswer(0, "leftLeg"))
                                  : Container(),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            //HEAD
                            GestureDetector(
                              onTap: () {
                                addToList(0, "head");
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
                                    addToList(0, "rightHand");
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
                                    addToList(0, "chest");
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
                                    addToList(0, "leftHand");
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
                                    addToList(0, "rightLeg");
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
                                    addToList(0, 'leftLeg');
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
                          addToList(1, '0');
                        },
                        child: SmallQuestionOption(
                          'Amanecer',
                          selected: snapshot.data[1].contains('0'),
                          // selected: true,
                          index: getIndexAnswer(1, '0'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          addToList(1, '1');
                        },
                        child: SmallQuestionOption(
                          'Mediodía',
                          selected: snapshot.data[1].contains('1'),
                          index: getIndexAnswer(1, '1'),
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
                          addToList(1, '2');
                        },
                        child: SmallQuestionOption(
                          'Atardecer',
                          selected: snapshot.data[1].contains('2'),
                          index: getIndexAnswer(1, '2'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          addToList(1, '3');
                        },
                        child: SmallQuestionOption(
                          'Noche',
                          selected: snapshot.data[1].contains('3'),
                          index: getIndexAnswer(1, '3'),
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
              );
            },
          ),
        ),
      ),
    );
  }

  String getIndexAnswer(int i, String answer) {
    List answers = questions[i];
    int index = 0;
    for (int i = 0; i < answers.length; i++) {
      if (answers[i] == answer) {
        index++;
      }
    }

    return index.toString();
  }

  addToList(int index, String data) {
    // print(questions[index]);
    setState(() {
      questions[index].add(data);
    });

    streamData.add(questions);
  }

  bool canContinue() {
    List parts = questions[0];
    List time = questions[1];
    if (parts.length == time.length) {
      Utils.setContinue();
      return true;
    }
    return false;
  }
}
