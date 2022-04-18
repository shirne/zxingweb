import 'dart:typed_data';

import 'package:buffer_image/buffer_image.dart';
import 'package:zxing_lib/zxing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import '../models/utils.dart';
import 'generator/index.dart' as generator;
import 'result.dart';
import 'camera.dart';

class IndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/camera':
            builder = (BuildContext context) => const CameraPage();
            break;
          case '/generator':
            builder = (BuildContext context) => const generator.IndexPage();
            break;
          case '/result':
            builder = (BuildContext context) =>
                ResultPage(settings.arguments as List<Result>);
            break;
          default:
            builder = (BuildContext context) => const _IndexPage();
        }
        return CupertinoPageRoute(builder: builder, settings: settings);
      },
    );
  }
}

class _IndexPage extends StatefulWidget {
  const _IndexPage();
  @override
  State<StatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends State<_IndexPage> {
  bool isReading = false;
  void openCamera() {
    Navigator.of(context).pushNamed('/camera');
  }

  void openGenerator() {
    Navigator.of(context).pushNamed('/generator');
  }

  void openFile() async {
    Uint8List? fileData = await _pickFile();
    if (fileData != null) {
      BufferImage? image = await BufferImage.fromFile(fileData);
      if (image == null) {
        alert(context, 'Can\'t read the image');
        return;
      }
      setState(() {
        isReading = true;
      });

      /// 解码大图会耗费太多时间，这里直接把图片缩小再传过去
      if (image.width > 1000) {
        image.scaleDown(image.width / 1000);
      }
      var results =
          await decodeImageInIsolate(image.buffer, image.width, image.height);
      setState(() {
        isReading = false;
      });
      if (results != null) {
        Navigator.of(context).pushNamed('/result', arguments: results);
      } else {
        alert(context, 'Can\'t detect barcodes or qrcodes');
      }
    } else {
      print('not pick any file');
    }
  }

  isoEntry(BufferImage image) {}

  Future<Uint8List?> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);

    if (result != null && result.count > 0) {
      return result.files.first.bytes;
    } else {
      // User canceled the picker
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Scanner'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            CupertinoButton.filled(
              child: const Text('Scanner'),
              onPressed: () {
                openCamera();
              },
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton.filled(
              child: const Text('Generator'),
              onPressed: () {
                openGenerator();
              },
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton.filled(
              child: SizedBox(
                width: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isReading) CupertinoActivityIndicator(),
                    const Text('Image discern')
                  ],
                ),
              ),
              onPressed: () {
                openFile();
              },
            ),
            SizedBox(
              height: 10,
            ),
            Text('Multi decode mode'),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
