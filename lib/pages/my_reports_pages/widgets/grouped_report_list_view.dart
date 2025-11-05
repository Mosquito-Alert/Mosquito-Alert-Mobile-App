import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/detail/shared_report_widgets.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';

class GroupedReportListView extends StatefulWidget {
  final Text Function(dynamic report) titleBuilder;
  final Future<Response<dynamic>> Function(int page, int pageSize) fetchObjects;
  final Widget? Function(dynamic report)? leadingBuilder;
  final Future<bool?> Function(dynamic report, BuildContext context) onTap;

  const GroupedReportListView({
    super.key,
    required this.fetchObjects,
    required this.titleBuilder,
    required this.onTap,
    this.leadingBuilder,
  });

  @override
  _GroupedReportListViewState createState() => _GroupedReportListViewState();
}

class SectionHeader {
  final String date;

  SectionHeader(this.date);
}

class _GroupedReportListViewState extends State<GroupedReportListView> {
  static const _pageSize = 20;

  PagingState<int, dynamic> _state = PagingState();

  Future<void> refresh() async {
    setState(() {
      _state = PagingState();
    });
    await _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    if (_state.isLoading || !_state.hasNextPage) return;

    setState(() {
      _state = _state.copyWith(isLoading: true, error: null);
    });

    final nextPageKey = (_state.keys?.last ?? 0) + 1;

    try {
      final response = await widget.fetchObjects(nextPageKey, _pageSize);

      final data = response.data;
      if (data == null) {
        setState(() {
          _state = _state.copyWith(isLoading: false, hasNextPage: false);
        });
        return;
      }

      final newItems = data.results?.toList() ?? [];

      // Group items by date
      final List<dynamic> itemsWithHeaders = [];
      String? lastDate = _state.pages
          ?.expand((page) => page) // flatten the list of lists
          .whereType<SectionHeader>() // only SectionHeader items
          .lastOrNull // last one or null
          ?.date;
      for (var item in newItems) {
        // Format createdAt to 'dd MMMM yyyy'
        final formattedDate = DateFormat('dd MMMM yyyy').format(item.createdAt);

        if (formattedDate != lastDate) {
          // Insert SectionHeader before the first item of this date
          itemsWithHeaders.add(SectionHeader(formattedDate));
          lastDate = formattedDate;
        }
        itemsWithHeaders.add(item);
      }

      final isLastPage = data.next == null;

      setState(() {
        _state = _state.copyWith(
          pages: [...?_state.pages, itemsWithHeaders],
          keys: [...?_state.keys, nextPageKey],
          hasNextPage: !isLastPage,
          isLoading: false,
        );
      });
    } catch (e) {
      setState(() {
        _state = _state.copyWith(isLoading: false, error: e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          await refresh();
        },
        child: PagedListView.separated(
          state: _state,
          fetchNextPage: _fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<dynamic>(
              noItemsFoundIndicatorBuilder: (context) => Center(
                    child:
                        Text(MyLocalizations.of(context, 'no_reports_yet_txt')),
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
                        item.date, // SectionHeader already stores formatted date
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Render normal item
                  return FutureBuilder<String>(
                    future: ReportUtils.formatLocationWithCity(item),
                    builder: (context, snapshot) {
                      final subtitle =
                          snapshot.connectionState == ConnectionState.waiting
                              ? '(HC) Loading...'
                              : (snapshot.data ?? '(HC) Unknown location');

                      return ListTile(
                        title: widget.titleBuilder(item),
                        subtitle: Text(subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            )),
                        leading: widget.leadingBuilder?.call(item),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          bool? deleted = await widget.onTap(item, context);
                          if (deleted == true) {
                            await refresh();
                          }
                        },
                      );
                    },
                  );
                }
              }),
          separatorBuilder: (context, index) => const Divider(
            thickness: 0.2,
            height: 1,
            color: Colors.grey,
          ),
        ));
  }
}
