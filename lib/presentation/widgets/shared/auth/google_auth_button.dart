import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleAuthButton extends StatelessWidget {
  final String text;
  const GoogleAuthButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: SvgPicture.asset(
        "assets/google_icon.svg",
        width: 32,
        height: 32,
        fit: BoxFit.cover,
      ),
      label: Text(
        text,
        style: GoogleFonts.manrope(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () {
        // Google Sign-In logic here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In not implemented yet.')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}