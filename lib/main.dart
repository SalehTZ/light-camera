import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:video_player/video_player.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _cameraController;
  bool _isRecording = false;
  String? _videoPath;
  VideoPlayerController? _videoPlayerController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.max);
    _cameraController
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        })
        .catchError((Object e) {
          if (e is CameraException) {
            // Handle camera errors here.
            debugPrint(e.toString());
          }
        });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _startVideoRecording() async {
    if (!_cameraController.value.isInitialized) {
      return;
    }

    setState(() {
      _isRecording = true;
    });

    try {
      await _cameraController.startVideoRecording();
    } on CameraException catch (e) {
      debugPrint(e.toString());
      return;
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!_cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile file = await _cameraController.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoPath = file.path;
      });
      _initVideoPlayer();
    } on CameraException catch (e) {
      debugPrint(e.toString());
      return;
    }
  }

  Future<void> _saveVideo() async {
    if (_videoPath == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await Gal.putVideo(_videoPath!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video saved to gallery!')),
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _initVideoPlayer() {
    if (_videoPath == null) return;
    _videoPlayerController = VideoPlayerController.file(File(_videoPath!))
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController!.play();
      });
  }

  void _retakeVideo() {
    setState(() {
      _videoPath = null;
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Camera Test')),
        body: Center(
          child: _videoPath != null
              ? _videoPlayerWidget()
              : _cameraPreviewWidget(),
        ),
        floatingActionButton: _isSaving
            ? null
            : FloatingActionButton(
                onPressed: () {
                  if (_videoPath != null) {
                    _retakeVideo();
                  } else {
                    if (_isRecording) {
                      _stopVideoRecording();
                    } else {
                      _startVideoRecording();
                    }
                  }
                },
                child: Icon(
                  _videoPath != null
                      ? Icons.camera_alt
                      : _isRecording
                          ? Icons.stop
                          : Icons.videocam,
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: _videoPath != null && !_isSaving
            ? BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveVideo,
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(_cameraController);
  }

  Widget _videoPlayerWidget() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      child: VideoPlayer(_videoPlayerController!),
    );
  }
}
