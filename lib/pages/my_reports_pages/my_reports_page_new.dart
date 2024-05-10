import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/report.dart';

class TabBarDemo extends StatelessWidget {
  const TabBarDemo({Key? key}) : super(key: key);

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
        body: TabBarView(
          children: [
            ReportList(type: 'adult'),
            ReportList(type: 'bite'),
            ReportList(type: 'site'),
          ],
        ),
      ),
    );
  }
}

class ReportList extends StatefulWidget {
  final String type;

  const ReportList({Key? key, required this.type}) : super(key: key);

  @override
  _ReportListState createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  List<Report> reports = [];

  @override
  void initState() {
    super.initState();
    getReports(widget.type);
  }

  void getReports(String type) async {
    var myData = await ApiSingleton().getReportsList();
    var filtered = myData.where((report) => report.type == type).toList();
    setState(() {
      reports = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: reports.isNotEmpty
        ? ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(reports[index].type ?? ''),
                subtitle: Text('Type: ${reports[index].type}'),
                // Add other properties of Report you want to display
              );
            },
          )
        : Center(
            child: Text('No reports found.'),
          ),
    );
  }
}
