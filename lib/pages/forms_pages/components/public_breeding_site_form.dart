import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class PublicBreedingForm extends StatefulWidget {
  final Function skipReport;
  final Map displayQuestion;
  final Function setValid;
  final bool selectPublic;

  PublicBreedingForm(
      this.skipReport, this.displayQuestion, this.setValid, this.selectPublic);
  @override
  _PublicBreedingFormState createState() => _PublicBreedingFormState();
}

class _PublicBreedingFormState extends State<PublicBreedingForm> {
  int selected;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.selectPublic ? selected = 91 : selected = 92;
  }

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
                          selected = id;
                        });
                        id == 92
                            ? widget.skipReport(true)
                            : widget.skipReport(false);
                        widget.setValid(true);
                      },
                      child: SmallQuestionOption(
                        text,
                        selected: selected == id,
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
