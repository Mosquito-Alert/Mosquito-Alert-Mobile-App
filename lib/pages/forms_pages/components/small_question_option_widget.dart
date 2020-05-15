import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class SmallQuestionOption extends StatelessWidget {
  final bool selected, disabled;
  final String text, index;
  SmallQuestionOption(
    this.text, {
    this.selected,
    this.index,
    this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return selected == null || !selected
        ? Opacity(
            opacity: disabled == null || !disabled ? 1.0 : 0.5,
            child: Container(
              alignment: Alignment.center,
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
              child: Style.body(text),
            ),
          )
        : Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(index != null ? 15 : 20),
            decoration: BoxDecoration(
              color: Style.colorPrimary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                index != null
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white.withOpacity(0.4),
                        ),
                        padding: EdgeInsets.all(5),
                        child: Style.body(index, color: Colors.white),
                      )
                    : Container(),
                Style.body(
                  text,
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
