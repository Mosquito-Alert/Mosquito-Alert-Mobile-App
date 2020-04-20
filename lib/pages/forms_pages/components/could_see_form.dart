import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class CouldSeeForm extends StatefulWidget {
  final Function addReport;

  CouldSeeForm(this.addReport);
  @override
  _CouldSeeFormState createState() => _CouldSeeFormState();
}

class _CouldSeeFormState extends State<CouldSeeForm> {
  String selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 35,
            ),
            Utils.report.type == "adult"
                ? Style.title('¿El mosquito te ha picado?')
                : Utils.report.type == "site"
                    ? Style.title('¿Has visto mosquitos alrededor del nido?')
                    : Container(),
            SizedBox(
              height: 30,
            ),
            Row(children: <Widget>[
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selected = 'si';
                        });
                        widget.addReport();
                      },
                      child: SmallQuestionOption(
                        'Si',
                        selected: selected == 'si' ? true : false,
                      ))),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selected = 'no';
                        });
                      },
                      child: SmallQuestionOption(
                        'No',
                        selected: selected == 'no' ? true : false,
                      ))),
            ]),
          ],
        ),
      ),
    );
  }
}
