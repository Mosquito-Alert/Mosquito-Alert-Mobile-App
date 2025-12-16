import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/outbox/outbox_item.dart';
import 'package:mosquito_alert_app/core/outbox/outbox_mixin.dart';
import 'package:mosquito_alert_app/features/reports/data/models/base_report_request.dart';
import 'package:mosquito_alert_app/features/reports/domain/models/base_report.dart';
import 'package:mosquito_alert_app/core/repositories/pagination_repository.dart';

abstract class ReportRepository<
  TReport extends BaseReportModel,
  TSdkModel,
  TApi,
  TCreateReportRequest extends BaseCreateReportRequest
>
    extends PaginationRepository<TReport, TApi>
    with OutboxMixin {
  final MosquitoAlert apiClient;
  final TReport Function(TSdkModel) itemFactory;
  final TCreateReportRequest Function(Map<String, dynamic>)
  createRequestFactory;
  final TReport Function(TCreateReportRequest) createReportFromRequest;
  final TCreateReportRequest Function(TReport) createRequestFromReport;
  // NOTE: Hive box to store offline reports. This is replacing the OutboxItem
  // when creating new reports in order to avoid desynchronization issues.
  // Main issue: a report is stored in the box and the corresponding OutboxItem is lost.
  final Box<TReport> box;

  ReportRepository({
    required this.apiClient,
    required this.itemFactory,
    required this.createRequestFactory,
    required this.createReportFromRequest,
    required this.createRequestFromReport,
    required super.itemApi,
    required this.box,
  });

  Future<TReport> sendCreateToApi({required TCreateReportRequest request});

  @override
  Future<(List<TReport> items, bool hasMore)> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    List<TReport> items = [];
    if (page == 1) {
      // Load offline items only on first page
      items = box.values.toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    try {
      final response = await (itemApi as dynamic).listMine(
        page: page,
        pageSize: pageSize,
        orderBy: BuiltList<String>(["-created_at"]),
      );

      for (final item in response.data?.results ?? []) {
        items.add(itemFactory(item));
      }
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return (items, response.data?.next != null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (items, false);
      } else {
        rethrow;
      }
    }
  }

  Future<int> getCount() async {
    int count = box.length;
    try {
      final response = await (itemApi as dynamic).listMine(
        page: 1,
        pageSize: 1,
      );
      count += response.data?.count as int;
    } catch (_) {
      // Ignore
    }
    return count;
  }

  @override
  Future<void> execute(OutboxItem item) async {
    switch (item.operation) {
      case 'create':
        final request = createRequestFactory(item.payload);
        try {
          await _create(request: request);
        } catch (_) {
          break;
        }
        break;
      case 'delete':
        final request = DeleteReportRequest.fromJson(item.payload);
        try {
          await (itemApi as dynamic).destroy(uuid: request.uuid);
        } on DioException catch (e) {
          if (e.response?.statusCode == 404) {
            // Already deleted
            break;
          }
          rethrow;
        }
        break;
      default:
        throw Exception("Unknown op: ${item.operation}");
    }
    super.execute(item);
  }

  @override
  Future<void> syncRepository() async {
    List<TCreateReportRequest> createRequests = box.values
        .map((e) => createRequestFromReport(e))
        .toList();

    for (final request in createRequests) {
      try {
        await execute(
          OutboxItem(
            id: request.localId,
            repository: repoName,
            operation: 'create',
            payload: request.toJson(),
          ),
        );
      } catch (_) {
        // Do nothing
      }
    }

    await super.syncRepository();
  }

  @override
  Future<void> schedule(
    String operation,
    Map<String, dynamic> payload, {
    bool runNow = true,
  }) async {
    if (operation == 'create') {
      final request = createRequestFactory(payload);
      final newReport = createReportFromRequest(request);
      await box.put(newReport.localId, newReport);
      if (!runNow) return;
      await execute(
        OutboxItem(
          id: newReport.localId!,
          repository: repoName,
          operation: operation,
          payload: payload,
        ),
      );
      return;
    }
    await super.schedule(operation, payload, runNow: runNow);
  }

  @override
  Future<void> unscheduleOutboxTask(OutboxItem item) async {
    if (item.operation == 'create') {
      final request = createRequestFactory(item.payload);
      await box.delete(request.localId);
      return;
    }
    await super.unscheduleOutboxTask(item);
  }

  Future<TReport> create({required TCreateReportRequest request}) async {
    final newReport = await _create(request: request);
    if (newReport.localId != null) {
      await schedule('create', request.toJson(), runNow: false);
    }
    return newReport;
  }

  Future<TReport> _create({required TCreateReportRequest request}) async {
    TReport newReport;
    try {
      newReport = await sendCreateToApi(request: request);
      await box.delete(request.localId);
    } on DioException catch (e) {
      if (e.response?.statusCode != null && e.response!.statusCode! < 500) {
        rethrow;
      }
      newReport = createReportFromRequest(request);
    }
    return newReport;
  }

  Future<void> delete({required String uuid}) async {
    await schedule('delete', DeleteReportRequest(uuid: uuid).toJson());
  }
}
