import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/take_picture_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import 'image_question_option_widget.dart';

class MosquitoTypeForm extends StatefulWidget {
  final Function setSkip3;

  MosquitoTypeForm(this.setSkip3);
  @override
  _MosquitoTypeFormState createState() => _MosquitoTypeFormState();
}

class _MosquitoTypeFormState extends State<MosquitoTypeForm> {
  Question question;

  @override
  void initState() {
    super.initState();
    question = new Question(
        question: '¿Pudiste reconocer el mosquito?', question_id: 6);
    if (Utils.report != null) {
      int index = Utils.report.responses.indexWhere((q) => q.question_id == 6);
      question.answer = Utils.report.responses[index].answer;
      question.answer_id = Utils.report.responses[index].answer_id;
    } else {
      Utils.createNewReport('adult');
    }
  }

  List<String> answers = [
    'Invasive Aedes',
    'Mosquito Común',
    'Otro',
    'No lo sé'
  ];

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
              Style.title(MyLocalizations.of(context, "could_see_txt")),
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
                        itemCount: answers.length,
                        itemBuilder: (ctx, index) {
                          return GestureDetector(
                            onTap: () {
                              onSelect(answers[index], (index + 61));
                              index == 1
                                  ? widget.setSkip3()
                                  : null; // skip when type = comon mosquito
                            },
                            child: ImageQuestionOption(
                              question.answer_id == (index + 61) ? true : false,
                              answers[index],
                              MyLocalizations.of(context, "recognize_it_txt"),
                              'assets/img/ic_other_mosquito.png',
                              disabled: question.answer_id != null
                                  ? (index + 61) != question.answer_id
                                  : false,
                            ),
                          );
                        })
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TakePicturePage()),
                  );
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 25, horizontal: 10),
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                            )),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Style.titleMedium(
                                  MyLocalizations.of(context, 'have_foto_txt'),
                                  fontSize: 16),
                              SizedBox(
                                height: 5,
                              ),
                              Style.bodySmall(MyLocalizations.of(
                                  context, 'click_to_add_txt'))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
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
    Utils.addResponse(question);
  }
}
