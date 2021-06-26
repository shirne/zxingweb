import 'package:flutter/cupertino.dart';
import 'package:zxing_lib/client.dart';

import '../widgets/cupertino_list_tile.dart';
import '../widgets/list_tile_group.dart';

class TextForm extends StatefulWidget {
  final TextParsedResult result;

  const TextForm({Key? key, required this.result}) : super(key: key);

  @override
  State<TextForm> createState() => _TextFormState();
}

class _TextFormState extends State<TextForm> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.result.text);
    _controller.addListener(() {
      widget.result.text = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTileGroup(
      children: [
        CupertinoListTile(
          title: Text('文本内容'),
        ),
        CupertinoTextField(
          maxLines: 5,
          controller: _controller,
        )
      ],
    );
  }
}
