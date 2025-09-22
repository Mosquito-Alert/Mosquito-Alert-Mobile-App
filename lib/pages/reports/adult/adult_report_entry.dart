import 'package:flutter/material.dart';

import 'adult_report_controller.dart';

/// Entry point for the adult report workflow
/// Call this function from anywhere in the app to start an adult report
Future<void> startAdultReportWorkflow(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AdultReportController(),
    ),
  );
}
