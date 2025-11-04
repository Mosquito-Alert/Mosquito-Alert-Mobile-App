import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/site_report_detail_page.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/widgets/grouped_report_list_view.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/report_formatter.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:provider/provider.dart';

class ReportsListSites extends StatefulWidget {
  const ReportsListSites({super.key});

  @override
  State<ReportsListSites> createState() => _ReportsListSitesState();
}

class _ReportsListSitesState extends State<ReportsListSites> {
  List<BreedingSite> siteReports = [];
  bool isLoading = true;
  late BreedingSitesApi breedingSitesApi;

  @override
  void initState() {
    super.initState();
    _initializeApi();
    _loadSiteReports();
  }

  void _initializeApi() {
    MosquitoAlert apiClient =
        Provider.of<MosquitoAlert>(context, listen: false);
    breedingSitesApi = apiClient.getBreedingSitesApi();
  }

  Future<void> _loadSiteReports() async {
    try {
      // TODO: Handle pagination like in notifications page with infinite scrolling view
      final response = await breedingSitesApi.listMine();

      final reports = response.data?.results?.toList() ?? [];

      if (mounted) {
        setState(() {
          siteReports = reports;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading site reports: $e');
      if (mounted) {
        setState(() {
          siteReports = [];
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

    if (siteReports.isEmpty) {
      return Center(
        child: Text(MyLocalizations.of(context, 'no_reports_yet_txt')),
      );
    }

    return GroupedReportListView(
      reports: siteReports,
      titleBuilder: (report) {
        return BreedingSiteWidgets(context, report).buildTitleText();
      },
      leadingBuilder: (report) {
        return ReportDetailWidgets.buildLeadingImage(
          report: report,
        );
      },
      onTap: (report, context) => _navigateToReportDetail(report, context),
    );
  }

  void _navigateToReportDetail(
      BreedingSite report, BuildContext context) async {
    await FirebaseAnalytics.instance.logSelectContent(
      contentType: 'breeding_site_report',
      itemId: report.uuid,
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SiteReportDetailPage(breedingSite: report),
      ),
    );

    // If the report was deleted, refresh the list
    if (result == true && mounted) {
      setState(() {
        siteReports.removeWhere((r) => r.uuid == report.uuid);
      });
    }
  }
}
