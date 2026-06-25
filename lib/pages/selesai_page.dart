import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDFF0).withOpacity(0.55),
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
                  color: const Color(0xFFE8F7EE).withOpacity(0.7),
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
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFF4DCE8),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1ACFA6BA),
                          blurRadius: 30,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFE5F8EC),
                                const Color(0xFFD2F1DD),
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
                            color: Color(0xFF6E5162),
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
                            color: Color(0xFF8F7382),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFAFD),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFF2DCE7),
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F2F7),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            "Terima kasih sudah mengerjakan ujian dengan baik. Tetap semangat belajar dan terus percaya pada kemampuan diri sendiri.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Color(0xFF7E6674),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFEAB6CF),
                                  Color(0xFFD9A7C2),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22D9A7C2),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                SystemNavigator.pop();
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFFFFF0F7)
            : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? const Color(0xFFE9BED3)
              : const Color(0xFFF1E2EA),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8F7382),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 18 : 15,
              color: const Color(0xFF6E5162),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static String _pesanApresiasi(int nilai) {
    if (nilai >= 90) {
      return "Luar biasa. Kamu telah menyelesaikan ujian dengan hasil yang sangat baik. Terus pertahankan semangat belajarmu.";
    } else if (nilai >= 75) {
      return "Kerja bagus. Usahamu hari ini sangat berarti. Tetap semangat dan terus berkembang menjadi lebih baik.";
    } else if (nilai >= 60) {
      return "Terima kasih sudah menyelesaikan ujian dengan baik. Tetap semangat belajar, hasil yang baik akan datang dengan latihan yang konsisten.";
    } else {
      return "Terima kasih sudah berusaha sampai selesai. Jangan berkecil hati, setiap proses belajar selalu membawa kemajuan.";
    }
  }
}