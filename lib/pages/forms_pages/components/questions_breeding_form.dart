import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class QuestionsBreedingForm extends StatefulWidget {
  @override
  _QuestionsBreedingFormState createState() => _QuestionsBreedingFormState();
}

class _QuestionsBreedingFormState extends State<QuestionsBreedingForm> {
  Question question;

  @override
  void initState() {
    super.initState();
    question = new Question(
      question: '¿El nido tiene agua?',
      question_id: 8,
    );
    if (Utils.report != null) {
      int index = Utils.report.responses.indexWhere((q) => q.question_id == 8);
      if (index != -1) {
        question.answer = Utils.report.responses[index].answer;
        question.answer_id = Utils.report.responses[index].answer_id;
      }
    }
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
            Style.title('¿El nido tiene agua?'),
            SizedBox(
              height: 30,
            ),
            Row(children: <Widget>[
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        addQuestion('Tiene agua', 81);
                      },
                      child: SmallQuestionOption(
                        'Tiene agua',
                        selected: question.answer_id == 81,
                      ))),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        addQuestion('No tiene agua', 82);
                      },
                      child: SmallQuestionOption(
                        'No tiene agua',
                        selected: question.answer_id == 82,
                      ))),
            ]),
          ],
        ),
      ),
    );
  }

  addQuestion(answer, answerId) {
    setState(() {
      question.answer = answer;
      question.answer_id = answerId;
    });

    Utils.addResponse(question);
  }
}
