import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/core/repositories/pagination_repository.dart';

class NotificationRepository extends PaginationRepository<sdk.Notification> {
  NotificationRepository({required super.itemApi});

  @override
  Future<Response> fetchPage({
    required int page,
    required int pageSize,
  }) {
    return (itemApi as sdk.NotificationsApi).listMine(
      page: page,
      pageSize: pageSize,
      orderBy: BuiltList<String>([
        "-created_at",
      ]),
    );
  }
}
