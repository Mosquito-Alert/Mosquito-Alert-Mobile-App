import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/features/reports/domain/models/base_report.dart';

abstract class ReportDetailPage<ReportType extends BaseReportModel>
    extends StatefulWidget {
  final ReportType item;

  const ReportDetailPage({super.key, required this.item});
}
