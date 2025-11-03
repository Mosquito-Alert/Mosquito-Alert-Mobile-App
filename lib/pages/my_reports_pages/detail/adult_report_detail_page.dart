import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/widgets/report_detail_page.dart';
import 'package:mosquito_alert_app/utils/report_formatter.dart';
import 'package:provider/provider.dart';

class AdultReportDetailPage extends StatefulWidget {
  final Observation observation;

  const AdultReportDetailPage({
    super.key,
    required this.observation,
  });

  @override
  State<AdultReportDetailPage> createState() => _AdultReportDetailPageState();
}

class _AdultReportDetailPageState extends State<AdultReportDetailPage> {
  late ObservationsApi observationsApi;

  @override
  void initState() {
    super.initState();
    _initializeApi();
  }

  void _initializeApi() {
    MosquitoAlert apiClient =
        Provider.of<MosquitoAlert>(context, listen: false);
    observationsApi = apiClient.getObservationsApi();
  }

  Widget _buildPhotoCarousel() {
    return CarouselView(
      scrollDirection: Axis.horizontal,
      itemExtent: double.infinity,
      itemSnapping: true,
      padding: EdgeInsets.zero,
      shape: const BeveledRectangleBorder(),
      children:
          List<Widget>.generate(widget.observation.photos.length, (int index) {
        final photo = widget.observation.photos[index];
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

  Future<void> _deleteReport({required Observation observation}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'delete_report',
      parameters: {'report_uuid': observation.uuid},
    );

    try {
      await observationsApi.destroy(uuid: observation.uuid);
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate deletion
      }
    } catch (e) {
      print('Error deleting observation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final observationWidgets = ObservationWidgets(context, widget.observation);
    final String? locationEnvironment =
        observationWidgets.getLocationEnvironment();

    // Build the map only if locationEnvironment is not null
    final extraListTileMap = <IconData, String>{};
    if (locationEnvironment != null) {
      extraListTileMap[Icons.not_listed_location] = locationEnvironment;
    }

    return ReportDetailPage(
      report: widget.observation,
      title: observationWidgets.buildTitleText(),
      onTapDelete: (observation) => _deleteReport(observation: observation),
      extraListTileMap: extraListTileMap,
      topBarBackgroundBuilder: _buildPhotoCarousel,
    );
  }
}
