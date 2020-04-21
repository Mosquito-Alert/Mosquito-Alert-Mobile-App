import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class PublicBreedingForm extends StatefulWidget {
  final Function skipReport;

  PublicBreedingForm(this.skipReport);
  @override
  _PublicBreedingFormState createState() => _PublicBreedingFormState();
}

class _PublicBreedingFormState extends State<PublicBreedingForm> {
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
            Style.title('¿El nido se econtraba en un lugar publico o privafo?'),
            SizedBox(
              height: 30,
            ),
            Row(children: <Widget>[
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selected = 'public';
                        });
                      },
                      child: SmallQuestionOption(
                        'Publico',
                        selected: selected == 'public' ? true : false,
                      ))),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        widget.skipReport();
                        setState(() {
                          selected = 'private';
                        });
                      },
                      child: SmallQuestionOption(
                        'Privado',
                        selected: selected == 'private' ? true : false,
                      ))),
            ]),
          ],
        ),
      ),
    );
  }
}
