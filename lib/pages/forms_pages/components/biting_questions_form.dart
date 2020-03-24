import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BitingQuestionsForm extends StatelessWidget {
  final List<Map<String, List<String>>> questions;
  final List<Questions> responses;
  final Function addResponses;

  BitingQuestionsForm(this.questions, this.addResponses, this.responses);

  @override
  Widget build(BuildContext context) {
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
                            Style.titleMedium(questions[index]['question'][0],
                                fontSize: 16),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: questions[index]['answers'].length,
                                itemBuilder: (ctx, i) {
                                  return GestureDetector(
                                    onTap: () {
                                      addResponses(
                                        questions[index]['question'][0],
                                        questions[index]['answers'][i],
                                      );
                                    },
                                    child: QuestionOption(
                                      selectedAnswer(
                                          questions[index]['question'][0],   // TODO: fix selector state
                                          questions[index]['answers'][i]),
                                      questions[index]['answers'][i],
                                      'assets/img/ic_image.PNG',
                                    ),
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
    );
  }

  bool selectedAnswer(String currentQuestion, String currentAnswer) {
    if (responses.length > 0) {
      int currentIndex = responses
          .indexWhere((question) => responses.contains(currentQuestion));
      if (currentIndex != -1) {
        if (responses[currentIndex].answer == currentAnswer) {
          return true;
        }
      }
    }
    return false;
  }
}
