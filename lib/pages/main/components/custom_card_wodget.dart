import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class CustomCard extends StatelessWidget {
  final String img, title, subtitle;
  final bool selected, disabled;
  CustomCard(
      {this.img, this.title, this.subtitle, this.selected, this.disabled});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled == true ? 0.5 : 1,
      child: Container(
        // height: double.infinity,
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
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                        child: Image.asset(
                          img,
                          height: 100,
                          // fit: BoxFit.contain,
                        ),
                      )
                    : SizedBox(
                        height: 140,
                      ),
                SizedBox(
                  height: 30,
                  child: AutoSizeText(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                ),
                Expanded(
                  // height: 30,
                  child: Style.bodySmall(subtitle,
                      textAlign: TextAlign.center,
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
