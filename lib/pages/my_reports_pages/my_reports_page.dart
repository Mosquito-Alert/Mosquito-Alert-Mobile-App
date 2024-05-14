import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/components/reports_list_widget.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';


class MyReportsPage extends StatefulWidget {
  const MyReportsPage({Key? key}) : super(key: key);

  @override
  _MyReportsPageState createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  late List<Report> adultReports;
  late List<Report> biteReports;
  late List<Report> siteReports;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  void loadReports() async {
    var myData = await ApiSingleton().getReportsList();    
    setState(() {
      adultReports = myData.where((report) => report.type == 'adult').toList();
      biteReports = myData.where((report) => report.type == 'bite').toList();
      siteReports = myData.where((report) => report.type == 'site').toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Image.asset('assets/img/ic_my_reports_mosquito.png'),
                text: MyLocalizations.of(context, 'single_mosquito') ?? 'Mosquito'),
              Tab(
                icon: Image.asset('assets/img/ic_my_reports_bite.png'),
                text: MyLocalizations.of(context, 'single_bite') ?? 'Bite'),
              Tab(
                icon: Image.asset('assets/img/ic_my_reports_breeding_site.png'),
                text: MyLocalizations.of(context, 'single_breeding_site') ?? 'Sites'),
            ],
          ),
          title: Text(MyLocalizations.of(context, 'your_reports_txt') ?? 'My reports'),
        ),
        body: isLoading ?
          Center(child: CircularProgressIndicator())
          :
          TabBarView(
            children: [
              ReportsList(reports: adultReports),
              ReportsList(reports: biteReports),
              ReportsList(reports: siteReports),
            ],
          ),
      ),
    );
  }
}