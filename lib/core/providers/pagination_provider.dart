import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/core/repositories/pagination_repository.dart';

abstract class PaginatedProvider<T> extends ChangeNotifier {
  final PaginationRepository repository;
  final T Function(dynamic raw)? itemFactory;
  final List<T> Function(List<T>)? orderFunction;

  PaginatedProvider(
      {required this.repository, this.itemFactory, this.orderFunction});

  bool loadedInitial = false;

  List<T> _items = [];

  List<T> get items => _items;

  set items(List<dynamic> rawItems) {
    _items = itemFactory != null
        ? rawItems.map((item) => itemFactory!(item)).toList()
        : List<T>.from(rawItems);
    if (orderFunction != null) {
      _items = orderFunction!(_items);
    }
    notifyListeners();
  }

  void addItem(T item) {
    _items.insert(0, item);
    if (orderFunction != null) {
      _items = orderFunction!(_items);
    }
    notifyListeners();
  }

  void deleteItem(T item) {
    _items.removeWhere((element) => element == item);
    notifyListeners();
  }

  bool isLoading = false;
  bool isRefreshing = false;
  bool hasMore = true;
  int page = 0;
  int pageSize = 20;
  String? error;

  /// Implement this in your feature provider.
  Future<Response> fetchPage({
    required int page,
    required int pageSize,
  }) {
    return repository.fetchPage(page: page, pageSize: pageSize);
  }

  // Load first page
  Future<void> loadInitial() async {
    isLoading = true;
    error = null;
    loadedInitial = false;
    notifyListeners();
    try {
      page = 1;
      final response = await fetchPage(page: page, pageSize: pageSize);

      items = response.data?.results?.toList() ?? [];
      hasMore = response.data?.next != null;
      loadedInitial = true;
    } catch (e) {
      error = e.toString();
      page = 0;
    }

    isLoading = false;
    notifyListeners();
  }

  // Load more pages (infinite scroll)
  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    int nextPage = page + 1;
    try {
      final response = await fetchPage(page: nextPage, pageSize: pageSize);

      List<T> newItems = response.data?.results?.toList() ?? [];

      items.addAll(newItems);
      hasMore = response.data?.next != null;
    } catch (e) {
      error = e.toString();
      hasMore = false;
      nextPage = page; // stay on the same page on error
    }

    page = nextPage;
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (isRefreshing) return; // prevent double refresh
    isRefreshing = true;
    error = null;
    notifyListeners();

    try {
      page = 1;
      final response = await fetchPage(page: page, pageSize: pageSize);

      items = response.data?.results?.toList() ?? [];
      hasMore = response.data?.next != null;
    } catch (e) {
      error = e.toString();
    }

    isRefreshing = false;
    notifyListeners();
  }
}
