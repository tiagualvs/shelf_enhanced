import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_enhanced/src/common/field.dart';
import 'package:shelf_multipart/shelf_multipart.dart';

extension RequestExtension on Request {
  /// Reads the body as a form data value from the context of the [Request].
  Future<Map<String, Field>> readFormData() async {
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

      if (contentType == null || !contentType.contains('multipart/form-data')) {
        return {};
      }

      if (formData() case var form?) {
        final parameters = <String, Field>{};

        await for (final formData in form.formData) {
          if (formData.filename != null) {
            parameters[formData.name] = await Field.fileFromForm(formData);
          } else {
            parameters[formData.name] = await Field.textFromForm(formData);
          }
        }

        return parameters;
      } else {
        return {};
      }
    } catch (_) {
      return {};
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

  /// Gets a value from the context of the [Request].
  T? get<T>(String key) {
    if (!context.containsKey(key)) return null;
    final value = context[key];
    if (value is! T) return null;
    return context[key] as T;
  }
}
