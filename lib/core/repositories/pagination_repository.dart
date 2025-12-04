abstract class PaginationRepository<T, ApiType> {
  final ApiType itemApi;

  PaginationRepository({required this.itemApi});

  Future<(List<T> items, bool hasMore)> fetchPage({
    required int page,
    required int pageSize,
  });
}
