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

class _MyReportsPageState extends State<MyReportsPage> with TickerProviderStateMixin {
  late List<Report> adultReports;
  late List<Report> biteReports;
  late List<Report> siteReports;
  bool isLoading = true;

  late final TabController _tabController;
  final List<Color> _indicatorColors = [
    Color(0xFFE1D32E),     // Color for Mosquito tab
    Color(0xFFC76758),     // Color for Bites tab
    Color(0xFF567483),     // Color for Breeding Sites tab
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Update UI when tab changes
    });
    loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void loadReports() async {
    var myReports = await ApiSingleton().getReportsList();

    // Sort the reports by creation_time in descending order
    myReports.sort((a, b) => b.creation_time!
        .compareTo(a.creation_time ?? '1970-01-01T00:00:00.000000Z'));

    setState(() {
      adultReports = myReports.where((report) => report.type == 'adult').toList();
      biteReports = myReports.where((report) => report.type == 'bite').toList();
      siteReports = myReports.where((report) => report.type == 'site').toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _indicatorColors[_tabController.index],
            labelColor: Colors.black,
            tabs: <Widget>[
              Tab(
                icon: Image.asset(
                  'assets/img/ic_mosquito_report_black.webp',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high),
                text: MyLocalizations.of(context, 'single_mosquito')),
              Tab(
                icon: Image.asset(
                  'assets/img/ic_bite_report_black.webp',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high),
                text: MyLocalizations.of(context, 'single_bite')),
              Tab(
                icon: Image.asset(
                  'assets/img/ic_breeding_report_black.webp',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high),
                text: MyLocalizations.of(context, 'single_breeding_site')),
            ],
          ),
          title: Text(MyLocalizations.of(context, 'your_reports_txt')),
        ),
        body: isLoading ?
          Center(child: CircularProgressIndicator())
          :
          TabBarView(
            controller: _tabController,
            children: [
              ReportsList(reports: adultReports),
              ReportsList(reports: biteReports),
              ReportsList(reports: siteReports),
            ],
          ),
      );
  }
}
