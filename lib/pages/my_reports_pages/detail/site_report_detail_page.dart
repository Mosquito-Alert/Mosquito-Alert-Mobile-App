import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';
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
  PageController _pageController = PageController();
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApi();
    _loadLocationText();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    return DateFormat('yyyy-MM-dd HH:mm').format(report.createdAtLocal);
  }

  String? _getHashtag() {
    final tags = widget.report.tags;
    if (tags == null || tags.isEmpty) {
      return null;
    }
    // Join multiple tags with spaces, adding # prefix to each
    return tags.map((tag) => '#$tag').join(' ');
  }

  String _getHasWater() {
    bool hasWater = widget.report.hasWater ?? false;
    if (hasWater) {
      return MyLocalizations.of(context, 'yes');
    } else {
      return MyLocalizations.of(context, 'no');
    }
  }

  String _getHasLarvae() {
    bool hasLarvae = widget.report.hasLarvae ?? false;
    if (hasLarvae) {
      return MyLocalizations.of(context, 'yes');
    } else {
      return MyLocalizations.of(context, 'no');
    }
  }

  String _getHasNearMosquitoes() {
    bool hasNearMosquitoes = widget.report.hasNearMosquitoes ?? false;
    if (hasNearMosquitoes) {
      return MyLocalizations.of(context, 'yes');
    } else {
      return MyLocalizations.of(context, 'no');
    }
  }

  Widget _buildPhotoCarousel() {
    final photos = widget.report.photos;

    if (photos.isEmpty) {
      // Fallback to dummy icon if no photos
      return Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.water_drop,
            size: 60,
            color: Colors.white,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: photos.length,
          onPageChanged: (index) {
            setState(() {
              _currentPhotoIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final photo = photos[index];
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
          },
        ),
        // Photo indicator if multiple photos
        if (photos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPhotoIndex
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
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
                      Style.colorPrimary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Photo carousel
                    _buildPhotoCarousel(),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
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
                              _formatLocationCoordinates(widget.report)),
                      isLoadingLocation: isLoadingLocation,
                      markerId: 'site_report_location',
                    ),
                    ReportDetailWidgets.buildInfoItem(
                      icon: Icons.calendar_today,
                      content: _formatDate(widget.report),
                    ),
                    if (_getHashtag() != null)
                      ReportDetailWidgets.buildInfoItem(
                        icon: Icons.tag,
                        content: _getHashtag()!,
                      ),
                    ReportDetailWidgets.buildInfoItem(
                      icon: Icons.water,
                      content: _getHasWater(),
                    ),
                    ReportDetailWidgets.buildInfoItem(
                      icon: Icons.bug_report, // TODO: Get larvae icon
                      content: _getHasLarvae(),
                    ),
                    ReportDetailWidgets.buildInfoItem(
                      icon:
                          Icons.bug_report_outlined, // TODO: get mosquito icon
                      content: _getHasNearMosquitoes(),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
