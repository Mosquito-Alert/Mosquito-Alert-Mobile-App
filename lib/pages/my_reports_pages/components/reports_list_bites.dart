import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/bite_report_detail_page.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/widgets/grouped_report_list_view.dart';
import 'package:mosquito_alert_app/providers/report_provider.dart';
import 'package:mosquito_alert_app/utils/report_formatter.dart';

import 'package:provider/provider.dart';

class ReportsListBites extends StatefulWidget {
  const ReportsListBites({super.key});

  @override
  State<ReportsListBites> createState() => _ReportsListBitesState();
}

class _ReportsListBitesState extends State<ReportsListBites> {
  @override
  Widget build(BuildContext context) {
    return GroupedReportListView<Bite>(
      provider: context.watch<BiteProvider>(),
      titleBuilder: (report) {
        return BiteWidgets(context, report).buildTitleText();
      },
      onTap: (report, context) async {
        return await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BiteReportDetailPage(bite: report),
          ),
        );
      },
    );
  }
}
