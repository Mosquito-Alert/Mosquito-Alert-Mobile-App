import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class CustomCard extends StatelessWidget {
  final String? img, title;
  final bool? selected, disabled;
  CustomCard({this.img, this.title, this.selected, this.disabled});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled == true ? 0.5 : 1,
      child: Container(
        child: Card(
          color: selected == true ? Style.colorPrimary : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: disabled == true ? 0 : 3,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                img != null
                    ? Expanded(
                        flex: MediaQuery.of(context).textScaleFactor < 1.23
                            ? 3
                            : 2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                          child: Image.asset(
                            img!,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 140,
                      ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Style.titleMedium(title,
                        textAlign: TextAlign.center, fontSize: 16
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
