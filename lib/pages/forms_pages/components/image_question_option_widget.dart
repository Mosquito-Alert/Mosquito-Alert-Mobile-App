import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class ImageQuestionOption extends StatelessWidget {
  final bool selected, disabled;
  final String title, text;
  final String img;

  ImageQuestionOption(this.selected, this.title, this.text, this.img,
      {this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Card(
        color: selected ? Style.colorPrimary : Colors.white,
        margin: EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                // color: Colors.blue,
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage(img!= null ? img : "assets/img/torax_711.png"),
                  fit: BoxFit.cover,
                  // colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcOver))
                ),
              ),
              // padding: EdgeInsets.all(5),
              // child: Image.asset(
              //   img,
              //   fit: BoxFit.cover,
              // ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Style.title(title, color: Colors.white),
                  Style.bodySmall(
                    text,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
