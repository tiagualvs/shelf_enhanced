import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:shelf_multipart/shelf_multipart.dart';

sealed class Field {
  final String name;
  const Field(this.name);

  Map<String, dynamic> toJson() {
    return switch (this) {
      SimpleField f => {
          'name': f.name,
          'value': f.value,
        },
      ListField f => {
          'name': f.name,
          'value': f.value.map((e) => e.toJson()).toList(),
        },
      ObjectField f => {
          'name': f.name,
          'value': f.value.entries.fold({}, (p, n) => {...p, n.key: n.value.toJson()}),
        },
    };
  }
}

final class SimpleField extends Field {
  final FieldValue value;
  const SimpleField(super.name, this.value);
}

final class ListField extends Field {
  final List<FieldValue> value;
  const ListField(super.name, this.value);
}

final class ObjectField extends Field {
  final Map<String, FieldValue> value;
  const ObjectField(super.name, this.value);
}

sealed class FieldValue {
  const FieldValue();
  const factory FieldValue.text(String value) = TextFieldValue._;
  const factory FieldValue.file(String filename, String mimeType, Uint8List value) = FileFieldValue._;

  static Future<FieldValue> textFromForm(FormData form) async {
    return TextFieldValue._(await form.part.readString());
  }

  static Future<FieldValue> fileFromForm(FormData form) async {
    return FileFieldValue._(
      form.filename ?? '',
      form.part.headers['content-type'] ?? lookupMimeType(form.filename ?? '') ?? 'application/octet-stream',
      await form.part.readBytes(),
    );
  }

  @override
  String toString() {
    return switch (this) {
      TextFieldValue t => 'TextField(value: ${t.value})',
      FileFieldValue f =>
        'FileField(filename: ${f.filename}, mimeType: ${f.mimeType}, lengthInBytes: ${f.value.length})',
    };
  }

  Map<String, dynamic> toJson() {
    return switch (this) {
      TextFieldValue t => {
          'value': t.value,
        },
      FileFieldValue f => {
          'filename': f.filename,
          'mime_type': f.mimeType,
          'value': f.value.lengthInBytes,
        },
    };
  }
}

final class TextFieldValue extends FieldValue {
  final String value;
  const TextFieldValue._(this.value);

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

final class FileFieldValue extends FieldValue {
  final String filename;
  final String mimeType;
  final Uint8List value;
  const FileFieldValue._(this.filename, this.mimeType, this.value);
}
