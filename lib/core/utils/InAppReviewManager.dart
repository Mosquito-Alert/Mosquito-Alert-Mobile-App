import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/features/bites/data/bite_repository.dart';
import 'package:mosquito_alert_app/features/breeding_sites/data/breeding_site_repository.dart';
import 'package:mosquito_alert_app/features/observations/data/observation_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InAppReviewManager {
  static void requestInAppReview(BuildContext context) async {
    const int minimumReportsForReview = 3;

    try {
      // TODO: Get a single api endpoint to retrieve report count?
      final totalReports =
          await _getTotalReportCount(context, minimumReportsForReview);
      await _processReviewRequest(totalReports, minimumReportsForReview);
    } catch (e) {
      print('Error in requestInAppReview: $e');
    }
  }

  static Future<int> _getTotalReportCount(
      BuildContext context, int minimumRequired) async {
    final apiClient = Provider.of<sdk.MosquitoAlert>(context, listen: false);

    final observationRepository = ObservationRepository(apiClient: apiClient);
    final biteRepository = BiteRepository(apiClient: apiClient);
    final breedingSiteRepository = BreedingSiteRepository(apiClient: apiClient);

    int totalReports = 0;

    totalReports += await observationRepository.getCount();
    totalReports += await biteRepository.getCount();
    totalReports += await breedingSiteRepository.getCount();

    return totalReports;
  }

  static Future<void> _processReviewRequest(
      int numReports, int minimumReports) async {
    if (numReports < minimumReports) {
      return;
    }

    final now = DateTime.now();
    final lastReportCount = await _getLastReportCount();
    final lastReviewRequest = await _getLastReviewRequest();

    final shouldRequestReview = (numReports == minimumReports ||
        numReports == minimumReports + 1 ||
        numReports >= lastReportCount + minimumReports ||
        (lastReviewRequest == null ||
            now.difference(lastReviewRequest).inDays >= 14));

    if (!shouldRequestReview) {
      return;
    }

    final inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();

      await _setLastReviewRequest(now);
      await _setLastReportCount(numReports);
    }
  }

  static Future<DateTime?> _getLastReviewRequest() async {
    var prefs = await SharedPreferences.getInstance();
    final milliSeconds = prefs.getInt('lastReviewRequest');
    if (milliSeconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(milliSeconds);
    }
    return null;
  }

  static Future<void> _setLastReviewRequest(DateTime datetime) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastReviewRequest', datetime.millisecondsSinceEpoch);
  }

  static Future<int> _getLastReportCount() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastReportCount') ?? 0;
  }

  static Future<void> _setLastReportCount(int lastReportCount) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastReportCount', lastReportCount);
  }
}
