import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:mosquito_alert/mosquito_alert.dart';
import 'package:mosquito_alert_app/core/models/base_report.dart';
import 'package:mosquito_alert_app/core/repositories/pagination_repository.dart';

abstract class ReportRepository<ReportType extends BaseReportModel,
    SdkModelType, ApiType> extends PaginationRepository<ReportType, ApiType> {
  final MosquitoAlert apiClient;
  final ReportType Function(SdkModelType raw) itemFactory;

  ReportRepository({
    required this.apiClient,
    required this.itemFactory,
    required super.itemApi,
  });

  @override
  Future<(List<ReportType> items, bool hasMore)> fetchPage({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await (itemApi as dynamic).listMine(
        page: page,
        pageSize: pageSize,
        orderBy: BuiltList<String>([
          "-created_at",
        ]),
      );
      return (
        (response.data?.results?.map(itemFactory).toList() ?? [])
            as List<ReportType>,
        response.data?.next != null
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return (<ReportType>[], false);
      } else {
        rethrow;
      }
    }
  }

  Future<void> delete({required String uuid}) async {
    await (itemApi as dynamic).destroy(uuid: uuid);
  }
}
