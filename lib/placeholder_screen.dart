import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0EBF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A2E35)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: const Color(0xFF1A2E35).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Fitur "$title"\nSedang Dalam Pengembangan',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF1A2E35),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
