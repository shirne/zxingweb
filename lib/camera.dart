import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zxing_lib/zxing.dart';
import 'package:camera/camera.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../models/utils.dart';
import '../widgets/cupertino_icon_button.dart';

class CameraPage extends StatefulWidget {
  const CameraPage();
  @override
  State<StatefulWidget> createState() => _CameraPageState();
}

const _videoConstraints = VideoConstraints(
  facingMode: FacingMode(
    type: CameraType.environment,
    constrain: Constrain.exact,
  ),
  width: VideoSize(ideal: 1920, maximum: 1920),
  height: VideoSize(ideal: 1080, maximum: 1080),
);

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  bool _detectedCamera = false;
  bool _isCameraAvailable = false;
  bool isDetecting = false;
  late List<MediaDeviceInfo> _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCameraController();
  }

  Future<void> _initializeCameraController() async {
    _cameras = await availableCameras();

    if (_cameras.length < 1) {
      setState(() {
        _detectedCamera = true;
      });
      return;
    }
    _controller = CameraController(
      options: CameraOptions(
        audio: AudioConstraints(enabled: false),
        deviceId: _cameras[0].deviceId,
      ),
    );
    await _controller.initialize();
    setState(() {
      _isCameraAvailable = true;
      _detectedCamera = true;
    });
    await _play();
  }

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
    setState(() {
      isDetecting = true;
    });

    CameraImage pic = await _controller.takePicture();
    Uint8List imageData = Uint8List.fromList(utf8.encode(pic.data));
    ui.Image image =
        (await (await ui.instantiateImageCodec(imageData)).getNextFrame())
            .image;

    List<Result>? results;
    String error = '';
    try {
      results = await decodeImageInIsolate(
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
              .buffer
              .asUint8List(),
          pic.width,
          pic.height);
    } catch (err) {
      error = ":${err.toString()}";
    }
    if (!mounted) return;
    if (results != null) {
      Navigator.of(context).pushNamed('/result', arguments: results);
    } else {
      MyDialog.of(context).toast('detected nothing $error');
    }
    setState(() {
      isDetecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Camera'),
      ),
      child: Center(
        child: !_isCameraAvailable
            ? Text(_detectedCamera ? 'Not detected cameras' : 'Detecting')
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
                        icon: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isDetecting) CupertinoActivityIndicator(),
                            Icon(CupertinoIcons.qrcode_viewfinder),
                          ],
                        ),
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
