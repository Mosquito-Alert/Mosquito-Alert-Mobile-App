import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:mosquito_alert_app/core/repositories/pagination_repository.dart';

abstract class ReportRepository<ApiType> extends PaginationRepository<ApiType> {
  ReportRepository({required ApiType itemApi}) : super(itemApi: itemApi);

  @override
  Future<Response> fetchPage({
    required int page,
    required int pageSize,
  }) {
    return (itemApi as dynamic).listMine(
      page: page,
      pageSize: pageSize,
      orderBy: BuiltList<String>([
        "-created_at",
      ]),
    );
  }

  Future<void> delete({required String uuid}) async {
    await (itemApi as dynamic).destroy(uuid: uuid);
  }
}
