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
  StreamController<List<String>> streamData =
      new StreamController<List<String>>.broadcast();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: StreamBuilder<List<String>>(
            stream: streamData.stream,
            // initialData: 'head',
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
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
                        Image.asset("assets/img/ic_left_leg.png"),
                        Image.asset('assets/img/ic_right_leg.png'),
                        Image.asset('assets/img/ic_body.png'),
                        Image.asset('assets/img/ic_left_handf.png'),
                        Image.asset('assets/img/ic_right_hand.png'),
                        Image.asset('assets/img/ic_head.png'),
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
                      child: SmallQuestionOption('', selected: true),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: SmallQuestionOption(
                        '',
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 10,
                  ),
                  Row(children: <Widget>[
                    Expanded(
                      child: SmallQuestionOption(
                        '',
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: SmallQuestionOption(''),
                    ),
                  ]),
                  SizedBox(
                    height: 15,
                  ),
                  false
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

  addData(String data) {
    List<String> list = List();
    list.add(data);
    streamData.add(list);
  }
}
