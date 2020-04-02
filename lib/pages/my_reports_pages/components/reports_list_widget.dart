import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:intl/intl.dart';

class ReportsList extends StatelessWidget {
  final Function onTap;
  final List<Report> reports;

  ReportsList(this.reports, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // shrinkWrap:
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            onTap(context, reports[index]);
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  SvgPicture.asset(
                    reports[index].type == 'adult'
                        ? 'assets/img/ic_adults_yours.svg'
                        : reports[index].type == 'breeding'
                            ? 'assets/img/ic_breeding_yours.svg'
                            : 'assets/img/ic_bites_yours.svg',
                    width: 40,
                  ),
                  Container(height: 60, child: VerticalDivider()),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Style.titleMedium(
                            MyLocalizations.of(
                                    context, "report_of_the_day_txt") +
                                DateFormat('dd-MM-yyyy')
                                    .format(DateTime.parse(
                                        reports[index].creation_time))
                                    .toString(),
                            fontSize: 14),
                        Style.body(MyLocalizations.of(context, "location_txt") +
                            "**Mi casa"),
                        Style.body(
                            MyLocalizations.of(context, "at_time_txt") +
                                DateFormat.Hm()
                                    .format(DateTime.parse(
                                        reports[index].creation_time))
                                    .toString(),
                            color: Colors.grey),
                      ],
                    ),
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/img/placeholder.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}