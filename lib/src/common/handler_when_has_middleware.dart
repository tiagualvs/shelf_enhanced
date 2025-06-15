import 'dart:async';

import 'package:shelf/shelf.dart';

final RegExp _parser = RegExp(r'([^<]*)(?:<([^>|]+)(?:\|([^>]*))?>)?');

Future<Handler> handlerWhenHasMiddleware(String normalizedPath, Function handler) async {
  final paramNames = <String>[];
  var pattern = '';
  for (var m in _parser.allMatches(normalizedPath)) {
    pattern += RegExp.escape(m[1]!);
    if (m[2] != null) {
      paramNames.add(m[2]!);
      if (m[3] != null && !_isNoCapture(m[3]!)) {
        throw ArgumentError.value(normalizedPath, 'path', 'expression for "${m[2]}" is capturing');
      }
      pattern += '(${m[3] ?? r'[^/]+'})';
    }
  }

  final routePattern = RegExp('^$pattern\$');

  FutureOr<Response> invoke(Request request) async {
    final requestedPath = '/${request.url.path}';

    final routeMatch = routePattern.firstMatch(requestedPath);

    var paramsMapped = <String, String>{};

    if (routeMatch != null) {
      for (var i = 0; i < paramNames.length; i++) {
        paramsMapped[paramNames[i]] = routeMatch[i + 1]!;
      }
    }
    return await Function.apply(handler, [
      request,
      ...paramNames.map((n) => paramsMapped[n]),
    ]) as Response;
  }

  return invoke;
}

bool _isNoCapture(String regexp) {
  return RegExp('^(?:$regexp)|.*\$').firstMatch('')!.groupCount == 0;
}
