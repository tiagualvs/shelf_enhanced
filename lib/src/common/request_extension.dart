import 'dart:convert';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';

extension RequestExtension on Request {
  Future<Map<String, dynamic>> readFormData() async {
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
        final parameters = <String, dynamic>{};

        await for (final formData in form.formData) {
          final filename = formData.filename;
          final part = formData.part;
          final headers = part.headers;
          if (filename != null) {
            parameters[formData.name] = {
              'filename': filename,
              'mime_type': headers['content-type'] ?? lookupMimeType(filename) ?? 'application/octet-stream',
              'data': await part.readBytes(),
            };
          } else {
            parameters[formData.name] = await part.readString();
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
}
