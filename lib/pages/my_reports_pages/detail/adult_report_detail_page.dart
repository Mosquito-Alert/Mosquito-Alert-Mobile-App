import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:provider/provider.dart';

class AdultReportDetailPage extends StatefulWidget {
  final Observation report;

  const AdultReportDetailPage({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  State<AdultReportDetailPage> createState() => _AdultReportDetailPageState();
}

class _AdultReportDetailPageState extends State<AdultReportDetailPage> {
  late ObservationsApi observationsApi;
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
    observationsApi = apiClient.getObservationsApi();
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

  String _formatTitle(Observation report) {
    if (report.identification == null) {
      return MyLocalizations.of(context, 'non_identified_specie');
    }

    final identification = report.identification;
    final result = identification?.result;
    final taxon = result?.taxon;
    final nameValue = taxon?.nameValue;

    if (nameValue == null || nameValue.isEmpty) {
      return MyLocalizations.of(context, 'non_identified_specie');
    }

    return nameValue;
  }

  bool _shouldItalicizeTitle(Observation report) {
    return report.identification?.result?.taxon?.italicize ?? false;
  }

  String _getLocationEnvironment() {
    return widget.report.eventEnvironment!.name;
  }

  String _getNotes() {
    return widget.report.note ?? '';
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
            Icons.photo_camera,
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
      await observationsApi.destroy(uuid: widget.report.uuid);
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
    final shouldItalicize = _shouldItalicizeTitle(widget.report);

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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      shouldItalicize ? FontStyle.italic : FontStyle.normal,
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
                              ReportUtils.formatLocationCoordinates(
                                  widget.report)),
                      isLoadingLocation: isLoadingLocation,
                      markerId: 'adult_report_location',
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
                      icon: Icons.location_city,
                      content: _getLocationEnvironment(),
                    ),
                    if (_getNotes().isNotEmpty)
                      ReportDetailWidgets.buildInfoItem(
                        icon: Icons.note,
                        content: _getNotes(),
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
