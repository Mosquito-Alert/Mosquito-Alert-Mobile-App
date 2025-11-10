import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/reports/shared/pages/location_selection_page.dart';
import 'package:mosquito_alert_app/pages/reports/shared/pages/notes_and_submit_page.dart';
import 'package:mosquito_alert_app/pages/reports/shared/pages/photo_selection_page.dart';
import 'package:mosquito_alert_app/pages/reports/shared/utils/report_dialogs.dart';
import 'package:mosquito_alert_app/pages/reports/shared/widgets/progress_indicator.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'models/breeding_site_report_data.dart';
import 'pages/larvae_question_page.dart';
import 'pages/site_type_selection_page.dart';
import 'pages/water_question_page.dart';

/// Main controller for the breeding site report workflow
/// Uses PageView slider architecture for step-by-step progression
class BreedingSiteReportController extends StatefulWidget {
  @override
  _BreedingSiteReportControllerState createState() =>
      _BreedingSiteReportControllerState();
}

class _BreedingSiteReportControllerState
    extends State<BreedingSiteReportController> {
  late PageController _pageController;
  late BreedingSiteReportData _reportData;
  late BreedingSitesApi _breedingSitesApi;

  int _currentStep = 0;
  bool _isSubmitting = false;

  static const int _stepWater = 2;
  static const int _stepLarvae = 3;
  static const int _stepLocation = 4;

  // Define the events to log
  final List<String> _pageEvents = [
    'report_add_site_type',
    'report_add_photo',
    'report_add_has_water',
    'report_add_has_larvae',
    'report_add_location',
    'report_add_note',
  ];

  List<String> get _stepTitles {
    return [
      '(HC) Site Type', // Step 0
      '(HC) Take Photos', // Step 1
      '(HC) Water Status', // Step 2
      '(HC) Larvae Check', // Step 3 (may be skipped)
      '(HC) Select Location', // Step 4
      '(HC) Notes & Submit', // Step 5
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _reportData = BreedingSiteReportData();

    // Initialize API
    final apiClient = Provider.of<MosquitoAlert>(context, listen: false);
    _breedingSitesApi = apiClient.getBreedingSitesApi();

    _logAnalyticsEvent('start_report');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to next step after water question, handling conditional larvae question
  Future<void> _nextStepAfterWater() async {
    if (_shouldSkipLarvaeStep) {
      // Clear any larvae response if water is not present
      _reportData.hasLarvae = null;
      // Skip larvae question and go directly to location
      setState(() {
        _currentStep = _stepLocation;
      });
      _pageController.animateToPage(
        _stepLocation,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Water is present, proceed to larvae question normally
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
      // Special handling for going back from location page
      if (_currentStep == _stepLocation && _shouldSkipLarvaeStep) {
        // Skip larvae question and go back to water question
        setState(() {
          _currentStep = _stepWater;
        });
        _pageController.animateToPage(
          _stepWater,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Normal previous step
        setState(() {
          _currentStep--;
        });
        _pageController.previousPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onPageChanged(int index) async {
    // Update current step to match the page
    setState(() {
      _currentStep = index;
    });

    // Check if the index is valid and log the event
    if (index >= 0 && index < _pageEvents.length) {
      await _logAnalyticsEvent(_pageEvents[index]);
    }
  }

  /// Handle location selection callback
  void _onLocationSelected(
      double latitude, double longitude, LocationRequestSource_Enum source) {
    setState(() {
      _reportData.latitude = latitude;
      _reportData.longitude = longitude;
      _reportData.locationSource = source;
    });
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

  /// Submit the breeding site report via API
  Future<void> _submitReport() async {
    if (!_reportData.isValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });
    await _logAnalyticsEvent('submit_report');

    try {
      // Step 1: Create location request
      final locationRequest = LocationRequest((b) => b
        ..source_ = _reportData.locationSource
        ..point.latitude = _reportData.latitude!
        ..point.longitude = _reportData.longitude!);

      // Step 2: Process photos
      final List<MultipartFile> photos = [];
      final uuid = Uuid();
      for (final photo in _reportData.photos) {
        photos.add(await MultipartFile.fromBytes(photo,
            filename:
                '${uuid.v4()}.jpg', // NOTE: Filename is required by the API
            contentType: DioMediaType('image', 'jpeg')));
      }
      final photosRequest = BuiltList<MultipartFile>(photos);

      // Step 3: Tags
      final userTags = await UserManager.getHashtags();
      final tags = userTags != null ? BuiltList<String>(userTags) : null;

      // Step 4: Make API call using BreedingSitesApi
      final response = await _breedingSitesApi.create(
        createdAt: _reportData.createdAt.toUtc(),
        sentAt: DateTime.now().toUtc(),
        location: locationRequest,
        photos: photosRequest,
        note: _reportData.notes,
        tags: tags,
        siteType: _reportData.siteType,
        hasWater: _reportData.hasWater,
        hasLarvae: _reportData.hasLarvae,
      );

      if (response.statusCode == 201) {
        ReportDialogs.showSuccessDialog(
          context,
          onOkPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
      } else {
        ReportDialogs.showErrorDialog(
            context, 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      ReportDialogs.showErrorDialog(context, 'Failed to submit report: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _logAnalyticsEvent(
    String eventName,
  ) async {
    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: {'type': 'breeding_site'},
    );
  }

  void _handleBackPressed() {
    if (_currentStep > 0) {
      _previousStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  bool get _shouldSkipLarvaeStep => _reportData.hasWater != true;

  List<String> _getEffectiveStepTitles() {
    final effectiveStepTitles = <String>[
      '(HC) Site Type',
      '(HC) Take Photos',
      '(HC) Water Status',
    ];

    // Add larvae step only if water is present
    if (_reportData.hasWater == true) {
      effectiveStepTitles.add('(HC) Larvae Check');
    }

    // Always add final steps
    effectiveStepTitles.addAll(['(HC) Select Location', '(HC) Notes & Submit']);

    return effectiveStepTitles;
  }

  int _calculateDisplayStep() {
    if (_currentStep <= _stepWater) {
      return _currentStep;
    } else if (_currentStep == _stepLarvae) {
      // Larvae question step - should only be reached when water is present
      return _stepWater + 1;
    } else if (_currentStep == _stepLocation) {
      // Location step
      return _shouldSkipLarvaeStep ? _stepWater + 1 : _stepLarvae + 1;
    } else {
      // Notes step
      return _shouldSkipLarvaeStep ? _stepWater + 2 : _stepLarvae + 2;
    }
  }

  List<Widget> get _pages {
    return [
      // Step 0: Site Type
      SiteTypeSelectionPage(
        reportData: _reportData,
        onNext: _nextStep,
      ),
      // Step 1: Photos
      PhotoSelectionPage(
        photos: _reportData.photos,
        onPhotosChanged: _onPhotosChanged,
        onNext: _nextStep,
        onPrevious: _previousStep,
        maxPhotos: 3,
        minPhotos: 1,
        infoBadgeTextKey: 'camera_info_breeding_txt_02',
        thumbnailText:
            '(HC) Photos of the same breeding site from different angles.',
      ),
      // Step 2: Water Status
      WaterQuestionPage(
        reportData: _reportData,
        onNext: _nextStepAfterWater,
        onPrevious: _previousStep,
      ),
      // Step 3: Larvae Question (always present but may be skipped)
      LarvaeQuestionPage(
        reportData: _reportData,
        onNext: _nextStep,
        onPrevious: _previousStep,
      ),
      // Step 4: Location
      LocationSelectionPage(
        initialLatitude: _reportData.latitude,
        initialLongitude: _reportData.longitude,
        onLocationSelected: _onLocationSelected,
        onNext: _nextStep,
        onPrevious: _previousStep,
        canProceed:
            _reportData.latitude != null && _reportData.longitude != null,
        locationSource: _reportData.locationSource,
      ),
      // Step 5: Notes and Submit
      NotesAndSubmitPage(
        initialNotes: _reportData.notes,
        onNotesChanged: _onNotesChanged,
        onSubmit: _submitReport,
        onPrevious: _previousStep,
        isSubmitting: _isSubmitting,
        submitLoadingText: '(HC) Submitting your breeding site report...',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentTitle = _stepTitles[_currentStep];

    // Calculate effective progress for display
    // We show progress based on actual steps the user will see
    final effectiveStepTitles = _getEffectiveStepTitles();

    // Calculate current step for progress indicator
    final displayStep = _calculateDisplayStep();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _handleBackPressed();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _handleBackPressed,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              ReportProgressIndicator(
                currentStep: displayStep,
                totalSteps: effectiveStepTitles.length,
                stepTitles: effectiveStepTitles,
              ),

              // Main content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics:
                      NeverScrollableScrollPhysics(), // Disable swipe navigation
                  children: _pages,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
