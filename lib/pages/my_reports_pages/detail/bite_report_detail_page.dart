import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:provider/provider.dart';

class BiteReportDetailPage extends StatefulWidget {
  final Bite report;

  const BiteReportDetailPage({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  State<BiteReportDetailPage> createState() => _BiteReportDetailPageState();
}

class _BiteReportDetailPageState extends State<BiteReportDetailPage> {
  late BitesApi bitesApi;
  String? locationText;
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initializeApi();
    _loadLocationText();
  }

  void _initializeApi() {
    MosquitoAlert apiClient =
        Provider.of<MosquitoAlert>(context, listen: false);
    bitesApi = apiClient.getBitesApi();
  }

  Future<void> _loadLocationText() async {
    try {
      final location = await ReportUtils.formatLocationWithCity(widget.report);
      if (mounted) {
        setState(() {
          locationText = location;
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          locationText = ReportUtils.formatLocationCoordinates(widget.report);
          isLoadingLocation = false;
        });
      }
    }
  }

  String _formatTitle(Bite report) {
    final totalBites = report.counts.total;

    if (totalBites == 0) {
      return MyLocalizations.of(context, 'no_bites');
    } else if (totalBites == 1) {
      return '1 ${MyLocalizations.of(context, 'single_bite').toLowerCase()}';
    } else {
      return '$totalBites ${MyLocalizations.of(context, 'plural_bite').toLowerCase()}';
    }
  }

  String _getLocationEnvironment() {
    return widget.report.eventEnvironment!.name;
  }

  Future<void> _deleteReport() async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'delete_report',
      parameters: {'report_uuid': widget.report.uuid},
    );

    try {
      await bitesApi.destroy(uuid: widget.report.uuid);
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    } catch (e) {
      await _showDeleteError();
    }
  }

  Future<void> _showDeleteError() async {
    await Utils.showAlert(
      MyLocalizations.of(context, 'app_name'),
      MyLocalizations.of(context, 'save_report_ko_txt'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _formatTitle(widget.report);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Style.colorPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 1) {
                Utils.showAlertYesNo(
                  MyLocalizations.of(context, 'delete_report_title'),
                  MyLocalizations.of(context, 'delete_report_txt'),
                  _deleteReport,
                  context,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      MyLocalizations.of(context, 'delete_report_title'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ReportDetailWidgets.buildInfoItem(
              icon: Icons.fingerprint,
              content: widget.report.shortId,
            ),
            ReportDetailWidgets.buildLocationWidget(
              context: context,
              latitude: widget.report.location.point.latitude,
              longitude: widget.report.location.point.longitude,
              locationText: isLoadingLocation
                  ? '...'
                  : (locationText ??
                      ReportUtils.formatLocationCoordinates(widget.report)),
              isLoadingLocation: isLoadingLocation,
              markerId: 'bite_report_location',
            ),
            ReportDetailWidgets.buildInfoItem(
              icon: Icons.calendar_today,
              content: ReportUtils.formatDate(widget.report),
            ),
            if (ReportUtils.getHashtag(widget.report) != null)
              ReportDetailWidgets.buildInfoItem(
                icon: Icons.tag,
                content: ReportUtils.getHashtag(widget.report)!,
              ),
            ReportDetailWidgets.buildInfoItem(
              icon: Icons.home,
              content: _getLocationEnvironment(),
            ),
          ],
        ),
      ),
    );
  }
}
