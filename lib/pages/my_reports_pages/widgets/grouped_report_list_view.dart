import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/defaults/first_page_exception_indicator.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';
import 'package:mosquito_alert_app/providers/report_provider.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

class GroupedReportListView<ReportType> extends StatefulWidget {
  final ReportProvider<ReportType> provider;
  final Text Function(dynamic report) titleBuilder;
  final Widget? Function(dynamic report)? leadingBuilder;
  final Future<bool?> Function(dynamic report, BuildContext context) onTap;

  const GroupedReportListView({
    super.key,
    required this.provider,
    required this.titleBuilder,
    required this.onTap,
    this.leadingBuilder,
  });

  @override
  _GroupedReportListViewState createState() => _GroupedReportListViewState();
}

class SectionHeader {
  final DateTime date;

  SectionHeader(this.date);

  String get formattedDate => DateFormat.yMMMMd().format(date);
}

class _GroupedReportListViewState<ReportType>
    extends State<GroupedReportListView<ReportType>> {
  bool _didInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialLoad) {
      _didInitialLoad = true;
      widget.provider.fetchNextPage();
    }
  }

  List<Object> _addHeaders(List<ReportType> objects) {
    if (objects.isEmpty) return [];

    // Group items by date
    final List<Object> itemsWithHeaders = [];
    DateTime? lastDate;
    for (var item in objects) {
      final createdAt = (item as dynamic).createdAtLocal as DateTime?;
      if (createdAt == null) {
        itemsWithHeaders.add(item as Object); // Just add item without header
        continue;
      }
      final currentDate =
          DateTime(createdAt.year, createdAt.month, createdAt.day);
      // NOTE: assuming items are sorted by createdAt descending
      if (lastDate == null || currentDate.isBefore(lastDate)) {
        itemsWithHeaders.add(SectionHeader(currentDate));
        lastDate = currentDate;
      }
      itemsWithHeaders.add(item as Object);
    }
    return itemsWithHeaders;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () => widget.provider.refresh(),
        child: PagedListView<int, Object>.separated(
          state: PagingState(
            pages: [_addHeaders(widget.provider.objects)],
            keys: [1],
            hasNextPage: widget.provider.hasMore,
            isLoading: widget.provider.isLoading,
            error: widget.provider.errorMessage,
          ),
          fetchNextPage: widget.provider.fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<Object>(
              noItemsFoundIndicatorBuilder: (context) =>
                  FirstPageExceptionIndicator(
                    title: MyLocalizations.of(context, 'no_reports_yet_txt'),
                  ),
              itemBuilder: (context, item, index) {
                if (item is SectionHeader) {
                  // Render section header
                  return Container(
                    color: Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: Text(
                        item.formattedDate,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }
                // We now know it's ReportType, so cast:
                final report = item as ReportType;
                // Render normal item
                return FutureBuilder<String>(
                  future: ReportUtils.formatLocationWithCity(report),
                  builder: (context, snapshot) {
                    final subtitle = snapshot.connectionState ==
                            ConnectionState.waiting
                        ? MyLocalizations.of(context, 'loading') + '...'
                        : (snapshot.data ??
                            MyLocalizations.of(context, 'unknown_location'));

                    return ListTile(
                      title: widget.titleBuilder(report),
                      subtitle: Text(subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          )),
                      leading: widget.leadingBuilder?.call(item),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        bool? deleted = await widget.onTap(report, context);
                        if (deleted == true) {
                          await widget.provider.refresh();
                        }
                      },
                    );
                  },
                );
              }),
          separatorBuilder: (context, index) => const Divider(
            thickness: 0.2,
            height: 1,
            color: Colors.grey,
          ),
        ));
  }
}
