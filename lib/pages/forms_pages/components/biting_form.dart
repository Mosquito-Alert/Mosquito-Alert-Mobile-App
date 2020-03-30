import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BitingForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 35,
              ),
              Style.title(
                  MyLocalizations.of(context, "need_more_information_txt")),
              Style.bodySmall(MyLocalizations.of(context, "lets_go_txt")),
              SizedBox(
                height: 25,
              ),
              Style.titleMedium('¿Cuántas picaduras quieres reportar y dónde?',
                  fontSize: 16),
              Container(
                height: 350,
                color: Colors.grey,
              ),
              SizedBox(
                height: 20,
              ),
              Style.titleMedium('¿Cuándo te ha picado el mosquito?',
                  fontSize: 16),
              SizedBox(
                height: 10,
              ),
              Row(children: <Widget>[
                Expanded(
                  child: Container(
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
                    child: Style.body('Amaneder'),
                  ),
                ),
                Expanded(
                  child: Container(
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
                    child: Style.body('Amaneder'),
                  ),
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
