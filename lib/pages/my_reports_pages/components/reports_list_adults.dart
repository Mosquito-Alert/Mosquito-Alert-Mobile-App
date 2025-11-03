import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/adult_report_detail_page.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/widgets/grouped_report_list_view.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/report_formatter.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:provider/provider.dart';

class ReportsListAdults extends StatefulWidget {
  const ReportsListAdults({super.key});

  @override
  State<ReportsListAdults> createState() => _ReportsListAdultsState();
}

class _ReportsListAdultsState extends State<ReportsListAdults> {
  List<Observation> adultReports = [];
  bool isLoading = true;
  late ObservationsApi observationsApi;

  @override
  void initState() {
    super.initState();
    _initializeApi();
    _loadAdultReports();
  }

  void _initializeApi() {
    MosquitoAlert apiClient =
        Provider.of<MosquitoAlert>(context, listen: false);
    observationsApi = apiClient.getObservationsApi();
  }

  Future<void> _loadAdultReports() async {
    try {
      // TODO: Handle pagination like in notifications page with infinite scrolling view
      final response = await observationsApi.listMine();

      final reports = response.data?.results?.toList() ?? [];

      if (mounted) {
        setState(() {
          adultReports = reports;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading adult reports: $e');
      if (mounted) {
        setState(() {
          adultReports = [];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Style.colorPrimary),
        ),
      );
    }

    if (adultReports.isEmpty) {
      return Center(
        child: Text(MyLocalizations.of(context, 'no_reports_yet_txt')),
      );
    }

    return GroupedReportListView(
      reports: adultReports,
      titleBuilder: (report) {
        return ObservationWidgets(context, report).buildTitleText();
      },
      leadingBuilder: (report) => ReportDetailWidgets.buildLeadingImage(
        report: report,
      ),
      onTap: (report, context) {
        // Handle tap on each report
        _navigateToReportDetail(report, context);
      },
    );
  }

  void _navigateToReportDetail(Observation report, BuildContext context) async {
    await FirebaseAnalytics.instance.logSelectContent(
      contentType: 'adult_report',
      itemId: report.uuid,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdultReportDetailPage(observation: report),
      ),
    );

    // If the report was deleted, refresh the list
    if (result == true && mounted) {
      setState(() {
        adultReports.removeWhere((r) => r.uuid == report.uuid);
      });
    }
  }
}
