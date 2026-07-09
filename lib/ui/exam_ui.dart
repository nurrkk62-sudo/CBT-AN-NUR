import '../camera_view.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ExamUI extends StatelessWidget {
  final CameraController cam;
  final int pelanggaran;
  final int jawaban;
  final List<int> jawabanList;
  final List<Map<String, dynamic>> soalList;
  final int currentIndex;
  final int totalSoal;
  final String namaUser;
  final String waktuTersisa;
  final String statusPengawas;

  final ValueChanged<int> onPick;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final ValueChanged<int> onJumpToQuestion;
  final VoidCallback onFinish;

  const ExamUI({
    super.key,
    required this.cam,
    required this.pelanggaran,
    required this.jawaban,
    required this.jawabanList,
    required this.soalList,
    required this.currentIndex,
    required this.totalSoal,
    required this.namaUser,
    required this.waktuTersisa,
    required this.onPick,
    required this.onNext,
    required this.onPrev,
    required this.onJumpToQuestion,
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
    final pertanyaan = (soal['pertanyaan'] ?? soal['Pertanyaan'] ?? "-").toString();

    final options = [
      soal['opsi_a'] ?? "-",
      soal['opsi_b'] ?? "-",
      soal['opsi_c'] ?? "-",
      soal['opsi_d'] ?? "-",
    ];

    const primary = Color(0xFF0D5C34);
    const primaryDark = Color(0xFF084024);
    const primaryLight = Color(0xFFE8F5E9);
    const textDark = Color(0xFF1E2D24);
    const textSoft = Color(0xFF556B5D);
    const borderColor = Color(0xFFE2E8E4);
    const timerColor = Color(0xFF2E7D32);
    const violationColor = Color(0xFFC62828);
    const cardColor = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: borderColor,
            height: 1.0,
          ),
        ),
            title: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F7F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/logo_uin.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(width: 12),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "CBT AN-NUR",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "SISTEM UJIAN ONLINE UIN",
                      style: TextStyle(
                        fontSize: 10,
                        color: textSoft,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      ),
      body: Stack(
        children: [
          // Base Scroll View
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 160, // Extra space at bottom to prevent floating camera overlap
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Participant Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x080D5C34),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "PESERTA UJIAN",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: textSoft,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              namaUser,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Timer & Violations Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF7ED),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFC8E6C9),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: timerColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              waktuTersisa,
                              style: const TextStyle(
                                color: timerColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF0F0),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFFFCDD2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: violationColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Pelanggaran: $pelanggaran",
                              style: const TextStyle(
                                color: violationColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Proctoring Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusPengawas.contains("normal") || statusPengawas.contains("aktif")
                              ? Colors.green
                              : Colors.amber,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (statusPengawas.contains("normal") || statusPengawas.contains("aktif")
                                      ? Colors.green
                                      : Colors.amber)
                                  .withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          statusPengawas,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Question Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x060D5C34),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "SOAL ${currentIndex + 1} DARI $totalSoal",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "Nilai: ${soal['nilai'] ?? 0}",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pertanyaan,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Custom Option Cards
                for (int i = 0; i < options.length; i++) ...[
                  Builder(builder: (context) {
                    final isSelected = (jawaban == i);
                    final charOption = String.fromCharCode(65 + i); // A, B, C, D

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: isSelected ? primaryLight : cardColor,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () => onPick(i),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? primary : borderColor,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Option Badge
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected ? primary : const Color(0xFFF0F4F2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      charOption,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : textDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Option Text
                                Expanded(
                                  child: Text(
                                    options[i].toString(),
                                    style: TextStyle(
                                      color: isSelected ? primaryDark : textDark,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 20),

                // Previous & Next Navigation Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentIndex > 0 ? onPrev : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primary,
                          disabledBackgroundColor: Colors.white.withOpacity(0.5),
                          disabledForegroundColor: Colors.grey.shade400,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: currentIndex > 0 ? primary : borderColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          "Sebelumnya",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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
                          disabledBackgroundColor: primary.withOpacity(0.4),
                          disabledForegroundColor: Colors.white70,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Berikutnya",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Question Navigation Grid Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x060D5C34),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "NAVIGASI SOAL",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 220, // Tinggi area navigasi, bisa diubah menjadi 250 atau 300
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: totalSoal,
                            itemBuilder: (context, index) {
                              final isCurrent = (index == currentIndex);
                              final isAnswered = (jawabanList[index] != -1);

                              Color buttonBg;
                              Color textCol;
                              BorderSide borderSide;

                              if (isCurrent) {
                                buttonBg = primary;
                                textCol = Colors.white;
                                borderSide = BorderSide.none;
                              } else if (isAnswered) {
                                buttonBg = primaryLight;
                                textCol = primary;
                                borderSide = const BorderSide(color: primary, width: 1);
                              } else {
                                buttonBg = Colors.white;
                                textCol = textSoft;
                                borderSide = const BorderSide(color: borderColor, width: 1);
                              }

                              return Material(
                                color: buttonBg,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () => onJumpToQuestion(index),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.fromBorderSide(borderSide),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          color: textCol,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Ujian Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0x332E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Selesai Ujian",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Proctoring Camera PiP (Overlay)
          Positioned(
            bottom: 24,
            right: 16,
            child: Container(
              width: 90,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D5C34).withOpacity(0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CameraView(
                cam: cam,
                height: 120,
                width: 90,
              ),
            ),
          ),
        ],
      ),
    );
  }
}