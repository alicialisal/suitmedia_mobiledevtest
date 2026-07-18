import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'second_screen.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _palindromeController = TextEditingController();

  bool _isPalindrome(String text) {
    final cleaned = text.replaceAll(' ', '').toLowerCase();
    final reversed = cleaned.split('').reversed.join('');
    return cleaned == reversed;
  }

  void _checkPalindrome() {
    final text = _palindromeController.text.trim();
    if (text.isEmpty) {
      _showDialog('Input Required', 'Please enter a text to check!');
      return;
    }
    final result = _isPalindrome(text);
    _showDialog("Result", result ? 'isPalindrome' : 'not palindrome');
  }

  void _showDialog(String? title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // SizedBox(height: 8),
        title: title != null
            ? Text(
                title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              )
            : null,
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: const Color(0xFF2B637B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextScreen() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showDialog('Name Required', 'Please enter your name to continue!');
      return;
    }
    context.read<UserProvider>().setUserName(name);
    context.read<UserProvider>().clearSelection();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SecondScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _palindromeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/background-image.png',
              fit: BoxFit.cover,
            ),
          ),
          // Subtle dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Profile avatar
                  Container(
                    width: 115,
                    height: 115,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55),
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Name field
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Name',
                  ),
                  const SizedBox(height: 16),
                  // Palindrome field
                  _buildTextField(
                    controller: _palindromeController,
                    hint: 'Palindrome',
                  ),
                  const SizedBox(height: 36),
                  // CHECK button
                  _buildButton(label: 'CHECK', onPressed: _checkPalindrome),
                  const SizedBox(height: 14),
                  // NEXT button
                  _buildButton(label: 'NEXT', onPressed: _goToNextScreen),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFF2B637B), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B637B),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF2B637B).withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}
