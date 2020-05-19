import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class CouldSeeForm extends StatefulWidget {
  final Function addReport;
  final Map displayQuestion;

  CouldSeeForm(this.addReport, this.displayQuestion);
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
            // Utils.report.type == "adult"
            //     ? Style.title('¿El mosquito te ha picado?')
            //     : Utils.report.type == "site"
            //         ? Style.title('¿Has visto mosquitos alrededor del nido?')
            //         : Container(),
            Style.title(widget.displayQuestion['question']['text']['es']),
            SizedBox(
              height: 30,
            ),

            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.displayQuestion['answers'].length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 5 / 2,
                // crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                String text =
                    widget.displayQuestion['answers'][index]['text']['es'];
                int id = widget.displayQuestion['answers'][index]['id'];
                return Container(
                  padding: EdgeInsets.all(5),
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selected = text;
                        });
                        id == 101 ? widget.addReport() : null;
                      },
                      child: SmallQuestionOption(
                        text,
                        selected: selected == text,
                      )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
