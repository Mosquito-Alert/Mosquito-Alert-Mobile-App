import 'dart:typed_data';
import 'package:built_collection/built_collection.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/adapters/observation_report.dart';
import 'package:mosquito_alert_app/core/models/photo.dart';
import 'package:mosquito_alert_app/core/widgets/step_page.dart';
import 'package:mosquito_alert_app/features/observations/presentation/state/observation_provider.dart';
import 'package:mosquito_alert_app/features/reports/presentation/pages/report_create_page.dart';
import 'package:mosquito_alert_app/features/reports/presentation/widgets/report_creation_environment_step.dart';
import 'package:mosquito_alert_app/features/reports/presentation/widgets/report_creation_notes_step.dart';
import 'package:mosquito_alert_app/features/reports/presentation/widgets/report_creation_photo_selection.dart';
import 'package:mosquito_alert_app/features/reports/presentation/widgets/location_selector.dart';
import 'package:mosquito_alert_app/features/settings/presentation/state/settings_provider.dart';
import 'package:mosquito_alert_app/screens/settings_pages/campaign_tutorial_page.dart';
import 'package:mosquito_alert_app/core/localizations/MyLocalizations.dart';
import 'package:mosquito_alert_app/core/utils/style.dart';
import 'package:provider/provider.dart';

class ObservationCreatePage extends StatefulWidget {
  @override
  _ObservationCreatePageState createState() => _ObservationCreatePageState();
}

class _ObservationCreatePageState extends State<ObservationCreatePage> {
  late CampaignsApi _campaignsApi;
  String title = '';

  final createdAt = DateTime.now().toUtc();

  static const Map<String, Object> analyticsParameters = {
    'report_type': 'adult',
  };

  LocationRequest? location;
  ObservationEventEnvironmentEnum? eventEnvironment;
  ObservationEventMomentEnum? eventMoment;
  String? notes;
  List<Uint8List> photos = [];

  bool _isLocationLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize API
    final apiClient = Provider.of<MosquitoAlert>(context, listen: false);
    _campaignsApi = apiClient.getCampaignsApi();
  }

  Future<ObservationReport> _handleSubmit(BuildContext context) async {
    final provider = context.read<ObservationProvider>();
    final userTags = context.read<SettingsProvider>().hashtags;

    List<MemoryPhoto> memoryPhotos = [];
    for (final photo in photos) {
      memoryPhotos.add(MemoryPhoto(photo));
    }

    final observation = await provider.createObservation(
      request: ObservationReportRequest(
        createdAt: createdAt,
        location: location!,
        photos: memoryPhotos,
        eventEnvironment: eventEnvironment,
        eventMoment: eventMoment,
        note: notes,
        tags: userTags,
      ),
    );
    return observation;
  }

  Future<void> _logAnalyticsEvent(String eventName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: analyticsParameters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReportCreatePage<ObservationReport>(
      title: title,
      analyticsParameters: analyticsParameters,
      stepPages: [
        // Step 1: Photo selection
        StepPage(
          canContinue: ValueNotifier<bool>(photos.length >= 1),
          onDisplay: () {
            _logAnalyticsEvent('report_add_photos');
            setState(() {
              title = MyLocalizations.of(context, 'photos');
            });
          },
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          allowScroll: false,
          child: ReportCreationPhotoSelection(
            photos: photos,
            onPhotosChanged: (newPhotos) {
              setState(() {
                photos = newPhotos;
              });
            },
            maxPhotos: 3,
            infoBadgeTextKey: 'one_mosquito_reminder_badge',
            thumbnailText:
                MyLocalizations.of(context, 'ensure_single_mosquito_photos'),
          ),
        ),
        // Step 2: Location selection
        StepPage(
          canContinue:
              ValueNotifier<bool>(!_isLocationLoading && location != null),
          onDisplay: () {
            _logAnalyticsEvent('report_add_location');
            setState(() {
              title = MyLocalizations.of(context, 'select-location');
            });
          },
          fullScreen: true,
          child: LocationSelector(
            initialLatitude: location?.point.latitude,
            initialLongitude: location?.point.longitude,
            onLocationChanged: (latitude, longitude, source) {
              setState(() {
                if (latitude == null || longitude == null || source == null) {
                  location = null;
                  return;
                }
                location = LocationRequest((b) => b
                  ..point.latitude = latitude
                  ..point.longitude = longitude
                  ..source_ = source);
              });
            },
            onLoadingChanged: (isLoading) {
              setState(() {
                _isLocationLoading = isLoading;
              });
            },
          ),
        ),
        // Step 3: Environment questions
        StepPage(
          canContinue: ValueNotifier<bool>(eventEnvironment != null),
          onDisplay: () {
            _logAnalyticsEvent('report_add_environment');
            setState(() {
              title = MyLocalizations.of(context, 'select_environment');
            });
          },
          child: ReportCreationEnvironmentStep(
            initialEnvironmentName:
                eventEnvironment != null ? eventEnvironment!.name : null,
            title: MyLocalizations.of(context, "question_13"),
            allowNullOption: false,
            onChanged: (value) {
              setState(() {
                eventEnvironment = value != null
                    ? ObservationEventEnvironmentEnum.valueOf(value)
                    : null;
              });
            },
          ),
        ),

        // Step 4: Notes and submit
        StepPage(
          canContinue: ValueNotifier<bool>(true),
          onDisplay: () {
            _logAnalyticsEvent('report_add_note');
            setState(() {
              title = MyLocalizations.of(context, 'notes');
            });
          },
          child: ReportCreationNotesStep(
            initialNotes: notes,
            onChange: (String? newNotes) {
              setState(() {
                notes = (newNotes?.trim().isEmpty ?? true)
                    ? null
                    : newNotes!.trim();
              });
            },
          ),
        )
      ],
      onSubmit: (context) => _handleSubmit(context),
      onSubmitSuccess: (context, report) async {
        Navigator.pop(context); // close the success dialog
        Country? country = report!.location.country;
        if (country == null) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return;
        }

        try {
          final campaignsResponse = await _campaignsApi.list(
            countryId: country.id,
            isActive: true,
            pageSize: 1,
            orderBy: ['-start_date'].build(),
          );
          final Campaign? campaign =
              campaignsResponse.data?.results?.firstOrNull;
          if (campaign != null) {
            _showAlertCampaign(
              campaign,
              (context) =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            );
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } catch (e) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
    );
  }

  Future _showAlertCampaign(
      Campaign activeCampaign, void Function(BuildContext) onDismiss) {
    final appName = MyLocalizations.of(context, 'app_name');
    final campaignBody =
        MyLocalizations.of(context, 'alert_campaign_found_create_body');
    final showInfoText = MyLocalizations.of(context, 'show_info');
    final noShowInfoText = MyLocalizations.of(context, 'no_show_info');
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appName),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Style.body(
                  campaignBody,
                  textAlign: TextAlign.left,
                  fontSize: 15.0,
                  height: 1.2,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDismiss(context);
              },
              child: Text(noShowInfoText),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CampaignTutorialPage()),
                );
              },
              child: Text(showInfoText),
            ),
          ],
        );
      },
    );
  }
}
