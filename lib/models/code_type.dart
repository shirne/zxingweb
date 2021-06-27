import 'package:zxing_lib/zxing.dart';
import 'package:zxing_lib/qrcode.dart' as qrcodeLib;
import 'package:zxing_lib/aztec.dart' as aztecLib;
import 'package:zxing_lib/datamatrix.dart' as datamatrixLib;
import 'package:zxing_lib/pdf417.dart' as pdf417Lib;

class CodeType {
  static final qrcode =
      CodeType(qrcodeLib.QRCodeWriter(), 'QRCode', [BarcodeFormat.QR_CODE]);
  static final aztec =
      CodeType(aztecLib.AztecWriter(), 'Aztec', [BarcodeFormat.AZTEC]);
  static final datamatrix = CodeType(datamatrixLib.DataMatrixWriter(),
      'DataMatrix', [BarcodeFormat.DATA_MATRIX]);
  static final pdf417 =
      CodeType(pdf417Lib.PDF417Writer(), 'Pdf417', [BarcodeFormat.PDF_417]);

  static final values = <CodeType>[qrcode, aztec, datamatrix, pdf417];

  final Writer type;
  final String name;

  final List<BarcodeFormat> formats;

  const CodeType(this.type, this.name, this.formats);

  @override
  String toString() {
    return name;
  }
}
