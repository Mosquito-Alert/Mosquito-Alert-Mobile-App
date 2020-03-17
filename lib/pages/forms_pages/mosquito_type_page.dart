import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/small_question_option_widget.dart';
import 'package:mosquito_alert_app/pages/main/main_vc.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class MosquitoTypePage extends StatefulWidget {
  @override
  _MosquitoTypePageState createState() => _MosquitoTypePageState();
}

class _MosquitoTypePageState extends State<MosquitoTypePage> {
  int _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Style.title(MyLocalizations.of(context, "biting_report_txt"),
            fontSize: 16),
        actions: <Widget>[
          Style.noBgButton(
              MyLocalizations.of(context, "finish"),
              _selectedIndex != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainVC()),
                      );
                    }
                  : null)
        ],
      ),
      body: SafeArea(
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, crossAxisSpacing: 10),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          itemBuilder: (ctx, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              child: SmallQuestionOption(
                                false,
                                "TITULO",
                                MyLocalizations.of(context, "recognize_it_txt"),
                                'assets/img/placeholder.jpg',
                                disabled: _selectedIndex != null
                                    ? index != _selectedIndex
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
                Card(
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
                                  MyLocalizations.of(context,
                                      'have_foto_txt'),
                                  
                                  fontSize: 16),
                              SizedBox(
                                height: 5,
                              ),
                              Style.bodySmall(
                                  MyLocalizations.of(
                                    context, 'click_to_add_txt')
                                 )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
