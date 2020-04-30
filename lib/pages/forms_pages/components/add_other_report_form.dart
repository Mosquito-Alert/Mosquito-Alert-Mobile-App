import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_wodget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class AddOtherReportPage extends StatefulWidget {
  final Function addReport;

  AddOtherReportPage(this.addReport);

  @override
  _AddOtherReportPageState createState() => _AddOtherReportPageState();
}

class _AddOtherReportPageState extends State<AddOtherReportPage> {
  String selectedType;

  setSelected(String type) {
    if (type != 'none') {
      widget.addReport(type);
    }

    setState(() {
      selectedType = type;
    });
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
            Style.title('¿Quieres reportar otro elemento?'),
            SizedBox(
              height: 15,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setSelected("bite");
                    },
                    child: CustomCard(
                      img: 'assets/img/ic_bite_report.png',
                      title: MyLocalizations.of(context, 'report_biting_txt'),
                      subtitle: MyLocalizations.of(
                          context, 'bitten_by_mosquito_question_txt'),
                      selected: selectedType == 'bite',
                      disabled: selectedType != 'bite',
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setSelected('site');
                    },
                    child: CustomCard(
                      img: 'assets/img/ic_breeding_report.png',
                      title: MyLocalizations.of(context, 'report_nest_txt'),
                      subtitle: MyLocalizations.of(
                          context, 'found_breeding_place_question_txt'),
                      selected: selectedType == 'site',
                      disabled: selectedType != 'site',
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
                      setSelected('adult');
                    },
                    child: CustomCard(
                      img: 'assets/img/ic_mosquito_report.png',
                      title: MyLocalizations.of(context, 'report_adults_txt'),
                      subtitle: MyLocalizations.of(
                          context, 'report_us_adult_mosquitos_txt'),
                      selected: selectedType == 'adult',
                      disabled: selectedType != 'adult',
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setSelected('none');
                    },
                    child: CustomCard(
                      // img: '',
                      title: MyLocalizations.of(context, 'exit'),
                      subtitle: 'No quiero añadir otro reporte',
                      selected: selectedType == 'none',
                      disabled: selectedType != 'none',
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
