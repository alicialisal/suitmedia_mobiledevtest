import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserListProvider extends ChangeNotifier {
  static const String _apiKey = 'free_user_3Gf07asKZphGhEN48JG3jSJCMtS';
  static const int _perPage = 10;

  final List<UserModel> _users = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  List<UserModel> get users => List.unmodifiable(_users);
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers({required int page, bool isRefresh = false}) async {
    if (isRefresh) {
      // Show full-screen loader only if we don't have any users cached yet
      _isLoading = _users.isEmpty;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (_isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final uri = Uri.https(
        'reqres.in',
        '/api/users',
        {'page': '$page', 'per_page': '$_perPage'},
      );

      final response = await http.get(
        uri,
        headers: {'x-api-key': _apiKey},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final List<UserModel> newUsers = (body['data'] as List)
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final int totalPages = (body['total_pages'] as int?) ?? 1;

        if (isRefresh) {
          _users.clear();
          _currentPage = 1;
        }
        _users.addAll(newUsers);
        _currentPage = page;
        _totalPages = totalPages;
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = null;
      } else {
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = 'Server error ${response.statusCode}. Please try again.';
      }
    } catch (e) {
      _isLoading = false;
      _isLoadingMore = false;
      _errorMessage = 'Failed to connect. Please check your internet connection.';
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchUsers(page: 1, isRefresh: true);
  }

  Future<void> fetchNextPage() async {
    if (!_isLoading && !_isLoadingMore && _currentPage < _totalPages) {
      await fetchUsers(page: _currentPage + 1);
    }
  }
}
