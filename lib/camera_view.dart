import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraView extends StatelessWidget {
  final CameraController cam;

  const CameraView({super.key, required this.cam});

  @override
  Widget build(BuildContext context) {
    if (!cam.value.isInitialized) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: CameraPreview(cam),
        ),
      ),
    );
  }
}