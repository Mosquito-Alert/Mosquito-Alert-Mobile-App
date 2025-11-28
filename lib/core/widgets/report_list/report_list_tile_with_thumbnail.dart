import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/core/models/base_report.dart';
import 'package:mosquito_alert_app/core/widgets/common_widgets.dart';
import 'package:mosquito_alert_app/core/widgets/report_detail_page.dart';
import 'package:mosquito_alert_app/core/widgets/report_list/report_list_tile.dart';

class ReportListTileWithThumbnail<ReportType extends BaseReport>
    extends ReportListTile<ReportType> {
  ReportListTileWithThumbnail({
    Key? key,
    required ReportType report,
    required ReportDetailPage<ReportType> reportDetailPage,
  }) : super(
          key: key,
          report: report,
          reportDetailPage: reportDetailPage,
          leadingBuilder: (report) => buildThumbnailImage(
              photo: (report as BaseReportWithPhotos).thumbnail),
        );
}
