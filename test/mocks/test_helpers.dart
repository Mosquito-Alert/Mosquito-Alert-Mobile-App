import 'package:mosquito_alert/mosquito_alert.dart' as sdk;

// Helper function to create test notifications
sdk.Notification createTestNotification({
  required int id,
  required String title,
  required String body,
  bool isRead = false,
  DateTime? createdAt,
}) {
  return sdk.Notification((b) => b
    ..id = id
    ..isRead = isRead
    ..createdAt = createdAt ?? DateTime.now()
    ..message = sdk.NotificationMessage((m) => m
      ..title = title
      ..body = body).toBuilder());
}

// Helper function to create test bite reports
sdk.Bite createTestBite({
  required String uuid,
  DateTime? createdAt,
  DateTime? updatedAt,
  int? head,
  int? chest,
  int? leftArm,
  int? rightArm,
  int? leftLeg,
  int? rightLeg,
}) {
  final headCount = head ?? 0;
  final chestCount = chest ?? 0;
  final leftArmCount = leftArm ?? 0;
  final rightArmCount = rightArm ?? 0;
  final leftLegCount = leftLeg ?? 0;
  final rightLegCount = rightLeg ?? 0;
  final total = headCount +
      chestCount +
      leftArmCount +
      rightArmCount +
      leftLegCount +
      rightLegCount;

  return sdk.Bite((b) => b
    ..uuid = uuid
    ..createdAt = createdAt ?? DateTime.now()
    ..updatedAt = updatedAt ?? DateTime.now()
    ..counts = sdk.BiteCounts((c) => c
      ..head = headCount
      ..chest = chestCount
      ..leftArm = leftArmCount
      ..rightArm = rightArmCount
      ..leftLeg = leftLegCount
      ..rightLeg = rightLegCount
      ..total = total).toBuilder());
}
