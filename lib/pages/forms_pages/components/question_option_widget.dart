import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class QuestionOption extends StatefulWidget {
  final bool selected;
  QuestionOption(this.selected);

  @override
  _QuestionOptionState createState() => _QuestionOptionState();
}

class _QuestionOptionState extends State<QuestionOption> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.selected ? Style.colorPrimary : Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          Icons.wb_sunny,
          color: Colors.amber,
        ),
        title: Style.body(
          'Por la mañana',
          color: widget.selected ? Colors.white : Style.textColor,
        ),
      ),
    );
  }
}
