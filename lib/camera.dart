import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/utils.dart';
import '../widgets/cupertino_icon_button.dart';

class CameraPage extends StatefulWidget {
  const CameraPage();
  @override
  State<StatefulWidget> createState() => _CameraPageState();
}

const _videoConstraints = VideoConstraints(
  facingMode: FacingMode(
    type: CameraType.rear,
    constrain: Constrain.ideal,
  ),
  width: VideoSize(ideal: 1920, maximum: 1920),
  height: VideoSize(ideal: 1080, maximum: 1080),
);

class _CameraPageState extends State<CameraPage> {
  final _controller = CameraController(
    options: const CameraOptions(
      audio: AudioConstraints(enabled: false),
      video: _videoConstraints,
    ),
  );
  bool detectedCamera = false;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCameraController();
  }

  Future<void> _initializeCameraController() async {
    await _controller.initialize();
    await _play();
  }

  bool get _isCameraAvailable =>
      _controller.value.status == CameraStatus.available;

  Future<void> _play() async {
    if (!_isCameraAvailable) return;
    return _controller.play();
  }

  Future<void> _stop() async {
    if (!_isCameraAvailable) return;
    return _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  onCameraView() async {
    if (isDetecting) return;
    isDetecting = true;
    try {
      CameraImage pic = await _controller.takePicture();

      var results = await decodeImageInIsolate(
          Uint8List.fromList(utf8.encode(pic.data)), pic.width, pic.height);

      if (results != null) {
        if (!mounted) return;
        Navigator.of(context).pushNamed('/result', arguments: results);
      } else {
        print('detected nothing');
      }
    } catch (_) {
      print('can\'t take picture from camera');
    }
    isDetecting = false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Camera'),
      ),
      child: Center(
        child: _isCameraAvailable
            ? Text(detectedCamera ? 'Not detected cameras' : 'Detecting')
            : Camera(
                controller: _controller,
                placeholder: (_) => const SizedBox(),
                preview: (context, preview) => Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: preview,
                    ),
                    Align(
                      alignment: Alignment(0, 0.7),
                      child: CupertinoIconButton(
                        icon: Icon(CupertinoIcons.qrcode_viewfinder),
                        onPressed: onCameraView,
                      ),
                    ),
                  ],
                ),
                error: (context, error) => Text(error.description),
              ),
      ),
    );
  }
}
