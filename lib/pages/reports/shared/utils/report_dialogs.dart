import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/pages/reports/shared/utils/InAppReviewManager.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

/// Dialog utilities for report functionality
class ReportDialogs {
  /// Show success dialog for report submissions
  /// Uses navigation pattern to return to app home screen
  static Future<void> showSuccessDialog(BuildContext context) {
    // Request in-app review after successful submission
    InAppReviewManager.requestInAppReview(context);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(MyLocalizations.of(context, 'app_name')),
        content: Text(MyLocalizations.of(context, 'save_report_ok_txt')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(
              foregroundColor: Style.colorPrimary,
            ),
            child: Text(MyLocalizations.of(context, 'ok')),
          ),
        ],
      ),
    );
  }
}
