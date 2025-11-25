import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:math'; // Import library matematika untuk random
import 'placeholder_screen.dart';
import 'database_helper.dart';

class ResponderDashboardScreen extends StatefulWidget {
  const ResponderDashboardScreen({super.key});

  @override
  State<ResponderDashboardScreen> createState() => _ResponderDashboardScreenState();
}

class _ResponderDashboardScreenState extends State<ResponderDashboardScreen> {
  // --- DATABASE ---
  List<EmergencyReport> reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // Fungsi untuk mengambil data dari Database
  Future<void> _loadReports() async {
    final dbHelper = DatabaseHelper();
    final loadedReports = await dbHelper.getReports();
    setState(() {
      reports = loadedReports.reversed.toList(); // Balik urutan agar yang terbaru di atas
      _isLoading = false;
    });
  }

  // --- FUNGSI MENAMBAH DATA (SIMULASI) ---
  Future<void> _simulateIncomingReport() async {
    final dbHelper = DatabaseHelper();
    final random = Random();

    // Contoh data acak
    final List<String> types = ['Pencurian', 'Banjir', 'Pohon Tumbang', 'Ular Masuk Rumah'];
    final List<String> locations = ['Jl. Merpati No. 5', 'Jl. Kenari Blok A', 'Kampung Durian Runtuh', 'Jl. Simpang Lima'];
    
    String selectedType = types[random.nextInt(types.length)];
    
    // Tentukan ikon dan warna berdasarkan tipe (Sederhana)
    IconData icon;
    Color color;
    
    if (selectedType == 'Pencurian') {
      icon = Icons.warning_amber_rounded;
      color = Colors.orange;
    } else if (selectedType == 'Banjir') {
      icon = Icons.water_drop_outlined;
      color = Colors.blue;
    } else {
      icon = Icons.priority_high_rounded;
      color = Colors.red;
    }

    final newReport = EmergencyReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID Unik dari waktu
      reporterName: 'Warga ${random.nextInt(100)}',
      reportType: selectedType,
      location: locations[random.nextInt(locations.length)],
      timeAgo: 'Baru saja',
      distance: '${(random.nextDouble() * 5).toStringAsFixed(1)} km',
      description: 'Laporan baru terdeteksi di area anda. Segera lakukan pengecekan.',
      iconCodePoint: icon.codePoint,
      iconBgColorValue: color.withOpacity(0.2).value,
      statusColorValue: color.value,
      status: 'MENUNGGU RESPON',
    );

    // Simpan ke SQLite
    await dbHelper.insertReport(newReport);

    // Refresh tampilan
    await _loadReports();
    
    // Tampilkan notifikasi kecil
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan baru berhasil ditambahkan ke Database!')),
      );
    }
  }

  bool _isOnline = true;
  int _selectedBottomNavIndex = 0;

  // Helper for navigation
  void _navigateToFeature(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceholderScreen(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0EBF0),
      // --- TOMBOL TAMBAH DATA ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simulateIncomingReport,
        backgroundColor: const Color(0xFF1A2E35),
        icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
        label: Text(
          "Simulasi Laporan",
          style: GoogleFonts.instrumentSans(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
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
        child: Stack(
          children: [
             Positioned(
              left: -48,
              top: 726,
              child: Container(
                width: 493,
                height: 367,
                decoration: ShapeDecoration(
                  color: const Color(0x331A2E35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38835400),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -84,
              top: -169,
              child: Container(
                width: 558,
                height: 283,
                decoration: ShapeDecoration(
                  color: const Color(0x704ADEDE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38835400),
                  ),
                ),
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildAppBarContent(),
                            const SizedBox(height: 24),
                            _buildStatusSwitch(),
                            const SizedBox(height: 24),
                            _buildReportListHeader(),
                            const SizedBox(height: 16),
                            _buildReportList(),
                            const SizedBox(height: 100), 
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Responder',
              style: GoogleFonts.instrumentSans(
                color: const Color(0x99192D34),
                fontSize: 14,
              ),
            ),
            Text(
              'Siap Melayani',
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF1A2E35),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
             HapticFeedback.lightImpact();
             _navigateToFeature('Profil Responder');
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0x334ADEDE), width: 1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: const Icon(Icons.person, color: Color(0xFF1A2E35)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x334ADEDE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isOnline ? const Color(0x22A3E42F) : const Color(0x22FF6464),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isOnline ? Icons.power_settings_new : Icons.power_off,
                  color: _isOnline ? const Color(0xFF5FA3E4) : const Color(0xFFFF6464),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isOnline ? 'Status: ONLINE' : 'Status: OFFLINE',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF1A2E35),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isOnline ? 'Anda menerima laporan' : 'Anda tidak menerima laporan',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0x99192D34),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: _isOnline,
            activeColor: const Color(0xFFA3E42F),
            onChanged: (value) {
              setState(() {
                _isOnline = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Laporan Masuk',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF1A2E35),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E35),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${reports.length} Baru',
            style: GoogleFonts.instrumentSans(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            "Belum ada laporan masuk.",
            style: GoogleFonts.instrumentSans(color: const Color(0x99192D34)),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildReportCard(reports[index]);
      },
    );
  }

  Widget _buildReportCard(EmergencyReport report) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(report.statusColorValue).withOpacity(0.3), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            _navigateToFeature('Detail Laporan: ${report.reportType}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(report.iconBgColorValue),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(IconData(report.iconCodePoint, fontFamily: 'MaterialIcons'), color: const Color(0xFF1A2E35)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  report.reportType,
                                  style: GoogleFonts.instrumentSans(
                                    color: const Color(0xFF1A2E35),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                report.timeAgo,
                                style: GoogleFonts.instrumentSans(
                                  color: const Color(0x99192D34),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.location,
                            style: GoogleFonts.instrumentSans(
                              color: const Color(0x99192D34),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  report.description,
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF1A2E35),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.near_me_outlined, size: 16, color: Color(0x99192D34)),
                        const SizedBox(width: 4),
                        Text(
                          report.distance,
                          style: GoogleFonts.instrumentSans(
                            color: const Color(0x99192D34),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(report.statusColorValue).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(report.statusColorValue).withOpacity(0.2)),
                      ),
                      child: Text(
                        report.status,
                        style: GoogleFonts.instrumentSans(
                          color: Color(report.statusColorValue),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xCCFFFFFF),
        border: Border(
          top: BorderSide(width: 1, color: Color(0x334ADEDE)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isSelected: _selectedBottomNavIndex == 0,
            onTap: () => setState(() => _selectedBottomNavIndex = 0),
          ),
          _buildBottomNavItem(
            icon: Icons.history_rounded,
            label: 'Riwayat',
            isSelected: _selectedBottomNavIndex == 1,
            onTap: () {
               setState(() => _selectedBottomNavIndex = 1);
               _navigateToFeature('Riwayat Penanganan');
            }
          ),
          _buildBottomNavItem(
            icon: Icons.person_outline,
            label: 'Profil',
            isSelected: _selectedBottomNavIndex == 2,
            onTap: () {
               setState(() => _selectedBottomNavIndex = 2);
               _navigateToFeature('Profil Responder');
            }
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF1A2E35) : const Color(0x7F192D34),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              color: isSelected ? const Color(0xFF1A2E35) : const Color(0x7F192D34),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
