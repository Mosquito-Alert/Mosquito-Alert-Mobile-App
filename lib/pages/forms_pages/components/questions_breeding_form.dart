import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'add_photo_button_widget.dart';

class QuestionsBreedingForm extends StatefulWidget {
  final Map displayQuestion;

  QuestionsBreedingForm(this.displayQuestion);

  @override
  _QuestionsBreedingFormState createState() => _QuestionsBreedingFormState();
}

class _QuestionsBreedingFormState extends State<QuestionsBreedingForm> {
  Question question;

  @override
  void initState() {
    super.initState();
    question = new Question(
      question: widget.displayQuestion['question']['text']['es'],
      question_id: widget.displayQuestion['question']['id'],
    );
    if (Utils.report != null) {
      int index = Utils.report.responses.indexWhere(
          (q) => q.question_id == widget.displayQuestion['question']['id']);
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
                        addQuestion(text, id);
                      },
                      child: SmallQuestionOption(
                        text,
                        selected: question.answer_id == id,
                      )),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(),
            ),
            AddPhotoButton(),
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
