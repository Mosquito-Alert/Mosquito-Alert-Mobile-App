import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/report.dart';


class TabBarDemo extends StatefulWidget {
  const TabBarDemo({Key? key}) : super(key: key);

  @override
  _TabBarDemoState createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<TabBarDemo> {
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

class ReportsList extends StatelessWidget {
  final List<Report> reports;

  const ReportsList({Key? key, required this.reports}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: reports.isEmpty
        ? Center(
            child: Text('No reports found.'),
          )
        : 
        ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4.0,
              child: ListTile(
                title: Text(reports[index].type ?? ''),
                subtitle: Text('Type: ${reports[index].type} \nAt: '),
                isThreeLine: true,
                onTap: () {
                  print('Tile pressed!');
                },
              ),
            );
          },
        )
    );
  }
}
