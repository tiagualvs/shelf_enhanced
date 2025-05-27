import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:shelf_multipart/shelf_multipart.dart';

sealed class Field {
  const Field();
  const factory Field.text(String name, String value) = TextField._;
  const factory Field.file(String name, String filename, String mimeType, Uint8List value) = FileField._;

  static Future<Field> textFromForm(FormData form) async {
    return TextField._(form.name, await form.part.readString());
  }

  static Future<Field> fileFromForm(FormData form) async {
    return FileField._(
      form.name,
      form.filename ?? '',
      form.part.headers['content-type'] ?? lookupMimeType(form.filename ?? '') ?? 'application/octet-stream',
      await form.part.readBytes(),
    );
  }
}

final class TextField extends Field {
  final String name;
  final String value;
  const TextField._(this.name, this.value);
}

final class FileField extends Field {
  final String name;
  final String filename;
  final String mimeType;
  final Uint8List value;
  const FileField._(this.name, this.filename, this.mimeType, this.value);
}
