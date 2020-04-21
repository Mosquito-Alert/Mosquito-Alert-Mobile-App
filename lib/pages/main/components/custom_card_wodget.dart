import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class CustomCard extends StatelessWidget {
  final String img, title, subtitle;
  CustomCard({this.img, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            img != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Image.asset(
                      img,
                      height: 100,
                      // fit: BoxFit.contain,
                    ),
                  )
                : SizedBox(
                    height: 100,
                  ),
            Style.titleMedium(title, fontSize: 16, textAlign: TextAlign.center),
            SizedBox(
              height: 5,
            ),
            Style.bodySmall(subtitle,
                textAlign: TextAlign.center, fontSize: 10),
          ],
        ),
      ),
    );
  }
}
