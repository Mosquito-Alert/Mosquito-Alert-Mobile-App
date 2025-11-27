import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/widgets/report_detail_page.dart';
import 'package:mosquito_alert_app/providers/report_provider.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/report_formatter.dart';
import 'package:provider/provider.dart';

class SiteReportDetailPage extends StatefulWidget {
  final BreedingSite breedingSite;

  const SiteReportDetailPage({
    super.key,
    required this.breedingSite,
  });

  @override
  State<SiteReportDetailPage> createState() => _SiteReportDetailPageState();
}

class _SiteReportDetailPageState extends State<SiteReportDetailPage> {
  @override
  void initState() {
    super.initState();
    _logViewScreen();
  }

  Future<void> _logViewScreen() async {
    await FirebaseAnalytics.instance.logSelectContent(
      contentType: 'breeding_site_report',
      itemId: widget.breedingSite.uuid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final breedingSiteWidgets =
        BreedingSiteWidgets(context, widget.breedingSite);

    final bool hasWater = widget.breedingSite.hasWater ?? false;
    final bool hasLarvae = widget.breedingSite.hasLarvae ?? false;

    // Build the map only if locationEnvironment is not null
    final extraListTileMap = <IconData, String>{
      Icons.water_drop: [
        MyLocalizations.of(context, 'question_10'),
        hasWater
            ? MyLocalizations.of(context, 'yes')
            : MyLocalizations.of(context, 'no')
      ].join(' '),
      Icons.grain: [
        MyLocalizations.of(context, 'question_17'),
        hasLarvae
            ? MyLocalizations.of(context, 'yes')
            : MyLocalizations.of(context, 'no')
      ].join(' '),
    };

    return ReportDetailPage(
      report: widget.breedingSite,
      provider: context.watch<BreedingSiteProvider>(),
      title: breedingSiteWidgets.buildTitleText(),
      extraListTileMap: extraListTileMap,
      topBarBackgroundBuilder: (breedingSite) =>
          ReportDetailWidgets.buildPhotoCarousel(report: breedingSite),
    );
  }
}
