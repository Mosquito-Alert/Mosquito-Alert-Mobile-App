import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/customModalBottomSheet.dart';
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
    }
  }

  String _formatCreationTime(Observation report) {
    return DateFormat('yyyy-MM-dd HH:mm').format(report.createdAt.toLocal());
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
            leading: Image.asset(
              'assets/img/ic_mosquito_report_black.webp',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            title: shouldItalicize
                ? Text(
                    title,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
            subtitle: Text(_formatCreationTime(report)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _reportBottomSheet(report, context),
          ),
        );
      },
    );
  }

  void _reportBottomSheet(Observation report, BuildContext context) async {
    await FirebaseAnalytics.instance.logSelectContent(
      contentType: 'adult_report',
      itemId: report.uuid,
    );

    await CustomShowModalBottomSheet.customShowModalBottomSheet(
      context: context,
      dismissible: true,
      builder: (BuildContext bc) => _AdultReportDetailSheet(
        report: report,
        onDelete: () => _deleteReport(report),
        formatters: _ReportFormatters(context),
      ),
    );
  }

  Future<void> _deleteReport(Observation report) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'delete_report',
      parameters: {'report_uuid': report.uuid},
    );
    Navigator.pop(context);

    try {
      await observationsApi.destroy(uuid: report.uuid);
      if (mounted) {
        setState(() {
          adultReports.removeWhere((r) => r.uuid == report.uuid);
        });
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
    final commonName = taxon?.commonName;

    if (commonName == null || commonName.isEmpty) {
      return MyLocalizations.of(context, 'non_identified_specie');
    }

    return commonName;
  }

  bool shouldItalicizeTitle(Observation report) {
    return report.identification?.result?.taxon?.italicize ?? false;
  }

  String formatDetailedDateTime(Observation report) {
    final localTime = report.createdAt.toLocal();
    final dateString =
        DateFormat('EEEE, dd MMMM yyyy', Utils.language.languageCode)
            .format(localTime);
    final timeString = DateFormat.Hms().format(localTime);
    return '$dateString\n${MyLocalizations.of(context, 'at_time_txt')}: $timeString ${MyLocalizations.of(context, 'hours')}';
  }

  String formatLocationCoordinates(Observation report) {
    final point = report.location.point;
    return '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
  }

  Future<String> formatLocationWithCity(Observation report) async {
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
    return formatLocationCoordinates(report);
  }
}

class _AdultReportDetailSheet extends StatelessWidget {
  final Observation report;
  final VoidCallback onDelete;
  final _ReportFormatters formatters;

  const _AdultReportDetailSheet({
    required this.report,
    required this.onDelete,
    required this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        minHeight: MediaQuery.of(context).size.height * 0.55,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _ReportHeaderWidget(
                report: report,
                formatters: formatters,
                onDelete: onDelete,
              ),
              const SizedBox(height: 20),
              _ReportMapWidget(report: report),
              const SizedBox(height: 20),
              _ReportLocationWidget(
                report: report,
                formatters: formatters,
              ),
              const SizedBox(height: 20),
              _ReportIdAndIdentificationWidget(
                report: report,
                formatters: formatters,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportMapWidget extends StatefulWidget {
  final Observation report;

  const _ReportMapWidget({required this.report});

  @override
  State<_ReportMapWidget> createState() => _ReportMapWidgetState();
}

class _ReportMapWidgetState extends State<_ReportMapWidget> {
  @override
  Widget build(BuildContext context) {
    final point = widget.report.location.point;
    final location = LatLng(point.latitude, point.longitude);

    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: 14.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('report_location'),
              position: location,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          },
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}

class _ReportHeaderWidget extends StatelessWidget {
  final Observation report;
  final _ReportFormatters formatters;
  final VoidCallback onDelete;

  const _ReportHeaderWidget({
    required this.report,
    required this.formatters,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = formatters.formatTitle(report);
    final shouldItalicize = formatters.shouldItalicizeTitle(report);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: shouldItalicize
              ? Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        PopupMenuButton<int>(
          onSelected: (value) {
            if (value == 1) {
              onDelete();
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
    );
  }
}

class _ReportLocationWidget extends StatefulWidget {
  final Observation report;
  final _ReportFormatters formatters;

  const _ReportLocationWidget({
    required this.report,
    required this.formatters,
  });

  @override
  State<_ReportLocationWidget> createState() => _ReportLocationWidgetState();
}

class _ReportLocationWidgetState extends State<_ReportLocationWidget> {
  String? locationText;
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadLocationText();
  }

  Future<void> _loadLocationText() async {
    try {
      final location =
          await widget.formatters.formatLocationWithCity(widget.report);
      if (mounted) {
        setState(() {
          locationText = location;
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          locationText =
              widget.formatters.formatLocationCoordinates(widget.report);
          isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MyLocalizations.of(context, 'exact_time_register_txt'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(widget.formatters.formatDetailedDateTime(widget.report)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MyLocalizations.of(context, 'location_txt'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              isLoadingLocation
                  ? Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Style.colorPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(MyLocalizations.of(context, 'location_txt')),
                      ],
                    )
                  : Text(locationText ??
                      widget.formatters
                          .formatLocationCoordinates(widget.report)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportIdAndIdentificationWidget extends StatelessWidget {
  final Observation report;
  final _ReportFormatters formatters;

  const _ReportIdAndIdentificationWidget({
    required this.report,
    required this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Report ID
        Row(
          children: [
            Text(
              'ID: ',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              report.uuid,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Identification details
        Text(
          '(HC) Species:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        _buildIdentificationText(context),
      ],
    );
  }

  Widget _buildIdentificationText(BuildContext context) {
    final title = formatters.formatTitle(report);
    final shouldItalicize = formatters.shouldItalicizeTitle(report);

    return shouldItalicize
        ? Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          )
        : Text(
            title,
            style: const TextStyle(fontSize: 14),
          );
  }
}
