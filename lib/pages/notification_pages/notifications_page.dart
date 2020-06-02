import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/customModalBottomSheet.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // ApiSingleton().getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Style.title(MyLocalizations.of(context, "notifications_title"),
            fontSize: 16),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(15),
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 9,
                itemBuilder: (ctx, index) {
                  return Opacity(
                    opacity: index == 0 ? 1 : 0.5,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        onTap: () {
                          _infoBottomSheet(context);
                        },
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Style.titleMedium(
                                "¡Nueva especie detectada en Barceloa!",
                                fontSize: 14),
                            Style.body(
                                "Lorem ipsum dolor sit amet, consectetur adipis..."),
                            Style.bodySmall("Leer más", color: Colors.grey),
                          ],
                        ),
                        trailing: Image.asset(
                          'assets/img/placeholder.jpg',
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  void _infoBottomSheet(BuildContext context) {
    CustomShowModalBottomSheet.customShowModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  )),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/img/placeholder.jpg',
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Style.title("¡Nueva especie detectada en Barcelona!"),
                    SizedBox(
                      height: 10,
                    ),
                    Style.body(
                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries"),
                    SizedBox(
                      height: 10,
                    ),
                    Style.bodySmall('fecha y quien lo ha enviado',
                        color: Colors.grey)
                  ],
                ),
              ),
            ),
          );
        });
  }
}
