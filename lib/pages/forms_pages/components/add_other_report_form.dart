import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/breeding_report_page.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_wodget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

import '../biting_report_page.dart';

class AddOtherReportPage extends StatelessWidget {
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
            Style.title('¿Quieres reportar otro elemento?'),
            SizedBox(
              height: 15,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Utils.addOtherReport('bite');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BitingReportPage()),
                      );
                    },
                    child: CustomCard(
                      img: 'assets/img/mosquito_placeholder.PNG',
                      title: MyLocalizations.of(context, 'report_biting_txt'),
                      subtitle: MyLocalizations.of(
                          context, 'bitten_by_mosquito_question_txt'),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Utils.addOtherReport('site');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BreedingReportPage()),
                      );
                    },
                    child: CustomCard(
                      img: 'assets/img/mosquito_placeholder.PNG',
                      title: MyLocalizations.of(context, 'report_nest_txt'),
                      subtitle: MyLocalizations.of(
                          context, 'found_breeding_place_question_txt'),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Utils.addOtherReport('adult');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdultReportPage()),
                      );
                    },
                    child: CustomCard(
                      img: 'assets/img/mosquito_placeholder.PNG',
                      title: MyLocalizations.of(context, 'report_adults_txt'),
                      subtitle: MyLocalizations.of(
                          context, 'report_us_adult_mosquitos_txt'),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => BitingReportPage()),
                      // );
                    },
                    child: CustomCard(
                      // img: '',
                      title: MyLocalizations.of(context, 'exit'),
                      subtitle: 'No quiero añadir otro reporte',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
