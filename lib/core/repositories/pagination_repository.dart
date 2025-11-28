import 'package:dio/dio.dart';

abstract class PaginationRepository<ApiType> {
  final ApiType itemApi;

  PaginationRepository({required this.itemApi});

  Future<Response> fetchPage({
    required int page,
    required int pageSize,
  });
}
