import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class SmallQuestionOption extends StatelessWidget {
  final bool selected;
  SmallQuestionOption({this.selected});

  @override
  Widget build(BuildContext context) {
    return selected == null || !selected
        ? Container(
            alignment: Alignment.center,
            // height: 45,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2,
                  )
                ]),
            child: Style.body('Amanecer'),
          )
        : Container(
            alignment: Alignment.center,
            // height: 45,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Style.colorPrimary,
              borderRadius: BorderRadius.circular(15),
              // boxShadow: [
              //   new BoxShadow(
              //     color: Colors.grey,
              //     blurRadius: 2,
              //   )
              // ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white.withOpacity(0.4),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Style.body('2', color: Colors.white),
                ),
                Style.body(
                  'Amanecer',
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          );
  }
}
