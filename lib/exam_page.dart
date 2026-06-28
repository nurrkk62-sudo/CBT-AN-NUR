import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;

import 'ui/exam_ui.dart';
import 'pages/cheat_page.dart';
import 'pages/selesai_page.dart';

class ExamPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Map<String, dynamic> userData;

  const ExamPage({
    super.key,
    required this.cameras,
    required this.userData,
  });

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> with WidgetsBindingObserver {
  CameraController? _cam;
  Timer? _timer;
  late final FaceDetector _faceDetector;

  bool isLoading = true;
  bool _hasFinished = false;
  bool _isProcessingFrame = false;
  DateTime _lastProcessed = DateTime.now();

  int pelanggaran = 0;
  int currentIndex = 0;

  List<Map<String, dynamic>> soalList = [];
  List<int> jawabanList = [];
  List<String> detailPelanggaran = [];

  String statusPengawas = "Memulai pengawasan...";
  String? _cameraError;

  int durasiMenit = 30;
late int sisaDetik;

  DateTime _lastFaceSeenAt = DateTime.now();
  DateTime? _wrongPoseSince;
  DateTime? _lastAppViolationAt;

  bool _absenceViolationActive = false;
  bool _multiFaceViolationActive = false;
  bool _wrongPoseViolationActive = false;

  final String scriptUrl =
      "https://script.google.com/macros/s/AKfycbxp3e7JCp5qaMiTstv8AerD-KxdhQCcgnoi6CYvRVKNwWWrZs5M6t27Fs33HH7h0K-jnA/exec";

  static const Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  static const int _wajahHilangDetik = 3;
  static const int _poseSalahDetik = 2;

  static const double _maxYaw = 18;
  static const double _maxPitch = 18;
  static const double _maxRoll = 12;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    sisaDetik = durasiMenit * 60;

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableTracking: false,
        enableLandmarks: false,
        enableContours: false,
        enableClassification: false,
      ),
    );

    _secure();
    _initCam();
    getSoal();
  }

  Future<void> _secure() async {
    try {
      await FlutterWindowManagerPlus.addFlags(
        FlutterWindowManagerPlus.FLAG_SECURE,
      );
    } catch (e) {
      debugPrint('FLAG_SECURE error: $e');
    }
  }

  Future<void> _startImageStream() async {
    if (_cam == null) return;
    if (!_cam!.value.isInitialized) return;
    if (_cam!.value.isStreamingImages) return;

    try {
      await _cam!.startImageStream((image) {
        _processCameraImage(image);
      });
    } catch (e) {
      debugPrint("ERROR START STREAM: $e");
    }
  }

  Future<void> _initCam() async {
    try {
      if (widget.cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _cameraError = "Kamera tidak ditemukan";
        });
        return;
      }

      final selectedCamera = widget.cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => widget.cameras.first,
      );

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) return;

      _cam = controller;
      setState(() {
        _cameraError = null;
      });

      await _startImageStream();
    } catch (e) {
      debugPrint("ERROR INIT CAMERA: $e");
      if (!mounted) return;
      setState(() {
        _cameraError = "Gagal mengakses kamera";
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame || _hasFinished) return;

    final now = DateTime.now();

    if (now.difference(_lastProcessed).inMilliseconds < 500) return;

    _lastProcessed = now;
    _isProcessingFrame = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      _evaluateFaces(faces);
    } catch (e) {
      debugPrint("ERROR PROCESS FRAME: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _stopImageStream() async {
    if (_cam == null) return;
    if (!_cam!.value.isInitialized) return;

    if (_cam!.value.isStreamingImages) {
      try {
        await _cam!.stopImageStream();
      } catch (e) {
        debugPrint("ERROR STOP STREAM: $e");
      }
    }
  }

  Future<void> getSoal() async {
  try {
    final url = Uri.parse("$scriptUrl?action=getSoal");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List && data.isNotEmpty) {
        final parsed = data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        final durasiDariSheet =
            int.tryParse(parsed.first["durasi_menit"].toString()) ?? 30;

        if (!mounted) return;
        setState(() {
          soalList = parsed;
          jawabanList = List.filled(parsed.length, -1);
          durasiMenit = durasiDariSheet;
          sisaDetik = durasiMenit * 60;
        });

        _startTimer();
      } else {
        debugPrint("FORMAT SOAL TIDAK VALID / SOAL KOSONG");
      }
    } else {
      debugPrint("GAGAL AMBIL SOAL: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("ERROR GET SOAL: $e");
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _hasFinished) {
        timer.cancel();
        return;
      }

      if (sisaDetik > 0) {
        setState(() {
          sisaDetik--;
        });
      } else {
        timer.cancel();
        _finish(autoSubmit: true);
      }
    });
  }

  String formatWaktu(int totalDetik) {
    final menit = (totalDetik ~/ 60).toString().padLeft(2, '0');
    final detik = (totalDetik % 60).toString().padLeft(2, '0');
    return "$menit:$detik";
  }

  String _jamSekarang() {
    final now = DateTime.now();
    final jam = now.hour.toString().padLeft(2, '0');
    final menit = now.minute.toString().padLeft(2, '0');
    final detik = now.second.toString().padLeft(2, '0');
    return "$jam:$menit:$detik";
  }

  void nextSoal() {
    if (currentIndex < soalList.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void prevSoal() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void jumpToSoal(int index) {
    if (index >= 0 && index < soalList.length) {
      setState(() {
        currentIndex = index;
      });
    }
  }

  String convertJawaban(int index) {
    switch (index) {
      case 0:
        return "Opsi_A";
      case 1:
        return "Opsi_B";
      case 2:
        return "Opsi_C";
      case 3:
        return "Opsi_D";
      default:
        return "";
    }
  }

  int hitungNilai() {
    int totalNilai = 0;

    for (int i = 0; i < soalList.length; i++) {
      if (jawabanList[i] == -1) continue;

      final jawabanUser = convertJawaban(jawabanList[i]);
      final jawabanBenar = (soalList[i]['jawaban'] ?? "").toString();
      final nilaiSoal = int.tryParse(soalList[i]['nilai'].toString()) ?? 0;

      if (jawabanUser == jawabanBenar) {
        totalNilai += nilaiSoal;
      }
    }

    return totalNilai;
  }

  int hitungBenar() {
    int jumlahBenar = 0;

    for (int i = 0; i < soalList.length; i++) {
      if (jawabanList[i] == -1) continue;

      final jawabanUser = convertJawaban(jawabanList[i]);
      final jawabanBenar = (soalList[i]['jawaban'] ?? "").toString();

      if (jawabanUser == jawabanBenar) {
        jumlahBenar++;
      }
    }

    return jumlahBenar;
  }

  String jawabanRingkas() {
    final hasil = <String>[];

    for (int i = 0; i < jawabanList.length; i++) {
      final isi = jawabanList[i] == -1
          ? "Belum dijawab"
          : convertJawaban(jawabanList[i]);
      hasil.add("Soal ${i + 1}: $isi");
    }

    return hasil.join(" | ");
  }

  String detailPelanggaranRingkas() {
    if (detailPelanggaran.isEmpty) return "-";
    return detailPelanggaran.join(" | ");
  }

  Future<void> simpanHasil({
    required int nilaiAkhir,
    required int jumlahBenar,
  }) async {
    try {
      final nama = widget.userData["nama"] ?? "";
      final username = widget.userData["username"] ?? "";
      final kelas = widget.userData["kelas"] ?? "";

      final url = Uri.parse(
        "$scriptUrl?action=saveResult"
        "&nama=${Uri.encodeComponent(nama.toString())}"
        "&username=${Uri.encodeComponent(username.toString())}"
        "&kelas=${Uri.encodeComponent(kelas.toString())}"
        "&jawaban=${Uri.encodeComponent(jawabanRingkas())}"
        "&benar=$jumlahBenar"
        "&nilai=$nilaiAkhir"
        "&pelanggaran=$pelanggaran"
        "&detail_pelanggaran=${Uri.encodeComponent(detailPelanggaranRingkas())}"
        "&waktu=${Uri.encodeComponent(DateTime.now().toIso8601String())}",
      );

      final response = await http.get(url);
      debugPrint("SIMPAN HASIL: ${response.body}");
    } catch (e) {
      debugPrint("ERROR SIMPAN HASIL: $e");
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cam == null) return null;
    if (!_cam!.value.isInitialized) return null;

    final camera = _cam!.description;
    final sensorOrientation = camera.sensorOrientation;
    final deviceOrientation =
        _orientations[_cam!.value.deviceOrientation] ?? 0;

    final rotationCompensation =
        camera.lensDirection == CameraLensDirection.front
            ? (sensorOrientation + deviceOrientation) % 360
            : (sensorOrientation - deviceOrientation + 360) % 360;

    final rotation =
        InputImageRotationValue.fromRawValue(rotationCompensation);
    if (rotation == null) return null;

    final rawFormat = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rawFormat == null) return null;

    Uint8List bytes;
    InputImageFormat formatForMlkit;
    int bytesPerRow;

    if (rawFormat == InputImageFormat.nv21 && image.planes.isNotEmpty) {
      bytes = image.planes.first.bytes;
      formatForMlkit = InputImageFormat.nv21;
      bytesPerRow = image.planes.first.bytesPerRow;
    } else if (rawFormat == InputImageFormat.yuv_420_888 &&
        image.planes.length == 3) {
      bytes = _yuv420ToNv21(image);
      formatForMlkit = InputImageFormat.nv21;
      bytesPerRow = image.width;
    } else if (rawFormat == InputImageFormat.bgra8888 &&
        image.planes.isNotEmpty) {
      bytes = image.planes.first.bytes;
      formatForMlkit = InputImageFormat.bgra8888;
      bytesPerRow = image.planes.first.bytesPerRow;
    } else {
      debugPrint("FORMAT KAMERA TIDAK DIDUKUNG: $rawFormat");
      return null;
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: formatForMlkit,
        bytesPerRow: bytesPerRow,
      ),
    );
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final out = Uint8List(width * height + (width * height ~/ 2));
    int offset = 0;

    for (int row = 0; row < height; row++) {
      final rowStart = row * yPlane.bytesPerRow;
      out.setRange(offset, offset + width, yPlane.bytes, rowStart);
      offset += width;
    }

    final uvWidth = width ~/ 2;
    final uvHeight = height ~/ 2;

    final uRowStride = uPlane.bytesPerRow;
    final vRowStride = vPlane.bytesPerRow;
    final uPixelStride = uPlane.bytesPerPixel ?? 1;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;

    for (int row = 0; row < uvHeight; row++) {
      final uRowStart = row * uRowStride;
      final vRowStart = row * vRowStride;

      for (int col = 0; col < uvWidth; col++) {
        final uIndex = uRowStart + col * uPixelStride;
        final vIndex = vRowStart + col * vPixelStride;

        out[offset++] = vPlane.bytes[vIndex];
        out[offset++] = uPlane.bytes[uIndex];
      }
    }

    return out;
  }

  void _evaluateFaces(List<Face> faces) {
    final now = DateTime.now();

    if (faces.isEmpty) {
      _setStatus("Wajah tidak terdeteksi");

      if (!_absenceViolationActive &&
          now.difference(_lastFaceSeenAt).inSeconds >= _wajahHilangDetik) {
        _registerViolation("Wajah hilang lebih dari $_wajahHilangDetik detik");
        _absenceViolationActive = true;
      }

      _multiFaceViolationActive = false;
      _wrongPoseViolationActive = false;
      _wrongPoseSince = null;
      return;
    }

    _lastFaceSeenAt = now;
    _absenceViolationActive = false;

    if (faces.length > 1) {
      _setStatus("Terdeteksi ${faces.length} wajah");

      if (!_multiFaceViolationActive) {
        _registerViolation("Lebih dari 1 wajah terdeteksi");
        _multiFaceViolationActive = true;
      }

      _wrongPoseViolationActive = false;
      _wrongPoseSince = null;
      return;
    }

    _multiFaceViolationActive = false;

    final face = faces.first;
    final pitch = (face.headEulerAngleX ?? 0).abs();
    final yaw = (face.headEulerAngleY ?? 0).abs();
    final roll = (face.headEulerAngleZ ?? 0).abs();

    final wrongPose = pitch > _maxPitch || yaw > _maxYaw || roll > _maxRoll;

    if (wrongPose) {
      _setStatus("Arah kepala tidak wajar");

      _wrongPoseSince ??= now;

      if (!_wrongPoseViolationActive &&
          now.difference(_wrongPoseSince!).inSeconds >= _poseSalahDetik) {
        _registerViolation("Kepala menoleh / menunduk terlalu lama");
        _wrongPoseViolationActive = true;
      }
    } else {
      _setStatus("Pengawasan aktif • wajah normal");
      _wrongPoseSince = null;
      _wrongPoseViolationActive = false;
    }
  }

  void _setStatus(String value) {
    if (!mounted) return;
    if (statusPengawas == value) return;

    setState(() {
      statusPengawas = value;
    });
  }

  void _registerViolation(String reason) {
    if (!mounted || _hasFinished) return;

    final detail = "${_jamSekarang()} - $reason";

    setState(() {
      pelanggaran++;
      detailPelanggaran.add(detail);
    });

    debugPrint("PELANGGARAN: $detail");
  }

  @override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  if (_hasFinished) return;

  /// ✅ TAMBAHAN INI (UNTUK NOTIFIKASI)
  if (state == AppLifecycleState.inactive) {
    await Future.delayed(const Duration(seconds: 2));

    if (_hasFinished) return;

    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      _registerViolation("Membuka notifikasi / keluar aplikasi");
      await _finish(autoSubmit: true);
      return;
    }
  }

  /// 🔴 YANG SUDAH ADA (TETAP DIPAKAI)
  if (state == AppLifecycleState.paused) {
    final now = DateTime.now();

    if (_lastAppViolationAt == null ||
        now.difference(_lastAppViolationAt!).inSeconds >= 2) {
      _registerViolation("Keluar / minimize aplikasi");
      _lastAppViolationAt = now;
    }

    try {
      await _cam?.pausePreview();
    } catch (e) {
      debugPrint("ERROR PAUSE PREVIEW: $e");
    }

    await _finish(autoSubmit: true);
  }

  /// 🔵 RESUME (TETAP)
  else if (state == AppLifecycleState.resumed) {
    if (_hasFinished) return;

    try {
      await _cam?.resumePreview();
    } catch (e) {
      debugPrint("ERROR RESUME PREVIEW: $e");
    }

    if (_cam != null &&
        _cam!.value.isInitialized &&
        !_cam!.value.isStreamingImages) {
      await _startImageStream();
    }
  }
}

  Future<void> _finish({
    bool autoSubmit = false,
  }) async {
    if (_hasFinished) return;

    _hasFinished = true;
    _timer?.cancel();

    await _stopImageStream();

    final nilaiAkhir = hitungNilai();
    final jumlahBenar = hitungBenar();
    final nama = widget.userData["nama"]?.toString() ?? "";
    final kelas = widget.userData["kelas"]?.toString() ?? "";
    final totalSoal = soalList.length;
    final totalPelanggaran = pelanggaran;
    final detailList = List<String>.from(detailPelanggaran);

    await simpanHasil(
      nilaiAkhir: nilaiAkhir,
      jumlahBenar: jumlahBenar,
    );

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (autoSubmit) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const CheatPage(),
          ),
          (route) => false,
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => SelesaiPage(
  nama: nama,
  kelas: kelas,
  nilaiAkhir: nilaiAkhir,
),
        ),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    FlutterWindowManagerPlus.clearFlags(
      FlutterWindowManagerPlus.FLAG_SECURE,
    ).catchError((_) {});

    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _faceDetector.close();
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (soalList.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Soal tidak tersedia"),
        ),
      );
    }

    if (_cameraError != null) {
      return Scaffold(
        body: Center(
          child: Text(_cameraError!),
        ),
      );
    }

    if (_cam == null || !_cam!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: Text("Kamera belum siap"),
        ),
      );
    }

    return PopScope(
  canPop: false,
  onPopInvoked: (didPop) async {
    if (didPop || _hasFinished) return;

    _registerViolation("Menekan tombol kembali");
    await _finish(autoSubmit: true);
  },
  child: ExamUI(
    cam: _cam!,
    pelanggaran: pelanggaran,
    jawaban: jawabanList[currentIndex],
    jawabanList: jawabanList,
    soalList: soalList,
    currentIndex: currentIndex,
    totalSoal: soalList.length,
    namaUser: widget.userData["nama"]?.toString() ?? "",
    waktuTersisa: formatWaktu(sisaDetik),
    statusPengawas: statusPengawas,
    onPick: (v) {
      if (_hasFinished) return;
      setState(() {
        jawabanList[currentIndex] = v;
      });
    },
    onNext: () {
      if (_hasFinished) return;
      nextSoal();
    },
    onPrev: () {
      if (_hasFinished) return;
      prevSoal();
    },
    onJumpToQuestion: (idx) {
      if (_hasFinished) return;
      jumpToSoal(idx);
    },
    onFinish: () => _finish(),
  ),
);
  }
}

