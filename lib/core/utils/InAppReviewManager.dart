import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/features/bites/bite_repository.dart';
import 'package:mosquito_alert_app/features/breeding_sites/breeding_site_repository.dart';
import 'package:mosquito_alert_app/features/observations/observation_repository.dart';
import 'package:provider/provider.dart';

import '../../utils/UserManager.dart';

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

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastReportCount = await UserManager.getLastReportCount() ?? 0;
    final lastReviewRequest = await UserManager.getLastReviewRequest() ?? 0;

    var shouldRequestReview = (numReports == minimumReports ||
        numReports == minimumReports + 1 ||
        numReports >= lastReportCount + minimumReports ||
        now - lastReviewRequest >= 14 * 24 * 60 * 60 * 1000);

    if (!shouldRequestReview) {
      return;
    }

    final inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();

      await UserManager.setLastReviewRequest(now);
      await UserManager.setLastReportCount(numReports);
    }
  }
}
