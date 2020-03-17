import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_logation_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BitingReportPage extends StatefulWidget {
  @override
  _BitingReportPageState createState() => _BitingReportPageState();
}

class _BitingReportPageState extends State<BitingReportPage> {
  final List<String> questions = [
    "¿Cuándo te ha picado el mosquito?",
    "¿En que situación te ha picado?",
    "¿Dónde te ha picado?"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Style.title(MyLocalizations.of(context, "biting_report_txt"),
            fontSize: 16),
        actions: <Widget>[
          Style.noBgButton(
              MyLocalizations.of(context, "next"),
              true
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BitinLogationPage()),
                      );
                    }
                  : null)
        ],
      ),
      body: SafeArea(
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
                Container(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Style.titleMedium(questions[index], fontSize: 16),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: 4,
                                  itemBuilder: (ctx, index) {
                                    return QuestionOption(
                                      index == 1,
                                      "Por la tarde",
                                      'assets/img/ic_image.PNG',
                                    );
                                  })
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
