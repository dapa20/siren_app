import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _descriptionController = TextEditingController();
  String _selectedType = 'Kecelakaan Lalu Lintas';
  bool _isSubmitting = false;

  final List<String> _reportTypes = [
    'Kecelakaan Lalu Lintas',
    'Kebakaran',
    'Medis Darurat',
    'Tindak Kejahatan',
    'Bencana Alam',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi deskripsi kejadian')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Tentukan Icon dan Warna berdasarkan tipe laporan
    int iconCodePoint;
    Color color;

    switch (_selectedType) {
      case 'Kebakaran':
        iconCodePoint = Icons.local_fire_department_outlined.codePoint;
        color = const Color(0xFFE7000B); // Merah
        break;
      case 'Medis Darurat':
        iconCodePoint = Icons.medical_services_outlined.codePoint;
        color = const Color(0xFFFFB400); // Kuning/Oranye
        break;
      case 'Tindak Kejahatan':
        iconCodePoint = Icons.local_police_outlined.codePoint;
        color = const Color(0xFF28CFD8); // Biru Cyan
        break;
      case 'Bencana Alam':
        iconCodePoint = Icons.flood_outlined.codePoint;
        color = const Color(0xFFA3E42F); // Hijau
        break;
      default: // Kecelakaan
        iconCodePoint = Icons.car_crash_outlined.codePoint;
        color = const Color(0xFFFF6464); // Merah Muda
    }

    // Buat Object Report Baru
    final newReport = EmergencyReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate ID unik
      reporterName: 'Anda', // Hardcode karena belum ada sistem auth user full
      reportType: _selectedType,
      location: 'Lokasi Terkini', // Mock lokasi
      timeAgo: 'Baru saja',
      distance: '0.1 km', // Mock jarak
      description: _descriptionController.text,
      iconCodePoint: iconCodePoint,
      iconBgColorValue: color.withOpacity(0.2).value,
      statusColorValue: color.value,
      status: 'MENUNGGU RESPON',
    );

    // Simpan ke Database
    await DatabaseHelper().insertReport(newReport);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
      // Kembali ke Dashboard dan beritahu sukses
      Navigator.pop(context, true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0EBF0), Color(0xFFF0F9FF), Color(0xFFE8F8F5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: const Color(0x99FFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(width: 1, color: Color(0x334ADEDE)),
                      ),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1A2E35)),
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Buat Laporan',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2E35),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Isi detail keadaan darurat di sekitar Anda.',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    color: const Color(0x99192D34),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Input
                Text(
                  'Jenis Darurat',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2E35),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xCCFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x334ADEDE)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: _reportTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35)),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Deskripsi Kejadian',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2E35),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  style: GoogleFonts.instrumentSans(color: const Color(0xFF1A2E35)),
                  decoration: InputDecoration(
                    hintText: 'Ceritakan detail kejadian...',
                    hintStyle: GoogleFonts.instrumentSans(color: const Color(0x66192D34)),
                    filled: true,
                    fillColor: const Color(0xCCFFFFFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0x334ADEDE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0x334ADEDE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF4ADEDE), width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Submit Button
                GestureDetector(
                  onTap: _isSubmitting ? null : () {
                    HapticFeedback.mediumImpact();
                    _submitReport();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE7000B), Color(0xFFFF6464)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4CFF6464),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        )
                      ],
                    ),
                    child: Center(
                      child: _isSubmitting 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : Text(
                            'KIRIM LAPORAN',
                            style: GoogleFonts.instrumentSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}