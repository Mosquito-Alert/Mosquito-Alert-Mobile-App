import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/image_question_option_widget.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class MosquitoPartsForm extends StatefulWidget {
  @override
  _MosquitoPartsFormState createState() => _MosquitoPartsFormState();
}

class _MosquitoPartsFormState extends State<MosquitoPartsForm> {
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
                    return Container(
                      width: sizeWidth * 0.22,
                      margin: EdgeInsets.only(right: 5),
                      child: ImageQuestionOption(
                        false,
                        '',
                        '',
                        'assets/img/placeholder.jpg',
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
                    return Container(
                      width: sizeWidth * 0.22,
                      margin: EdgeInsets.only(right: 5),
                      // color: Colors.green,
                      child: ImageQuestionOption(
                        false,
                        '',
                        '',
                        'assets/img/placeholder.jpg',
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
                    return Container(
                      width: sizeWidth * 0.22,
                      margin: EdgeInsets.only(right: 5),
                      // color: Colors.green,
                      child: ImageQuestionOption(
                        false,
                        '',
                        '',
                        'assets/img/placeholder.jpg',
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
                    return Container(
                      width: sizeWidth * 0.22,
                      margin: EdgeInsets.only(right: 5),
                      // color: Colors.green,
                      child: ImageQuestionOption(
                        false,
                        '',
                        '',
                        'assets/img/placeholder.jpg',
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: 15,
            ),
            Center(child: Style.noBgButton("No lo tengo claro", () {}))
          ],
        ),
      ),
    );
  }
}
