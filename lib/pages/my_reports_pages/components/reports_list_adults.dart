import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/adult_report_detail_page.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
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

  String _formatCreationTime(Observation report) {
    return ReportUtils.formatDate(report);
  }

  Widget _buildLeadingImage(Observation report) {
    final photos = report.photos;

    if (photos.isEmpty) {
      // Fallback to default mosquito icon
      return Image.asset(
        'assets/img/ic_mosquito_report_black.webp',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }

    // Use the first photo from the report
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: photos.first.url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 40,
          height: 40,
          color: Colors.grey.withValues(alpha: 0.3),
          child: const Icon(
            Icons.photo_camera,
            size: 20,
            color: Colors.grey,
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/img/ic_mosquito_report_black.webp',
          width: 40,
          height: 40,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
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

    return ListView.builder(
      itemCount: adultReports.length,
      itemBuilder: (context, index) {
        final report = adultReports[index];
        final formatters = _ReportFormatters(context);
        final title = formatters.formatTitle(report);
        final shouldItalicize = formatters.shouldItalicizeTitle(report);

        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: _buildLeadingImage(report),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle:
                    shouldItalicize ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            subtitle: Text(_formatCreationTime(report)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateToReportDetail(report, context),
          ),
        );
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
        builder: (context) => AdultReportDetailPage(report: report),
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

class _ReportFormatters {
  final BuildContext context;

  _ReportFormatters(this.context);

  String formatTitle(Observation report) {
    if (report.identification == null) {
      return MyLocalizations.of(context, 'non_identified_specie');
    }

    // Navigate through nested nullable fields
    final identification = report.identification;
    final result = identification?.result;
    final taxon = result?.taxon;
    final nameValue = taxon?.nameValue;

    if (nameValue == null || nameValue.isEmpty) {
      return MyLocalizations.of(context, 'non_identified_specie');
    }

    return nameValue;
  }

  bool shouldItalicizeTitle(Observation report) {
    return report.identification?.result?.taxon?.italicize ?? false;
  }
}
