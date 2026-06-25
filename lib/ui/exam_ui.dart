import '../camera_view.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ExamUI extends StatelessWidget {
  final CameraController cam;
  final int pelanggaran;
  final int jawaban;
  final List<Map<String, dynamic>> soalList;
  final int currentIndex;
  final int totalSoal;
  final String namaUser;
  final String waktuTersisa;
  final String statusPengawas;

  final ValueChanged<int> onPick;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onFinish;

  const ExamUI({
    super.key,
    required this.cam,
    required this.pelanggaran,
    required this.jawaban,
    required this.soalList,
    required this.currentIndex,
    required this.totalSoal,
    required this.namaUser,
    required this.waktuTersisa,
    required this.onPick,
    required this.onNext,
    required this.onPrev,
    required this.onFinish,
    required this.statusPengawas,
  });

  @override
  Widget build(BuildContext context) {
    if (soalList.isEmpty || currentIndex >= soalList.length) {
      return const Scaffold(
        body: Center(child: Text("Soal tidak ditemukan")),
      );
    }

    final soal = soalList[currentIndex];

    final pertanyaan =
        (soal['pertanyaan'] ?? soal['Pertanyaan'] ?? "-").toString();

    final options = [
      soal['opsi_a'] ?? "-",
      soal['opsi_b'] ?? "-",
      soal['opsi_c'] ?? "-",
      soal['opsi_d'] ?? "-",
    ];

    const primary = Color(0xFFE7A9C2);
    const primaryDark = Color(0xFFD98EAF);
    const bgTop = Color(0xFFFFF7FB);
    const bgBottom = Color(0xFFFCE8F1);
    const cardColor = Color(0xFFFFFCFD);
    const textDark = Color(0xFF6B4A5C);
    const textSoft = Color(0xFF9D7B8C);
    const borderColor = Color(0xFFF3D4E1);
    const timerColor = Color(0xFFE8A8BB);
    const violationColor = Color(0xFFD98BA5);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCEAF2),
        elevation: 0,
        centerTitle: true,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "CBT AN-NUR",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textDark,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "UJIAN ONLINE",
              style: TextStyle(
                fontSize: 11,
                color: textSoft,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1AD98EAF),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                "Peserta: $namaUser",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: textDark,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1AD98EAF),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: CameraView(cam: cam),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: timerColor.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: timerColor.withOpacity(0.35),
                      ),
                    ),
                    child: Text(
                      "Sisa waktu: $waktuTersisa",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: violationColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: violationColor.withOpacity(0.30),
                      ),
                    ),
                    child: Text(
                      "Pelanggaran: $pelanggaran",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                "Status pengawas: $statusPengawas",
                style: const TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14D98EAF),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Soal ${currentIndex + 1} / $totalSoal",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textSoft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pertanyaan,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (int i = 0; i < options.length; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: (jawaban == i) ? primaryDark : borderColor,
                    width: (jawaban == i) ? 2 : 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10D98EAF),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: RadioListTile<int>(
                  value: i,
                  groupValue: jawaban,
                  activeColor: primaryDark,
                  title: Text(
                    options[i].toString(),
                    style: TextStyle(
                      color:
                          (jawaban == i) ? textDark : const Color(0xFF7D6270),
                      fontWeight:
                          (jawaban == i) ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  onChanged: (v) => onPick(v ?? -1),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentIndex > 0 ? onPrev : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7DDE8),
                      foregroundColor: textDark,
                      disabledBackgroundColor: const Color(0xFFF8EEF3),
                      disabledForegroundColor: const Color(0xFFBFA8B3),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Sebelumnya",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentIndex < totalSoal - 1 ? onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFF1DCE5),
                      disabledForegroundColor: const Color(0xFFBFA8B3),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Berikutnya",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primary, primaryDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22D98EAF),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Selesai Ujian",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
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