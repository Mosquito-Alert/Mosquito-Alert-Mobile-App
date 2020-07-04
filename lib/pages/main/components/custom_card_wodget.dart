import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class CustomCard extends StatelessWidget {
  final String img, title, subtitle;
  bool selected, disabled;
  CustomCard(
      {this.img, this.title, this.subtitle, this.selected, this.disabled});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled == true ? 0.5 : 1,
          child: Card(
        color: selected == true ? Style.colorPrimary : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation:  disabled == true ? 0 : 3,
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              img != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Image.asset(
                        img,
                        height: 100,
                        // fit: BoxFit.contain,
                      ),
                    )
                  : SizedBox(
                      height: 120,
                    ),
              Style.titleMedium(title, fontSize: 18, textAlign: TextAlign.center),
              SizedBox(
                height: 4,
              ),
              SizedBox(
                height: 30,
                child: Style.bodySmall(subtitle,
                    textAlign: TextAlign.center, fontSize: 12, color: Colors.black.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
