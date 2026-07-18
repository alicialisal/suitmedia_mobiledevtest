import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../providers/user_list_provider.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserListProvider>().fetchUsers(page: 1, isRefresh: true);
    });
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
      context.read<UserListProvider>().fetchNextPage();
    }
  }

  void _onUserTap(UserModel user) {
    context.read<UserProvider>().setSelectedUserName(user.fullName);
    Navigator.pop(context);
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
    final listProvider = context.watch<UserListProvider>();

    if (listProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2B637B)),
      );
    }

    if (listProvider.errorMessage != null && listProvider.users.isEmpty) {
      return _buildErrorState(listProvider);
    }

    if (listProvider.users.isEmpty) {
      return _buildEmptyState(listProvider);
    }

    return RefreshIndicator(
      color: const Color(0xFF2B637B),
      onRefresh: listProvider.refresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: listProvider.users.length + (listProvider.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 82,
          endIndent: 16,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          if (index == listProvider.users.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF2B637B)),
              ),
            );
          }
          return _buildUserTile(listProvider.users[index]);
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

  Widget _buildEmptyState(UserListProvider listProvider) {
    return RefreshIndicator(
      color: const Color(0xFF2B637B),
      onRefresh: listProvider.refresh,
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

  Widget _buildErrorState(UserListProvider listProvider) {
    return RefreshIndicator(
      color: const Color(0xFF2B637B),
      onRefresh: listProvider.refresh,
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
                  listProvider.errorMessage ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: listProvider.refresh,
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
