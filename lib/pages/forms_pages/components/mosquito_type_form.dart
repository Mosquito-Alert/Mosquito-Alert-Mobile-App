import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'image_question_option_widget.dart';

class MosquitoTypeForm extends StatefulWidget {
  final Function setSkip3;
  final Map displayQuestion;
  final Function setValid, showCamera, nextPage, skipReport;

  MosquitoTypeForm(this.setSkip3, this.displayQuestion, this.setValid,
      this.showCamera, this.nextPage, this.skipReport);
  @override
  _MosquitoTypeFormState createState() => _MosquitoTypeFormState();
}

class _MosquitoTypeFormState extends State<MosquitoTypeForm> {
  Question question = Question();
  String language;

  @override
  void initState() {
    super.initState();
    language = Utils.getLanguage();
    question = new Question(
        question: widget.displayQuestion['question']['text'][language],
        question_id: widget.displayQuestion['question']['id']);
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
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          // height: double.infinity,
          // width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 35,
              ),
              Style.title(widget.displayQuestion['question']['text'][language]),
              Style.body(MyLocalizations.of(context, "could_recognise_txt")),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, crossAxisSpacing: 10),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.displayQuestion['answers'].length,
                        itemBuilder: (ctx, index) {
                          return GestureDetector(
                            onTap: () {
                              onSelect(
                                  widget.displayQuestion['answers'][index]
                                      ['text'][language],
                                  widget.displayQuestion['answers'][index]
                                      ['id']);

                              widget.displayQuestion['answers'][index]['id'] ==
                                      63
                                  ? widget.skipReport(true)
                                  : widget.nextPage();

                              widget.displayQuestion['answers'][index]['id'] ==
                                      61
                                  ? widget.setSkip3(true)
                                  : widget.setSkip3(false);
                            },
                            child: ImageQuestionOption(
                              question.answer_id ==
                                      (widget.displayQuestion['answers'][index]
                                          ['id'])
                                  ? true
                                  : false,
                              widget.displayQuestion['answers'][index]['text']
                                  [language],
                              widget.displayQuestion['answers'][index]['id'] ==
                                      63
                                  ? MyLocalizations.of(
                                      context, "not_a_mosquito")
                                  : MyLocalizations.of(
                                      context, "recognize_it_txt"),
                              widget.displayQuestion['answers'][index]['img'],
                              disabled: question.answer_id != null &&
                                  widget.displayQuestion['answers'][index]
                                          ['id'] !=
                                      question.answer_id,
                            ),
                          );
                        })
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10.0),
              //   child: Divider(),
              // ),
              // AddPhotoButton(),
              Style.bottomOffset,
            ],
          ),
        ),
      ),
    );
  }

  onSelect(answer, answerId) {
    setState(() {
      question.answer = answer;
      question.answer_id = answerId;
    });
    // widget.setValid(true);
    Utils.addResponse(question);
  }
}
