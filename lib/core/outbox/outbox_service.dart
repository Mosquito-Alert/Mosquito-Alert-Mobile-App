import 'package:hive_ce/hive.dart';
import 'package:mosquito_alert_app/core/outbox/outbox_item.dart';
import 'package:uuid/uuid.dart';

class OutboxService {
  // ---- Singleton boilerplate ----
  OutboxService._internal();
  static final OutboxService _instance = OutboxService._internal();
  factory OutboxService() => _instance;

  // ---- Class implementation ----
  static const _boxName = 'outbox';
  late Box<OutboxItem> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox<OutboxItem>(_boxName);
    _initialized = true;
  }

  Future<OutboxItem> add(
    String repository,
    String operation,
    Map<String, dynamic> payload,
  ) async {
    final uuid = Uuid().v4();
    final item = OutboxItem(
      id: uuid,
      repository: repository,
      operation: operation,
      payload: payload,
    );
    await _box.put(uuid, item);
    return item;
  }

  List<OutboxItem> getAll() => _box.values.toList();

  Future<void> remove(String id) async => _box.delete(id);

  bool get isEmpty => _box.isEmpty;
}
