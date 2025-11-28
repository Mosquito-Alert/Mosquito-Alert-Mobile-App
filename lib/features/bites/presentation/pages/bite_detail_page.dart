import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/core/adapters/bite_report.dart';
import 'package:mosquito_alert_app/core/models/report_detail_field.dart';
import 'package:mosquito_alert_app/core/widgets/report_detail_page.dart';
import 'package:mosquito_alert_app/features/bites/presentation/state/bite_provider.dart';
import 'package:mosquito_alert_app/pages/reports/bite/models/bite_report_data.dart';
import 'package:mosquito_alert_app/pages/reports/bite/widgets/body_part_selector.dart';
import 'package:mosquito_alert_app/core/widgets/report_detail/report_detail_scaffold.dart';
import 'package:provider/provider.dart';

class BiteDetailPage extends ReportDetailPage<BiteReport> {
  const BiteDetailPage({Key? key, required BiteReport bite})
      : super(key: key, item: bite);

  @override
  _BiteDetailPageState createState() => _BiteDetailPageState();
}

class _BiteDetailPageState extends State<BiteDetailPage> {
  late BiteReport bite;
  BiteReportData biteReportData = BiteReportData();

  @override
  void initState() {
    super.initState();
    bite = widget.item;
    biteReportData.headBites = bite.raw.counts.head ?? 0;
    biteReportData.leftHandBites = bite.raw.counts.leftArm ?? 0;
    biteReportData.rightHandBites = bite.raw.counts.rightArm ?? 0;
    biteReportData.chestBites = bite.raw.counts.chest ?? 0;
    biteReportData.leftLegBites = bite.raw.counts.leftLeg ?? 0;
    biteReportData.rightLegBites = bite.raw.counts.rightLeg ?? 0;
    _logScreenView();
  }

  Future<void> _logScreenView() async {
    await FirebaseAnalytics.instance.logSelectContent(
      contentType: 'bite_report',
      itemId: bite.uuid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? locationEnvironment = bite.getLocalizedEnvironment(context);
    final String? eventMoment = bite.getEventMoment(context);
    // Build the map only if locationEnvironment is not null
    final extraFields = <ReportDetailField>[];
    if (locationEnvironment != null) {
      extraFields.add(ReportDetailField(
        icon: Icons.not_listed_location,
        value: locationEnvironment,
      ));
    }
    if (eventMoment != null) {
      extraFields.add(ReportDetailField(
        icon: Icons.av_timer,
        value: eventMoment,
      ));
    }

    Widget topBarBackground = LayoutBuilder(
      builder: (context, constraints) {
        return Container(
            color: Colors.white,
            child: SafeArea(
                child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: BodyPartSelector.buildVisualBodySelector(
                  context,
                  biteReportData,
                  isEditable: false,
                ),
              ),
            )));
      },
    );

    return ReportDetailScaffold<BiteReport>(
      report: bite,
      provider: context.watch<BiteProvider>(),
      extraFields: extraFields,
      topBarBackground: topBarBackground,
    );
  }
}
