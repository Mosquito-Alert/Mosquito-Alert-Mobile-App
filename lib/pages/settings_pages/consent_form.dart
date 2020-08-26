import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:url_launcher/url_launcher.dart';

class ConsentForm extends StatefulWidget {
  @override
  _ConsentFormState createState() => _ConsentFormState();
}

class _ConsentFormState extends State<ConsentForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset(
          'assets/img/ic_logo.png',
          height: 40,
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Style.body(
                  "Participa en el estudio, seguimiento y control de mosquitos vectores de enfermedades con la App Mosquito Alert. \n\nEnvía datos de posibles lugares de cría en la vía pública, picaduras y hallazgos de estas 5 especies de mosquito: mosquito tigre (Aedes albopictus), mosquito de la fiebre amarilla (Aedes aegypti), mosquito del Japón (Aedes japonicus), mosquito de Corea (Aedes koreicus) y mosquito común (Culex pipiens). \n"),
              Style.body("FORMULARIO DE CONSENTIMIENTO \n"),
              Container(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    Style.body("He leído y acepto las "),
                    InkWell(
                      onTap: () async {
                        final url = MyLocalizations.of(context, 'url_politics');
                        if (await canLaunch(url))
                          await launch(url);
                        else
                          throw 'Could not launch $url';
                      },
                      child: Text(
                          MyLocalizations.of(
                              context, 'terms_and_conditions_txt2'),
                          style: TextStyle(
                              color: Style.textColor,
                              fontSize: 14,
                              decoration: TextDecoration.underline)),
                    ),
                    Style.body(" y la "),
                    InkWell(
                      onTap: () async {
                        final url = MyLocalizations.of(context, 'url_politics');
                        if (await canLaunch(url))
                          await launch(url);
                        else
                          throw 'Could not launch $url';
                      },
                      child: Text(
                          MyLocalizations.of(
                              context, 'terms_and_conditions_txt2'),
                          style: TextStyle(
                              color: Style.textColor,
                              fontSize: 14,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
              Style.body(
                  "\n\nEntiendo que para participar en el proyecto Mosquito Alert a través de la aplicación Mosquito Alert, tengo que ser mayor de edad o estar supervisado por un adulto. \n\nEntiendo que Mosquito Alert recoge y comparte con terceros o el público general la siguiente información: \n"),
              Style.body("· Blabla"),
              Style.body("· Blabla"),
              Style.body(
                  'Entiendo que Mosquito Alert recoge y comparte con terceros o el público general la información que se detalla en la política de privacidad de datos y que se usará y compartirá con terceros en los términos que en ella y en las condiciones de uso se detallan.'),
              Style.body(
                  'Entiendo que los datos e imágenes recogidos y compartidos a través de Mosquito Alert no son de carácter personal, ya que no se recoge información referente a personas físicas identificadas o identificables, según lo establecido en la Ley Orgánica 3/2018, de 5 de diciembre, de Protección de Datos Personales y garantía de los derechos digitales y en el Reglamento (UE) 2016/679 del Parlamento Europeo y del Consejo, de 27 de abril de 2016 (Reglamento general de protección de datos). Entiendo que está bajo mi responsabilidad la correcta utilización de Mosquito Alert y que no tengo que recoger, ni enviar, a través de Mosquito Alert, imágenes o datos personales, ni hacer un uso indebido, o fuera de la legalidad, o diferente al que Mosquito Alert está destinado.')
            ],
          ),
        ),
      ),
    );
  }
}
