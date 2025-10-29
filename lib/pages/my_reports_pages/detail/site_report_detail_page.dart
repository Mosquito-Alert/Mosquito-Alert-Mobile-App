import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:provider/provider.dart';

class SiteReportDetailPage extends StatefulWidget {
  final BreedingSite report;

  const SiteReportDetailPage({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  State<SiteReportDetailPage> createState() => _SiteReportDetailPageState();
}

class _SiteReportDetailPageState extends State<SiteReportDetailPage> {
  late BreedingSitesApi breedingSitesApi;
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
    breedingSitesApi = apiClient.getBreedingSitesApi();
  }

  Future<void> _loadLocationText() async {
    try {
      final location = await _formatLocationWithCity(widget.report);
      if (mounted) {
        setState(() {
          locationText = location;
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          locationText = _formatLocationCoordinates(widget.report);
          isLoadingLocation = false;
        });
      }
    }
  }

  String _formatTitle() {
    return MyLocalizations.of(context, 'single_breeding_site');
  }

  String _formatLocationCoordinates(BreedingSite report) {
    final point = report.location.point;
    return '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
  }

  Future<String> _formatLocationWithCity(BreedingSite report) async {
    // First try to get the display name from the location object
    final displayName = report.location.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    // Fall back to reverse geocoding using coordinates
    final point = report.location.point;
    try {
      final cityName =
          await Utils.getCityNameFromCoords(point.latitude, point.longitude);
      if (cityName != null && cityName.isNotEmpty) {
        return cityName;
      }
    } catch (e) {
      print('Error getting city name: $e');
    }

    // Final fallback to coordinates
    return _formatLocationCoordinates(report);
  }

  String _formatDate(BreedingSite report) {
    return DateFormat('yyyy-MM-dd').format(report.createdAtLocal);
  }

  String _getHashtag() {
    // TODO: Get hashtag from report data when available
    return '#mosquitoalert';
  }

  String _getHasWater() {
    // TODO: Get hasWater from report data when available
    return MyLocalizations.of(context, 'yes');
  }

  String _getHasLarvae() {
    // TODO: Get hasLarvae from report data when available
    return MyLocalizations.of(context, 'no');
  }

  Future<void> _deleteReport() async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'delete_report',
      parameters: {'report_uuid': widget.report.uuid},
    );

    try {
      await breedingSitesApi.destroy(uuid: widget.report.uuid);
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
    final title = _formatTitle();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Style.colorPrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
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
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Style.colorPrimary,
                      Style.colorPrimary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Dummy photo for now
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoItem(
                      icon: Icons.fingerprint,
                      title: 'UUID',
                      content: widget.report.uuid,
                    ),
                    _buildInfoItem(
                      icon: Icons.location_on,
                      title: MyLocalizations.of(context, 'location_txt'),
                      content: isLoadingLocation
                          ? '...'
                          : (locationText ??
                              _formatLocationCoordinates(widget.report)),
                    ),
                    _buildInfoItem(
                      icon: Icons.calendar_today,
                      title: MyLocalizations.of(
                          context, 'exact_time_register_txt'),
                      content: _formatDate(widget.report),
                    ),
                    _buildInfoItem(
                      icon: Icons.tag,
                      title: 'Hashtag',
                      content: _getHashtag(),
                    ),
                    _buildInfoItem(
                      icon: Icons.water,
                      title: 'Has Water',
                      content: _getHasWater(),
                    ),
                    _buildInfoItem(
                      icon: Icons.bug_report,
                      title: 'Has Larvae',
                      content: _getHasLarvae(),
                    ),
                    const SizedBox(height: 20),
                    _buildMapWidget(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWidget() {
    final point = widget.report.location.point;
    final location = LatLng(point.latitude, point.longitude);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: 15.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('site_location'),
              position: location,
              infoWindow: InfoWindow(
                title: MyLocalizations.of(context, 'location_txt'),
              ),
            ),
          },
          // Disable all interactions to make it a static view
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Style.colorPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Style.colorPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
