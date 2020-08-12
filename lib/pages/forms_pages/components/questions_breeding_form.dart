import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_photo_button_widget.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/image_question_option_widget.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class QuestionsBreedingForm extends StatefulWidget {
  final Map displayQuestion;
  final Function setValid;
  final bool hasImage;
  final Function nextPage;

  QuestionsBreedingForm(
      this.displayQuestion, this.setValid, this.hasImage, this.nextPage);

  @override
  _QuestionsBreedingFormState createState() => _QuestionsBreedingFormState();
}

class _QuestionsBreedingFormState extends State<QuestionsBreedingForm> {
  Question question;

  @override
  void initState() {
    super.initState();
    question = new Question(
      question: widget.displayQuestion['question']['text'],
      question_id: widget.displayQuestion['question']['id'],
    );
    if (Utils.report != null) {
      int index = Utils.report.responses.indexWhere(
          (q) => q.question_id == widget.displayQuestion['question']['id']);
      if (index != -1) {
        question.answer = Utils.report.responses[index].answer;
        question.answer_id = Utils.report.responses[index].answer_id;
        widget.setValid(true);
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
            widget.displayQuestion['question']['id'] == 10
                ? AddPhotoButton(true, true)
                : Container(),
            Style.title(MyLocalizations.of(context, widget.displayQuestion['question']['text'])),
            SizedBox(
              height: 30,
            ),
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.displayQuestion['answers'].length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: widget.hasImage ? 1 : 5 / 2,
                crossAxisSpacing: widget.hasImage ? 10 : 0,
              ),
              itemBuilder: (context, index) {
                String text =
                    widget.displayQuestion['answers'][index]['text'];
                int id = widget.displayQuestion['answers'][index]['id'];
                if (widget.hasImage) {
                  return Container(
                    child: GestureDetector(
                      onTap: () {
                        addQuestion(text, id);
                        widget.setValid(true);
                        widget.nextPage();
                      },
                      child: ImageQuestionOption(
                        question.answer_id == id ? true : false,
                        MyLocalizations.of(context, text),
                        widget.displayQuestion['answers'][index]['img'],
                      ),
                    ),
                  );
                }
                return Container(
                  padding: EdgeInsets.all(5),
                  child: GestureDetector(
                      onTap: () {
                        addQuestion(text, id);
                        widget.setValid(true);
                        widget.nextPage();
                      },
                      child: SmallQuestionOption(
                        text,
                        selected: question.answer_id == id,
                      )),
                );
              },
            ),
            Style.bottomOffset,
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
