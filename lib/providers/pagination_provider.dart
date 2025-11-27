import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:mosquito_alert/mosquito_alert.dart' as sdk;

abstract class PaginationProvider<T> extends ChangeNotifier {
  static const _pageSize = 20;
  final sdk.MosquitoAlert apiClient;

  PaginationProvider({required this.apiClient});

  List<T> objects = [];

  // Pagination state
  int _lastFetchedPage = 0;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<Response> fetchPage({
    required int page,
    required int pageSize,
  });

  Future<void> fetchNextPage({bool clear = false}) async {
    if (_isLoading || !_hasMore) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      int nextPage = _lastFetchedPage + 1;
      final response = await fetchPage(page: nextPage, pageSize: _pageSize);

      final newObjects = response.data?.results?.toList() ?? [];
      _hasMore = response.data?.next != null;
      _lastFetchedPage = nextPage;

      if (clear) {
        objects = newObjects;
      } else {
        objects.addAll(newObjects);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _lastFetchedPage = 0;
    _hasMore = true;
    await fetchNextPage(clear: true);
  }
}
