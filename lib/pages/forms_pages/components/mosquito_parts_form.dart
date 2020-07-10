import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_photo_button_widget.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/image_question_option_widget.dart';
import 'package:mosquito_alert_app/pages/info_pages/info_page.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class MosquitoPartsForm extends StatefulWidget {
  final Map displayQuestion;
  final Function setValid;

  MosquitoPartsForm(this.displayQuestion, this.setValid);
  @override
  _MosquitoPartsFormState createState() => _MosquitoPartsFormState();
}

class _MosquitoPartsFormState extends State<MosquitoPartsForm> {
  List<Question> questions = List();
  String language;

  @override
  void initState() {
    super.initState();

    language = Utils.getLanguage();
    if (Utils.report != null) {
      for (Question q in Utils.report.responses) {
        if (q.question_id == widget.displayQuestion['question']['id']) {
          questions.add(q);
          widget.setValid(true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var sizeWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 40,
              ),
              AddPhotoButton(),
              Style.title(widget.displayQuestion['question']['text'][language]),
               SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InfoPage('d')),
                  );
                },
                child: Style.bodySmall("mas ifno de eto", color: Style.colorPrimary),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 200,
                child: ListView.builder(
                    itemCount: 4,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      int id =
                          widget.displayQuestion['answers'][0][index]['id'];
                      String txt = widget.displayQuestion['answers'][0][index]
                          ['text'][language];

                      return GestureDetector(
                        onTap: () {
                          onSelect(txt, id, 710);
                        },
                        child: Container(
                          width: sizeWidth * 0.22,
                          margin: EdgeInsets.only(right: 5),
                          child: ImageQuestionOption(
                            questions.any((q) => q.answer_id == id),
                            '',
                            '',
                            widget.displayQuestion['answers'][0][index]['img'],
                            disabled: questions.length != null
                                ? isDisabled(710, id)
                                : false,
                          ),
                        ),
                      );
                    }),
              ),
              Container(
                height: 200,
                child: ListView.builder(
                    itemCount: 4,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      int id =
                          widget.displayQuestion['answers'][1][index]['id'];
                      String txt = widget.displayQuestion['answers'][1][index]
                          ['text'][language];
                      return GestureDetector(
                        onTap: () {
                          onSelect(txt, id, 720);
                        },
                        child: Container(
                          width: sizeWidth * 0.22,
                          margin: EdgeInsets.only(right: 5),
                          child: ImageQuestionOption(
                            questions.any((q) => q.answer_id == id),
                            '',
                            '',
                            widget.displayQuestion['answers'][1][index]['img'],
                            disabled: questions.length != null
                                ? isDisabled(720, id)
                                : false,
                          ),
                        ),
                      );
                    }),
              ),
              Container(
                height: 200,
                child: ListView.builder(
                    itemCount: 4,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      int id =
                          widget.displayQuestion['answers'][2][index]['id'];
                      String txt = widget.displayQuestion['answers'][2][index]
                          ['text'][language];
                      return GestureDetector(
                        onTap: () {
                          onSelect(txt, id, 730);
                        },
                        child: Container(
                          width: sizeWidth * 0.22,
                          margin: EdgeInsets.only(right: 5),
                          child: ImageQuestionOption(
                            questions.any((q) => q.answer_id == id),
                            '',
                            '',
                            widget.displayQuestion['answers'][2][index]['img'],
                            disabled: questions.length != null
                                ? isDisabled(730, id)
                                : false,
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 15,
              ),
              // Center(child: Style.noBgButton("No lo tengo claro", () {}))
              Style.bottomOffset,
            ],
          ),
        ),
      ),
    );
  }

  onSelect(answer, answerId, int i) {
    Utils.addAdultPartsResponse(answer, answerId, i);

    var list = Utils.report.responses
        .where((q) => q.question_id == widget.displayQuestion['question']['id'])
        .toList();
    if (list.length == 3) {
      widget.setValid(true);
    } else {
      widget.setValid(false);
    }

    setState(() {
      questions = Utils.report.responses;
    });
  }

  bool isDisabled(int index, int aswerId) {
    var group = questions
        .where((q) => q.answer_id >= index && q.answer_id < index + 10)
        .toList();

    return group.any((q) => q.answer_id != aswerId);
  }
}
