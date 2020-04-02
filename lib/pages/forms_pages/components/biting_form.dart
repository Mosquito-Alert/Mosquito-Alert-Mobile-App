import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BitingForm extends StatefulWidget {
  @override
  _BitingFormState createState() => _BitingFormState();
}

class _BitingFormState extends State<BitingForm> {
  StreamController<List<dynamic>> streamData =
      new StreamController<List<String>>.broadcast();

  List questions = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // streamData.add(questions);
    questions = [
      List.of({
        "leftArm",
        "leftArm",
        "head",
      }),
      List.of({'1'}),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                        Container(),
                        // Image.asset("assets/img/ic_left_leg_off.png"),
                        // Image.asset('assets/img/ic_right_leg_off.png'),
                        new GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            print('chest');
                          },
                          child: Image.asset('assets/img/ic_chest_off.png'),
                        ),
                        // Image.asset('assets/img/ic_left_hand_off.png'),
                        // new GestureDetector(
                        //     behavior: HitTestBehavior.translucent,
                        //     onTap: () {
                        //       print('no head');
                        //     },
                        //     child: Image.asset(
                        //         'assets/img/ic_right_hand_off.png')),
                        new GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              print('head');
                            },
                            child: Image.asset('assets/img/ic_head_off.png'))
                      ],
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
                          index: getIndexAnswer('0'),
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
                          index: getIndexAnswer('1'),
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
                          index: getIndexAnswer('2'),
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
                          index: getIndexAnswer('3'),
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 15,
                  ),
                  canContinue()
                  // false
                      ? Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Style.colorPrimary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Style.body('Continuar',
                              textAlign: TextAlign.center, color: Colors.white),
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Style.body(
                              'Complete todos los campos para continuar',
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


  String getIndexAnswer(String answer) {
    List answers = questions[1];
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

  bool canContinue(){
    List parts = questions[0];
    List time = questions[1]; 
    return parts.length == time.length;
  }
}
