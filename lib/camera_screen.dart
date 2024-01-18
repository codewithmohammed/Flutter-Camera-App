import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    initializeGallery();
    initializeCamera(selectedCamera);
    super.initState();
  }

  late final String dirPath;
  late final Directory directory;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int selectedCamera = 0;
  List<File> capturedImages = [];

  initializeCamera(int cameraIndex) async {
    _controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  initializeGallery() async {
    directory = Directory('/storage/emulated/0/Cameratest');
    dirPath = directory.path;
    List<FileSystemEntity> files = directory.listSync();
    for (var file in files) {
      if (file is File) {
        capturedImages.add(File(file.path));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    if (widget.cameras.length > 1) {
                      setState(() {
                        selectedCamera = selectedCamera == 0 ? 1 : 0;
                        initializeCamera(selectedCamera);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No secondary camera found'),
                        duration: Duration(seconds: 2),
                      ));
                    }
                  },
                  icon: const Icon(Icons.switch_camera_rounded,
                      color: Colors.white),
                ),
                GestureDetector(
                  onTap: () async {
                    photoPermission();
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (capturedImages.isEmpty) return;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GalleryScreen(
                                images: capturedImages.reversed.toList())));
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      image: capturedImages.isNotEmpty
                          ? DecorationImage(
                              image: FileImage(capturedImages.last),
                              fit: BoxFit.cover)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  photoPermission() async {
    final statusPhoto = await Permission.photos.request();
    final statusStorage = await Permission.manageExternalStorage.request();
    if (statusPhoto.isGranted && statusStorage.isGranted) {
      await _initializeControllerFuture;
      var xFile = await _controller.takePicture();
      final File capturedImage = File(xFile.path);
      String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '$dirPath/$uniqueFileName';
      try {
        final File newImage = await capturedImage.copy(filePath);
        setState(() {
          capturedImages.add(newImage);
        });
      } catch (e) {
        print("Error saving image: $e");
      }
    }
    if (statusPhoto.isDenied || statusStorage.isDenied) {
      debugPrint('Permission Denied');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Cant Aceess Gallery'),
        action: SnackBarAction(
            label: 'Open App Settings',
            onPressed: () {
              openAppSettings();
            }),
      ));
    }
    if (statusPhoto.isPermanentlyDenied || statusStorage.isDenied) {
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
    if (statusPhoto.isRestricted || statusStorage.isRestricted) {
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
    if (statusPhoto.isPermanentlyDenied || statusStorage.isPermanentlyDenied) {
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
