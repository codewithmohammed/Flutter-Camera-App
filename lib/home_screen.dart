import 'package:camera/camera.dart';
import 'package:cameratest/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({super.key, required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            await checkCameraPermission();
          },
          icon: const Icon(Icons.camera),
          label: const Text('Access Camera'),
        ),
      ),
    );
  }

  Future<void> checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return CameraScreen(cameras: widget.cameras);
      }));
    }
    if (status == PermissionStatus.denied) {
      debugPrint('Permission Denied');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Cant Aceess Camera'),
        action: SnackBarAction(
            label: 'Open App Settings',
            onPressed: () {
              openAppSettings();
            }),
      ));
    }
    if (status.isPermanentlyDenied) {
      debugPrint('Permission Permanently Denied');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Cant Aceess Camera'),
        action: SnackBarAction(
            label: 'Open App Settings',
            onPressed: () {
              openAppSettings();
            }),
      ));
    }
    if (status == PermissionStatus.restricted) {
      debugPrint('Permission Denied');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Allow us to use camera'),
        action: SnackBarAction(
            label: 'Open App Settings',
            onPressed: () {
              openAppSettings();
            }),
      ));
    }
    if (status == PermissionStatus.permanentlyDenied) {
      debugPrint('PermanentlyDenied');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Cannot use camera'),
        action: SnackBarAction(
            label: 'Open App Settings',
            onPressed: () {
              openAppSettings();
            }),
      ));
    }
  }
}
