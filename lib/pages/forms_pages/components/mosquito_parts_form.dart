import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/models/question.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/image_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class MosquitoPartsForm extends StatefulWidget {
  @override
  _MosquitoPartsFormState createState() => _MosquitoPartsFormState();
}

class _MosquitoPartsFormState extends State<MosquitoPartsForm> {
  List<Question> questions = List();

  @override
  Widget build(BuildContext context) {
    var sizeWidth = MediaQuery.of(context).size.width;
    return SafeArea(
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
              height: 100,
              child: ListView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        onSelect('answer', (index + 711).toString());
                      },
                      child: Container(
                        width: sizeWidth * 0.22,
                        margin: EdgeInsets.only(right: 5),
                        child: ImageQuestionOption(
                          questions.any(
                              (q) => q.answer_id == (index + 711).toString()),
                          '',
                          '',
                          'assets/img/placeholder.jpg',
                          disabled: questions.length != null
                              ? isDisabled(710, index + 711)
                              : false,
                        ),
                      ),
                    );
                  }),
            ),
            Container(
              height: 100,
              child: ListView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        onSelect('answer', (index + 721).toString());
                      },
                      child: Container(
                        width: sizeWidth * 0.22,
                        margin: EdgeInsets.only(right: 5),
                        // color: Colors.green,
                        child: ImageQuestionOption(
                          questions.any(
                              (q) => q.answer_id == (index + 721).toString()),
                          '',
                          '',
                          'assets/img/placeholder.jpg',
                          disabled: questions.length != null
                              ? isDisabled(720, (index + 721))
                              : false,
                        ),
                      ),
                    );
                  }),
            ),
            Container(
              height: 100,
              child: ListView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        onSelect('answer', (index + 731).toString());
                      },
                      child: Container(
                        width: sizeWidth * 0.22,
                        margin: EdgeInsets.only(right: 5),
                        // color: Colors.green,
                        child: ImageQuestionOption(
                          questions.any(
                              (q) => q.answer_id == (index + 731).toString()),
                          '',
                          '',
                          'assets/img/placeholder.jpg',
                          disabled: questions.length != null
                              ? isDisabled(730, (index + 731))
                              : false,
                        ),
                      ),
                    );
                  }),
            ),
            // Container(
            //   height: 100,
            //   child: ListView.builder(
            //       itemCount: 4,
            //       shrinkWrap: true,
            //       physics: NeverScrollableScrollPhysics(),
            //       scrollDirection: Axis.horizontal,
            //       itemBuilder: (context, index) {
            //         return Container(
            //           width: sizeWidth * 0.22,
            //           margin: EdgeInsets.only(right: 5),
            //           // color: Colors.green,
            //           child: ImageQuestionOption(
            //             false,
            //             '',
            //             '',
            //             'assets/img/placeholder.jpg',
            //           ),
            //         );
            //       }),
            // ),
            SizedBox(
              height: 15,
            ),
            Center(child: Style.noBgButton("No lo tengo claro", () {}))
          ],
        ),
      ),
    );
  }

  onSelect(answer, answerId) {
    Question newQuestion = new Question(
      question: '¿Como era el mosquito?',
      answer: answer,
      question_id: '7',
      answer_id: answerId.toString(),
    );

    setState(() {
      questions.add(newQuestion);
    });

    Utils.addResponse(newQuestion);
  }

  bool isDisabled(int index, int aswerId) {
    var group = questions
        .where((q) =>
            int.parse(q.answer_id) >= index &&
            int.parse(q.answer_id) < index + 10)
        .toList();

    print(group.any((q) => q.answer_id != aswerId.toString()));
    return group.any((q) => q.answer_id != aswerId.toString());
  }
}
