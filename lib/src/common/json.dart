import 'dart:convert';

import 'package:shelf/shelf.dart';

class Json extends Response {
  Json._(
    super.statusCode, {
    super.body,
    super.headers,
    super.context,
    super.encoding,
  });

  factory Json(
    int statusCode, {
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json._(
      statusCode,
      body: switch (body) {
        List<dynamic> l => json.encode(l),
        Map<String, dynamic> m => json.encode(m),
        _ => null,
      },
      headers: {
        'Content-Type': 'application/json',
        'x-powered-by': 'https://github.com/tiagualvs/shelf_enhanced.git',
        ...?headers,
      },
      context: context,
      encoding: utf8,
    );
  }

  factory Json.ok({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(200, body: body, headers: headers, context: context);
  }

  factory Json.created({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(201, body: body, headers: headers, context: context);
  }

  factory Json.noContent({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(204, body: body, headers: headers, context: context);
  }

  factory Json.badRequest({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(400, body: body, headers: headers, context: context);
  }

  factory Json.unauthorized({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(401, body: body, headers: headers, context: context);
  }

  factory Json.forbidden({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(403, body: body, headers: headers, context: context);
  }

  factory Json.notFound({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(404, body: body, headers: headers, context: context);
  }

  factory Json.methodNotAllowed({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(405, body: body, headers: headers, context: context);
  }

  factory Json.conflict({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(409, body: body, headers: headers, context: context);
  }

  factory Json.internalServerError({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(500, body: body, headers: headers, context: context);
  }

  factory Json.serviceUnavailable({
    Object? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(503, body: body, headers: headers, context: context);
  }
}
