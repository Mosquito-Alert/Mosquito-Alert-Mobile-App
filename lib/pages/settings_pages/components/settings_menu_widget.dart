import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class SettingsMenuWidget extends StatelessWidget {
  final String? text;
  final Function onTap;
  final bool addDivider;

  SettingsMenuWidget(this.text, this.onTap, {this.addDivider = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            onTap();
          },
          title: Style.body(text),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
            size: 18,
          ),
          visualDensity: VisualDensity(vertical: -4),
          dense: true,          
        ),
        if (addDivider)
          Divider(
            thickness: 0.5,
            indent: 5.0,
            endIndent: 5.0,
          )
      ],
    );
  }
}
