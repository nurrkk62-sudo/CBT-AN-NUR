import 'package:flutter/material.dart';
import 'login_page.dart'; // Import halaman login
import '../main.dart'; // Import main.dart untuk mengambil variabel global cameras

class SelesaiPage extends StatelessWidget {
  final String nama;
  final String kelas;
  final int nilaiAkhir;

  const SelesaiPage({
    super.key,
    required this.nama,
    required this.kelas,
    required this.nilaiAkhir,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D5C34);
    const primaryDark = Color(0xFF084024);
    const primaryLight = Color(0xFFE8F5E9);
    const textDark = Color(0xFF1E2D24);
    const textSoft = Color(0xFF556B5D);
    const borderColor = Color(0xFFE2E8E4);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background bubbles
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: primaryLight.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -20,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: borderColor,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C0D5C34),
                          blurRadius: 30,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Checkmark Success Badge
                        Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE5F8EC),
                                Color(0xFFD2F1DD),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB9E6C9).withOpacity(0.45),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 62,
                            color: Color(0xFF3DAA6B),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          "Ujian Selesai",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _pesanApresiasi(nilaiAkhir),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.65,
                            color: textSoft,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Results Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBFDFB),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                          child: Column(
                            children: [
                              _infoRow("Nama", nama),
                              const SizedBox(height: 12),
                              _infoRow("Kelas", kelas),
                              const SizedBox(height: 12),
                              _infoRow(
                                "Nilai Akhir",
                                nilaiAkhir.toString(),
                                highlight: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Inspirational Quote Panel
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4F2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            "Terima kasih sudah mengerjakan ujian dengan baik. Tetap semangat belajar dan terus percaya pada kemampuan diri sendiri.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Color(0xFF3E5044),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        // Close Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  primary,
                                  primaryDark,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x220D5C34),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // Kembali ke halaman login dan menghapus seluruh tumpukan halaman sebelumnya
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(cameras: cameras), // Membuka halaman login
                                  ),
                                  (route) => false, // Menghapus seluruh route sebelumnya agar tidak bisa di-back
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                "Selesai",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false}) {
    const primary = Color(0xFF0D5C34);
    const primaryLight = Color(0xFFE8F5E9);
    const textDark = Color(0xFF1E2D24);
    const textSoft = Color(0xFF556B5D);
    const borderColor = Color(0xFFE2E8E4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: highlight ? primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? const Color(0xFFC8E6C9) : borderColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: textSoft,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 18 : 15,
              color: highlight ? primary : textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static String _pesanApresiasi(int nilai) {
    if (nilai >= 90) {
      return "Luar biasa. Kamu telah menyelesaikan ujian dengan hasil yang sangat baik. Terus pertahaman semangat belajarmu.";
    } else if (nilai >= 75) {
      return "Kerja bagus. Usahamu hari ini sangat berarti. Tetap semangat dan terus berkembang menjadi lebih baik.";
    } else if (nilai >= 60) {
      return "Terima kasih sudah menyelesaikan ujian dengan baik. Tetap semangat belajar, hasil yang baik akan datang dengan latihan yang konsisten.";
    } else {
      return "Terima kasih sudah berusaha sampai selesai. Jangan berkecil hati, setiap proses belajar selalu membawa kemajuan.";
    }
  }
}