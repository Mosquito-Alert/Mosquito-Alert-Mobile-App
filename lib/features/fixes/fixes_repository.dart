import 'package:mosquito_alert/mosquito_alert.dart' as sdk;
import 'package:mosquito_alert_app/features/fixes/data/models/fix_request.dart';

class FixesRepository {
  final sdk.MosquitoAlert apiClient;
  late final sdk.FixesApi itemApi;

  FixesRepository({required this.apiClient}) {
    itemApi = apiClient.getFixesApi();
  }

  Future<void> create({required FixRequest request}) async {
    final fixRequest = sdk.FixRequest((f) => f
      ..coverageUuid = request.coverageUuid
      ..createdAt = request.createdAt.toUtc()
      ..sentAt = DateTime.now().toUtc()
      ..point = request.point.toBuilder()
      ..power = request.power);

    await itemApi.create(fixRequest: fixRequest);
  }
}
