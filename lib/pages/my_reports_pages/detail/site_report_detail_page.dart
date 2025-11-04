import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/widgets/report_detail_page.dart';
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
  late BreedingSitesApi breedingSitesApi;

  @override
  void initState() {
    super.initState();
    _initializeApi();
  }

  void _initializeApi() {
    MosquitoAlert apiClient =
        Provider.of<MosquitoAlert>(context, listen: false);
    breedingSitesApi = apiClient.getBreedingSitesApi();
  }

  Widget _buildPhotoCarousel() {
    return CarouselView(
      scrollDirection: Axis.horizontal,
      itemExtent: double.infinity,
      itemSnapping: true,
      padding: EdgeInsets.zero,
      shape: const BeveledRectangleBorder(),
      children:
          List<Widget>.generate(widget.breedingSite.photos.length, (int index) {
        final photo = widget.breedingSite.photos[index];
        return CachedNetworkImage(
          imageUrl: photo.url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Container(
            color: Colors.white.withValues(alpha: 0.2),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.white.withValues(alpha: 0.2),
            child: const Center(
              child: Icon(
                Icons.error,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _deleteReport({required BreedingSite breedingSite}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'delete_report',
      parameters: {'report_uuid': breedingSite.uuid},
    );

    try {
      await breedingSitesApi.destroy(uuid: breedingSite.uuid);
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate deletion
      }
    } catch (e) {
      print('Error deleting breeding site: $e');
    }
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
      Icons.bug_report: [
        MyLocalizations.of(context, 'question_17'),
        hasLarvae
            ? MyLocalizations.of(context, 'yes')
            : MyLocalizations.of(context, 'no')
      ].join(' '),
    };

    return ReportDetailPage(
      report: widget.breedingSite,
      title: breedingSiteWidgets.buildTitleText(),
      onTapDelete: (report) => _deleteReport(breedingSite: report),
      extraListTileMap: extraListTileMap,
      topBarBackgroundBuilder: _buildPhotoCarousel,
    );
  }
}
