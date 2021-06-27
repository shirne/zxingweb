import 'package:buffer_image/buffer_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zxing_lib/client.dart';
import 'package:zxing_lib/common.dart';

import '../models/result_generator.dart';
import '../widgets/list_tile_group.dart';
import '../widgets/cupertino_list_tile.dart';
import '../models/code_type.dart';
import '../widgets/type_picker.dart';
import 'geo_form.dart';
import 'sms_form.dart';
import 'vcard_form.dart';
import 'wifi_form.dart';
import 'text_form.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  ResultGenerator result = ResultGenerator.text;
  Map<ResultGenerator, Widget> forms = {};
  Map<ResultGenerator, ParsedResult> results = {};
  CodeType codeType = CodeType.qrcode;
  int formatsIndex = 0;

  late BufferImage image;
  bool _isCreating = false;

  setResult() async {
    ResultGenerator? newResult = await pickerType<ResultGenerator>(
        context, ResultGenerator.values, result);
    if (newResult != null) {
      setState(() {
        result = newResult;
      });
    }
  }

  setStyle() async {
    CodeType? newType =
        await pickerType<CodeType>(context, CodeType.values, codeType);
    if (newType != null) {
      setState(() {
        codeType = newType;
      });
    }
  }

  formWidget(ResultGenerator type) {
    switch (type) {
      case ResultGenerator.wifi:
        return WIFIForm(
            result: results.putIfAbsent(type, () => typeResult(type))
                as WifiParsedResult);
      case ResultGenerator.vcard:
        return VCardForm(
            result: results.putIfAbsent(type, () => typeResult(type))
                as AddressBookParsedResult);
      case ResultGenerator.sms:
        return SMSForm(
            result: results.putIfAbsent(type, () => typeResult(type))
                as SMSParsedResult);
      case ResultGenerator.geo:
        return GeoForm(
            result: results.putIfAbsent(type, () => typeResult(type))
                as GeoParsedResult);
      default:
        return TextForm(
            result: results.putIfAbsent(type, () => typeResult(type))
                as TextParsedResult);
    }
  }

  typeResult(ResultGenerator type) {
    switch (type) {
      case ResultGenerator.vcard:
        return AddressBookParsedResult()
          ..addName('')
          ..addPhoneNumber('')
          ..addAddress('');
      case ResultGenerator.sms:
        return SMSParsedResult([''], [''], '', '');
      case ResultGenerator.geo:
        return GeoParsedResult(0, 0);
      case ResultGenerator.wifi:
        return WifiParsedResult('WEP', '', '');
      default:
        return TextParsedResult('');
    }
  }

  Future<BufferImage> createCode(String content,
      {int pixelSize = 0,
      Color bgColor = Colors.white,
      Color color = Colors.black}) async {
    BitMatrix matrix =
        codeType.type.encode(content, codeType.formats[formatsIndex], 500, 500);

    BufferImage image = BufferImage(matrix.width, matrix.height);
    image.drawRect(
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        bgColor);

    for (int x = 0; x < matrix.width; x++) {
      for (int y = 0; y < matrix.height; y++) {
        if (matrix.get(x, y)) {
          image.setColor(x, y, color);
        }
      }
    }
    return image;
  }

  createQrCode() async {
    if (_isCreating) return;
    _isCreating = true;
    var _result = results[result];
    if (_result != null) {
      image = await createCode(result.generator(_result));
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('barcode'),
            content: AspectRatio(
              aspectRatio: 1,
              child: Image(
                image: RgbaImage.fromBufferImage(image),
              ),
            ),
          );
        },
      );

      _isCreating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Generator'),
        trailing: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text('Create'),
          onPressed: () {
            createQrCode();
          },
        ),
      ),
      backgroundColor: Colors.black12,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            children: [
              ListTileGroup(
                children: [
                  CupertinoListTile(
                    title: Text('内容类型'),
                    onTap: () {
                      setResult();
                    },
                    trailing: Text(result.name),
                  ),
                  CupertinoListTile(
                    onTap: setStyle,
                    title: Text('码类型'),
                    trailing: Text(codeType.name),
                    isLink: true,
                  ),
                ],
              ),
              forms.putIfAbsent(result, () => formWidget(result))
            ],
          ),
        ),
      ),
    );
  }
}
