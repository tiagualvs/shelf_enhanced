import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_enhanced/src/common/field.dart';
import 'package:shelf_multipart/shelf_multipart.dart' hide FormData;

import 'form.dart';

extension RequestExtension on Request {
  /// Reads the body as a form data value from the context of the [Request].
  Future<FormData> readFormData() async {
    try {
      final contentType = headers['content-type'];

      final contetnLength = headers['content-length'];

      if (contetnLength == null) {
        return FormData.empty();
      }

      if (int.tryParse(contetnLength) == null) {
        return FormData.empty();
      }

      if (int.parse(contetnLength) == 0) {
        return FormData.empty();
      }

      if (contentType == null || !contentType.contains('multipart/form-data')) {
        return FormData.empty();
      }

      if (formData() case var form?) {
        final fields = <Field>[];

        await for (final formData in form.formData) {
          final match = RegExp(r'^(\w+)(?:\[(\d+)\])?$').firstMatch(formData.name);
          final name = match?.group(1) ?? formData.name;
          final isArray = match?.group(2) != null;
          if (formData.filename != null) {
            if (isArray) {
              final index = fields.indexWhere((f) => f.name == name);

              if (index == -1) {
                fields.add(Field.list(name, [await Field.fileFromForm(formData)]));
              } else {
                fields[index] = switch (fields[index]) {
                  TextField t => Field.list(name, [t, await Field.fileFromForm(formData)]),
                  FileField f => Field.list(name, [f, await Field.fileFromForm(formData)]),
                  ListField l => Field.list(name, [...l.value, await Field.fileFromForm(formData)]),
                };
              }
            } else {
              fields.add(await Field.fileFromForm(formData));
            }
          } else {
            if (isArray) {
              final index = fields.indexWhere((f) => f.name == name);

              if (index == -1) {
                fields.add(Field.list(name, [await Field.textFromForm(formData)]));
              } else {
                fields[index] = switch (fields[index]) {
                  TextField t => Field.list(name, [t, await Field.textFromForm(formData)]),
                  FileField f => Field.list(name, [f, await Field.textFromForm(formData)]),
                  ListField l => Field.list(name, [...l.value, await Field.textFromForm(formData)]),
                };
              }
            } else {
              fields.add(await Field.textFromForm(formData));
            }
          }
        }

        return FormData(int.parse(contetnLength), fields);
      } else {
        return FormData.empty();
      }
    } catch (_) {
      return FormData.empty();
    }
  }

  /// Reads the body as a JSON value from the context of the [Request].
  Future<Map<String, dynamic>> readJson() async {
    try {
      final contentType = headers['content-type'];

      final contetnLength = headers['content-length'];

      if (contetnLength == null) {
        return {};
      }

      if (int.tryParse(contetnLength) == null) {
        return {};
      }

      if (int.parse(contetnLength) == 0) {
        return {};
      }

      if (contentType == null || !contentType.contains('application/json')) {
        return {};
      }

      return json.decode(await readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// Sets a value to the context of the [Request] and returns a copy of [Request].
  Request set<T>(String key, T value) {
    return change(context: {key: value});
  }

  /// Gets a value from the context of the [Request].
  T? get<T>(String key) {
    if (!context.containsKey(key)) return null;
    final value = context[key];
    if (value is! T) return null;
    return context[key] as T;
  }
}
