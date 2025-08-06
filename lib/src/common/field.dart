import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:shelf_multipart/shelf_multipart.dart';

sealed class Field {
  final String name;
  const Field(this.name);
  const factory Field.text(String name, String value) = TextField._;
  const factory Field.file(String name, String filename, String mimeType, Uint8List value) = FileField._;
  const factory Field.list(String name, List<Field> value) = ListField._;

  static Future<Field> textFromForm(FormData form) async {
    final name = RegExp(r'^(\w+)(?:\[(\d+)\])?$').firstMatch(form.name)?.group(1) ?? form.name;
    return TextField._(name, await form.part.readString());
  }

  static Future<Field> fileFromForm(FormData form) async {
    final name = RegExp(r'^(\w+)(?:\[(\d+)\])?$').firstMatch(form.name)?.group(1) ?? form.name;
    return FileField._(
      name,
      form.filename ?? '',
      form.part.headers['content-type'] ?? lookupMimeType(form.filename ?? '') ?? 'application/octet-stream',
      await form.part.readBytes(),
    );
  }

  @override
  String toString() {
    return switch (this) {
      TextField t => 'TextField(name: ${t.name}, value: ${t.value})',
      FileField f =>
        'FileField(name: ${f.name}, filename: ${f.filename}, mimeType: ${f.mimeType}, lengthInBytes: ${f.value.length})',
      ListField l => 'ListField(name: ${l.name}, value: ${l.value.join(', ')})',
    };
  }
}

final class TextField extends Field {
  final String value;
  const TextField._(super.name, this.value);

  int toInt() {
    try {
      return int.parse(value);
    } catch (_) {
      return 0;
    }
  }

  double toDouble() {
    try {
      return double.parse(value);
    } catch (_) {
      return 0.0;
    }
  }

  bool toBool() {
    try {
      return bool.parse(value);
    } catch (_) {
      return false;
    }
  }
}

final class FileField extends Field {
  final String filename;
  final String mimeType;
  final Uint8List value;
  const FileField._(super.name, this.filename, this.mimeType, this.value);
}

final class ListField extends Field {
  final List<Field> value;
  const ListField._(super.name, this.value);
}
