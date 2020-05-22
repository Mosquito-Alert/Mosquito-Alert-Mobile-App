import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/image_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class MosquitoPartsForm extends StatefulWidget {
  final Map displayQuestion;

  MosquitoPartsForm(this.displayQuestion);
  @override
  _MosquitoPartsFormState createState() => _MosquitoPartsFormState();
}

class _MosquitoPartsFormState extends State<MosquitoPartsForm> {
  List<Question> questions = List();

  List<String> torax;

  @override
  void initState() {
    super.initState();

    if (Utils.report != null) {
      for (Question q in Utils.report.responses) {
        if (q.question_id == 7) {
          questions.add(q);
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
              Style.title('¿Como era el mosquito?'),
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
                          ['text']['es'];
                      print(txt);
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
                      int i = 711;
                      int id =
                          widget.displayQuestion['answers'][1][index]['id'];
                      String txt = widget.displayQuestion['answers'][1][index]
                          ['text']['es'];
                      print(txt);
                      return GestureDetector(
                        onTap: () {
                          onSelect(txt, id, 720);
                        },
                        child: Container(
                          width: sizeWidth * 0.22,
                          margin: EdgeInsets.only(right: 5),
                          child: ImageQuestionOption(
                            questions.any((q) => q.answer_id == i),
                            '',
                            '',
                            widget.displayQuestion['answers'][1][index]['img'],
                            disabled: questions.length != null
                                ? isDisabled(710, index + 721)
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
                      int i = 711;
                      int id =
                          widget.displayQuestion['answers'][2][index]['id'];
                      String txt = widget.displayQuestion['answers'][2][index]
                          ['text']['es'];
                      print(txt);
                      return GestureDetector(
                        onTap: () {
                          onSelect(txt, id, 710);
                        },
                        child: Container(
                          width: sizeWidth * 0.22,
                          margin: EdgeInsets.only(right: 5),
                          child: ImageQuestionOption(
                            questions.any((q) => q.answer_id == i),
                            '',
                            '',
                            widget.displayQuestion['answers'][2][index]['img'],
                            disabled: questions.length != null
                                ? isDisabled(710, index + 711)
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
            ],
          ),
        ),
      ),
    );
  }

  onSelect(answer, answerId, int i) {
    Utils.addAdultPartsResponse(answer, answerId, i);

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
