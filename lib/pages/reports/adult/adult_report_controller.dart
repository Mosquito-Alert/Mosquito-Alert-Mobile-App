import 'package:built_collection/built_collection.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/reports/adult/widgets/dialogs.dart';
import 'package:mosquito_alert_app/pages/reports/shared/pages/environment_question_page.dart';
import 'package:mosquito_alert_app/pages/reports/shared/pages/location_selection_page.dart';
import 'package:mosquito_alert_app/pages/reports/shared/pages/notes_and_submit_page.dart';
import 'package:mosquito_alert_app/pages/reports/shared/pages/photo_selection_page.dart';
import 'package:mosquito_alert_app/pages/reports/shared/utils/report_dialogs.dart';
import 'package:mosquito_alert_app/pages/reports/shared/widgets/progress_indicator.dart';
import 'package:mosquito_alert_app/services/report_sync_service.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:provider/provider.dart';

import 'models/adult_report_data.dart';

/// Main controller for the adult report workflow
/// Uses PageView slider architecture for step-by-step progression
class AdultReportController extends StatefulWidget {
  @override
  _AdultReportControllerState createState() => _AdultReportControllerState();
}

class _AdultReportControllerState extends State<AdultReportController> {
  late PageController _pageController;
  late AdultReportData _reportData;
  late CampaignsApi _campaignsApi;
  late ReportSyncService _reportSyncService;

  int _currentStep = 0;
  bool _isSubmitting = false;

  // Define the events to log
  final List<String> _pageEvents = [
    'report_add_photo',
    'report_add_location',
    'report_add_environment',
    'report_add_note',
  ];

  List<String> get _stepTitlesTextKeys =>
      ['photos', 'select-location', 'select_environment', 'notes'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _reportData = AdultReportData();

    // Initialize API
    final apiClient = Provider.of<MosquitoAlert>(context, listen: false);
    _campaignsApi = apiClient.getCampaignsApi();
    _reportSyncService =
      Provider.of<ReportSyncService>(context, listen: false);

    _logAnalyticsEvent('start_report');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigate to next step
  Future<void> _nextStep() async {
    if (_currentStep < _stepTitlesTextKeys.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) async {
    // Check if the index is valid and log the event
    if (index >= 0 && index < _pageEvents.length) {
      await _logAnalyticsEvent(_pageEvents[index]);
    }
  }

  /// Handle photo selection callback
  void _onPhotosChanged() {
    setState(() {
      // Trigger rebuild to update any photo-dependent UI
    });
  }

  /// Handle notes changes callback
  void _onNotesChanged(String? notes) {
    setState(() {
      _reportData.notes = notes;
    });
  }

  /// Submit the adult report via API or queue it if offline
  Future<void> _submitReport() async {
    if (!_reportData.isValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _logAnalyticsEvent('submit_report');

      final result =
          await _reportSyncService.submitAdultReport(_reportData.copy());

      if (!mounted) return;

      if (result.status == ReportSubmissionStatus.sent) {
        await _handleSuccessfulSubmission(result.data);
      } else {
        await _handleQueuedSubmission();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleSuccessfulSubmission(Observation? observation) async {
    await ReportDialogs.showSuccessDialog(
      context,
      onOkPressed: () async {
        Navigator.pop(context);
        if (!mounted) {
          return;
        }
        final Country? country = observation?.location.country;
        if (country == null) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return;
        }

        try {
          final campaignsResponse = await _campaignsApi.list(
            countryId: country.id,
            isActive: true,
            pageSize: 1,
            orderBy: BuiltList<String>(['-start_date']),
          );
          final Campaign? campaign =
              campaignsResponse.data?.results?.firstOrNull;
          if (campaign != null) {
            Dialogs.showAlertCampaign(
              context,
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

  Future<void> _handleQueuedSubmission() async {
    await ReportDialogs.showErrorDialog(context);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _logAnalyticsEvent(String eventName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: {'type': 'adult'},
    );
  }

  void _handleBackPressed() {
    if (_currentStep > 0) {
      _previousStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _stepTitles = _stepTitlesTextKeys
        .map(
          (key) => MyLocalizations.of(context, key),
        )
        .toList();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _handleBackPressed();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_stepTitles[_currentStep]),
          leading: _currentStep > 0
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previousStep,
                )
              : IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
          bottom: PreferredSize(
            child: ReportProgressIndicator(
              currentStep: _currentStep,
              totalSteps: _stepTitles.length,
            ),
            preferredSize: Size.fromHeight(0),
          ),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: NeverScrollableScrollPhysics(), // Disable swipe navigation
          children: [
            PhotoSelectionPage(
              photos: _reportData.photos,
              onPhotosChanged: _onPhotosChanged,
              onNext: _nextStep,
              // No onPrevious for adult reports (first step)
              maxPhotos: 3,
              minPhotos: 1,
              infoBadgeTextKey: 'one_mosquito_reminder_badge',
              thumbnailText:
                  MyLocalizations.of(context, 'ensure_single_mosquito_photos'),
            ),
            LocationSelectionPage(
              initialLatitude: _reportData.latitude,
              initialLongitude: _reportData.longitude,
              initialSource: _reportData.locationSource,
              onNext: (latitude, longitude, source) {
                setState(() {
                  _reportData.latitude = latitude;
                  _reportData.longitude = longitude;
                  _reportData.locationSource = source;
                });
                _nextStep();
              },
            ),
            EnvironmentQuestionPage(
              title: MyLocalizations.of(context, "question_13"),
              allowNullOption: false,
              onNext: (value) {
                setState(() {
                  _reportData.environmentAnswer = value != null
                      ? ObservationEventEnvironmentEnum.valueOf(value)
                      : null;
                });
                _nextStep();
              },
              onPrevious: _previousStep,
            ),
            NotesAndSubmitPage(
              initialNotes: _reportData.notes,
              onNotesChanged: _onNotesChanged,
              onSubmit: _submitReport,
              onPrevious: _previousStep,
              isSubmitting: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
