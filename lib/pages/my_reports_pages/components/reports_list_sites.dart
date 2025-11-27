import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/site_report_detail_page.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/widgets/grouped_report_list_view.dart';
import 'package:mosquito_alert_app/providers/report_provider.dart';
import 'package:mosquito_alert_app/utils/report_formatter.dart';

import 'package:provider/provider.dart';

class ReportsListSites extends StatefulWidget {
  const ReportsListSites({super.key});

  @override
  State<ReportsListSites> createState() => _ReportsListSitesState();
}

class _ReportsListSitesState extends State<ReportsListSites> {
  @override
  Widget build(BuildContext context) {
    return GroupedReportListView<BreedingSite>(
      provider: context.watch<BreedingSiteProvider>(),
      titleBuilder: (report) {
        return BreedingSiteWidgets(context, report).buildTitleText();
      },
      leadingBuilder: (report) {
        return ReportDetailWidgets.buildLeadingImage(
          report: report,
        );
      },
      onTap: (report, context) async {
        return await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteReportDetailPage(breedingSite: report),
          ),
        );
      },
    );
  }
}
