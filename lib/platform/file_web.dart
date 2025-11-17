// Web implementation: wrapper around web file-like objects (XFile or html.File)
import 'dart:async';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;

class File {
  final dynamic _data;

  File([this._data]);

  /// Path or name fallback
  String get path {
    try {
      if (_data == null) return '';
      if (_data is XFile) return (_data as XFile).path;
      if (_data is html.File) return (_data as html.File).name;
      return _data.toString();
    } catch (_) {
      return '';
    }
  }

  /// Read bytes from underlying object. Supports XFile and dart:html File.
  Future<Uint8List> readAsBytes() async {
    if (_data == null) return Uint8List(0);

    if (_data is XFile) {
      return await (_data as XFile).readAsBytes();
    }

    if (_data is html.File) {
      final completer = Completer<Uint8List>();
      final reader = html.FileReader();
      reader.onLoad.listen((event) {
        final result = reader.result;
        if (result is ByteBuffer) {
          completer.complete(Uint8List.view(result));
        } else if (result is List<int>) {
          completer.complete(Uint8List.fromList(result));
        } else {
          completer.completeError('Unsupported read result: ${result.runtimeType}');
        }
      });
      reader.onError.listen((event) => completer.completeError(reader.error ?? 'File read error'));
      reader.readAsArrayBuffer(_data as html.File);
      return completer.future;
    }

    // If underlying data is already bytes
    if (_data is Uint8List) return _data as Uint8List;

    // Fallback: try to convert to bytes from string (not ideal)
    final s = _data.toString();
    return Uint8List.fromList(s.codeUnits);
  }
}
