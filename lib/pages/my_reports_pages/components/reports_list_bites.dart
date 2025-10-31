import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/bite_report_detail_page.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/widgets/grouped_report_list_view.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:provider/provider.dart';

class ReportsListBites extends StatefulWidget {
  const ReportsListBites({super.key});

  @override
  State<ReportsListBites> createState() => _ReportsListBitesState();
}

class _ReportsListBitesState extends State<ReportsListBites> {
  List<Bite> biteReports = [];
  bool isLoading = true;
  late BitesApi bitesApi;

  @override
  void initState() {
    super.initState();
    _initializeApi();
    _loadBiteReports();
  }

  void _initializeApi() {
    MosquitoAlert apiClient =
        Provider.of<MosquitoAlert>(context, listen: false);
    bitesApi = apiClient.getBitesApi();
  }

  Future<void> _loadBiteReports() async {
    try {
      // TODO: Handle pagination like in notifications page with infinite scrolling view
      final response = await bitesApi.listMine();

      final reports = response.data?.results?.toList() ?? [];

      if (mounted) {
        setState(() {
          biteReports = reports;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading bite reports: $e');
      if (mounted) {
        setState(() {
          biteReports = [];
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

    if (biteReports.isEmpty) {
      return Center(
        child: Text(MyLocalizations.of(context, 'no_reports_yet_txt')),
      );
    }

    final formatters = _ReportFormatters(context);

    return GroupedReportListView(
      reports: biteReports,
      titleBuilder: (report) {
        return Text(formatters.formatTitle(report));
      },
      onTap: (report, context) {
        _navigateToReportDetail(report, context);
      },
    );
  }

  void _navigateToReportDetail(Bite report, BuildContext context) async {
    await FirebaseAnalytics.instance.logSelectContent(
      contentType: 'bite_report',
      itemId: report.uuid,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BiteReportDetailPage(report: report),
      ),
    );

    // If the report was deleted, refresh the list
    if (result == true && mounted) {
      setState(() {
        biteReports.removeWhere((b) => b.uuid == report.uuid);
      });
    }
  }
}

class _ReportFormatters {
  final BuildContext context;

  _ReportFormatters(this.context);

  String formatTitle(Bite report) {
    final totalBites = report.counts.total;

    if (totalBites == 0) {
      return MyLocalizations.of(context, 'no_bites');
    } else if (totalBites == 1) {
      return '1 ${MyLocalizations.of(context, 'single_bite').toLowerCase()}';
    } else {
      return '$totalBites ${MyLocalizations.of(context, 'plural_bite').toLowerCase()}';
    }
  }
}
