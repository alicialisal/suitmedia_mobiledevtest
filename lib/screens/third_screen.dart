import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

// ── Data model ───────────────────────────────────────────────────────────────

class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        email: json['email'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        avatar: json['avatar'] as String,
      );
}

// ── Third Screen ─────────────────────────────────────────────────────────────

class ThirdScreen extends StatefulWidget {
  final void Function(String name) onUserSelected;

  const ThirdScreen({super.key, required this.onUserSelected});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  static const String _apiKey = 'free_user_3Gf07asKZphGhEN48JG3jSJCMtS';
  static const int _perPage = 10;

  final List<UserModel> _users = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers(page: 1, isRefresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 120) {
      if (!_isLoading && !_isLoadingMore && _currentPage < _totalPages) {
        _fetchUsers(page: _currentPage + 1);
      }
    }
  }

  Future<void> _fetchUsers(
      {required int page, bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        if (_users.isEmpty) {
          _isLoading = true;
        }
        _errorMessage = null;
      });
    } else {
      if (_isLoadingMore) return;
      setState(() => _isLoadingMore = true);
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

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final List<UserModel> newUsers = (body['data'] as List)
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final int totalPages = (body['total_pages'] as int?) ?? 1;

        setState(() {
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
        });
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage =
              'Server error ${response.statusCode}. Please try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage =
            'Failed to connect. Please check your internet connection.';
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchUsers(page: 1, isRefresh: true);
  }

  void _onUserTap(UserModel user) {
    widget.onUserSelected(user.fullName);
    Navigator.pop(context, user.fullName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              color: Color(0xFF2B637B), size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Third Screen',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2B637B)),
      );
    }

    if (_errorMessage != null && _users.isEmpty) {
      return _buildErrorState();
    }

    if (_users.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF2B637B),
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _users.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 82,
          endIndent: 16,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF2B637B)),
              ),
            );
          }
          return _buildUserTile(_users[index]);
        },
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return InkWell(
      onTap: () => _onUserTap(user),
      splashColor: const Color(0xFF2B637B).withValues(alpha: 0.08),
      highlightColor: const Color(0xFF2B637B).withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Circular avatar
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: user.avatar,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFE2EFF3),
                  child: const Icon(Icons.person,
                      color: Color(0xFF2B637B), size: 28),
                ),
                errorWidget: (_, _, _) => Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFE2EFF3),
                  child: const Icon(Icons.person,
                      color: Color(0xFF2B637B), size: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Full name + email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: const Color(0xFF2B637B),
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No users found',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pull down to refresh',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      color: const Color(0xFF2B637B),
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded,
                  size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  _errorMessage ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B637B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
