class OutboxItem {
  final String id;

  final String repository;

  final String operation;

  final Map<String, dynamic> payload;

  OutboxItem({
    required this.id,
    required this.repository,
    required this.operation,
    required this.payload,
  });
}
