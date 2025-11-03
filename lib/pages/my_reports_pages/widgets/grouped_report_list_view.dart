import 'package:flutter/material.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';

class GroupedReportListView<T> extends StatelessWidget {
  final List<T> reports;
  final Text Function(T report) titleBuilder;
  final Widget? Function(T report)? leadingBuilder;
  final void Function(T report, BuildContext context) onTap;

  const GroupedReportListView({
    super.key,
    required this.reports,
    required this.titleBuilder,
    required this.onTap,
    this.leadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final groupedReports = ReportUtils.groupByMonth(reports);
    return GroupListView(
      sectionsCount: groupedReports.keys.length,
      countOfItemInSection: (int section) {
        final key = groupedReports.keys.elementAt(section);
        return groupedReports[key]?.length ?? 0;
      },
      separatorBuilder: (context, index) => const Divider(
        thickness: 0.2,
        height: 1,
        color: Colors.grey,
      ),
      itemBuilder: (BuildContext context, IndexPath index) {
        final report = groupedReports[
            groupedReports.keys.elementAt(index.section)]![index.index];

        return FutureBuilder<String>(
          future: ReportUtils.formatLocationWithCity(report),
          builder: (context, snapshot) {
            final subtitle = snapshot.connectionState == ConnectionState.waiting
                ? '(HC) Loading...'
                : (snapshot.data ?? '(HC) Unknown location');

            return ListTile(
              title: titleBuilder(report),
              subtitle: Text(subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  )),
              leading: leadingBuilder?.call(report),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => onTap(report, context),
            );
          },
        );
      },
      groupHeaderBuilder: (BuildContext context, int section) {
        return Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Text(
                groupedReports.keys.toList()[section],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ));
      },
    );
  }
}
