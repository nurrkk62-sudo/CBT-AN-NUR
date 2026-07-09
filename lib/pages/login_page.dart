import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../exam_page.dart';

class LoginPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const LoginPage({super.key, required this.cameras});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  final String scriptUrl =
      "https://script.google.com/macros/s/AKfycbxp3e7JCp5qaMiTstv8AerD-KxdhQCcgnoi6CYvRVKNwWWrZs5M6t27Fs33HH7h0K-jnA/exec";

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan password wajib diisi"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final uri = Uri.parse(scriptUrl).replace(
        queryParameters: {
          "action": "login",
          "username": username,
          "password": password,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login gagal. Status code: ${response.statusCode}"),
          ),
        );
        return;
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data is Map && data["status"] == "success") {
        // Jika status success, arahkan pengguna ke halaman ujian
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExamPage(
              cameras: widget.cameras,
              userData: Map<String, dynamic>.from(data["user"] ?? {}),
            ),
          ),
        );
      } else if (data is Map && data["status"] == "sudah_ujian") {
        // Jika status sudah_ujian, tampilkan pop-up dialog informasi
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Akses Ditolak"), // Judul dialog pop-up
            content: const Text("Akun ini sudah menyelesaikan ujian dan tidak bisa masuk lagi."), // Isi pesan dialog
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Tombol OK untuk menutup dialog pop-up
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        // Jika status lainnya (gagal), tampilkan pesan error menggunakan SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (data is Map ? data["message"] : null) ?? "Login gagal",
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error login: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0D5C34);
    const primaryDark = Color(0xFF084024);
    const primaryLight = Color(0xFFE8F5E9);
    const textDark = Color(0xFF1E2D24);
    const textSoft = Color(0xFF556B5D);
    const borderColor = Color(0xFFE2E8E4);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/cbt.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.60),
                    const Color(0xFFEDF4F0).withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 360,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 35,
                    ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                   Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6F1),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/logo_uin.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    const SizedBox(height: 23),
                    const Text(
                      "LOGIN CBT",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Silakan masuk untuk memulai ujian",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSoft,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        labelStyle: const TextStyle(color: textSoft),
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: textSoft,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.92),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: const TextStyle(color: textSoft),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: textSoft,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.92),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => isLoading ? null : login(),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
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
                              color: Color(0x220D5C34),
                              blurRadius: 14,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.6,
                                  ),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
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
        ],
      ),
    );
  }
}