import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraView extends StatelessWidget {
  final CameraController cam;
  final double height;
  final double width;

  const CameraView({
    super.key,
    required this.cam,
    this.height = 180,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    if (!cam.value.isInitialized) {
      return SizedBox(
        height: height,
        width: width,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: height,
          width: width,
          child: CameraPreview(cam),
        ),
      ),
    );
  }
}