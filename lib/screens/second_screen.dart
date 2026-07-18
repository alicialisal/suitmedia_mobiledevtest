import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'third_screen.dart';

class SecondScreen extends StatefulWidget {
  final String userName;

  const SecondScreen({super.key, required this.userName});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  String _selectedUserName = 'Selected User Name';

  void _goToThirdScreen() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ThirdScreen(
          onUserSelected: (_) {},
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedUserName = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedUser = _selectedUserName != 'Selected User Name';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF2B637B), size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Second Screen',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            // "Welcome" static label
            Text(
              'Welcome',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            // Name from first screen
            Text(
              widget.userName,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            // Selected name for third screen
            Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: GoogleFonts.poppins(
                  fontSize: hasSelectedUser ? 20 : 22,
                  fontWeight: FontWeight.w700,
                  color: hasSelectedUser ? Colors.black87 : Colors.black54,
                ),
                child: Text(
                  _selectedUserName,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(),
            // Choose a user button
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goToThirdScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2B637B),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF2B637B).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Choose a User',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
