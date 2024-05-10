import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/components/reports_list_widget.dart';


class MyReportsTabBar extends StatefulWidget {
  const MyReportsTabBar({Key? key}) : super(key: key);

  @override
  _MyReportsTabBarState createState() => _MyReportsTabBarState();
}

class _MyReportsTabBarState extends State<MyReportsTabBar> {
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
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.car_crash), text: 'Adult'),
              Tab(icon: Icon(Icons.biotech), text: 'Bite'),
              Tab(icon: Icon(Icons.location_on), text: 'Sites'),
            ],
          ),
          title: const Text('My Reports'),
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