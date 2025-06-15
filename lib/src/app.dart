import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_enhanced/shelf_enhanced.dart';
import 'package:shelf_router/shelf_router.dart';

import 'common/handler_when_has_middleware.dart';
import 'common/not_found_handler.dart';
import 'interfaces/app.dart';

class AppImp implements App {
  final String? prefix;
  final Router _router = Router(notFoundHandler: notFoundHandler());
  final List<Middleware> _middlewares = [];

  AppImp({this.prefix});

  @override
  void add(Method method, String path, Function handler, {Middleware? middleware}) async {
    if (!pathRegex.hasMatch(path)) {
      throw ArgumentError('Invalid path');
    }

    if (prefix == null) {
      return _router.add(method.verb, path, handler);
    }

    if (!pathRegex.hasMatch(prefix!)) {
      throw ArgumentError('Invalid prefix');
    }

    final joinedPath = '$prefix$path';

    final normalizedPath = switch (joinedPath.endsWith('/')) {
      true => joinedPath.substring(0, joinedPath.length - 1),
      false => joinedPath,
    };

    if (middleware != null) {
      final newHandler = await handlerWhenHasMiddleware(normalizedPath, handler);

      return _router.add(method.verb, normalizedPath, middleware(newHandler));
    } else {
      return _router.add(method.verb, normalizedPath, handler);
    }
  }

  @override
  void delete(String path, Function handler, {Middleware? middleware}) {
    return add(Delete(), path, handler, middleware: middleware);
  }

  @override
  void get(String path, Function handler, {Middleware? middleware}) {
    return add(Get(), path, handler, middleware: middleware);
  }

  @override
  void head(String path, Function handler, {Middleware? middleware}) {
    return add(Head(), path, handler, middleware: middleware);
  }

  @override
  void options(String path, Function handler, {Middleware? middleware}) {
    return add(Options(), path, handler, middleware: middleware);
  }

  @override
  void patch(String path, Function handler, {Middleware? middleware}) {
    return add(Patch(), path, handler, middleware: middleware);
  }

  @override
  void post(String path, Function handler, {Middleware? middleware}) {
    return add(Post(), path, handler, middleware: middleware);
  }

  @override
  void put(String path, Function handler, {Middleware? middleware}) {
    return add(Put(), path, handler, middleware: middleware);
  }

  @override
  void trace(String path, Function handler, {Middleware? middleware}) {
    return add(Trace(), path, handler, middleware: middleware);
  }

  @override
  void controller(Controller controller, {Middleware? middleware}) async {
    if (prefix == null) {
      return _router.mount(controller.prefix, controller.handler);
    }

    if (!pathRegex.hasMatch(prefix!)) {
      throw ArgumentError('Invalid prefix');
    }

    final joinedPath = '$prefix${controller.prefix}';

    final normalizedPath = switch (joinedPath.endsWith('/')) {
      true => joinedPath.substring(0, joinedPath.length - 1),
      false => joinedPath,
    };

    if (middleware != null) {
      final newHandler = await handlerWhenHasMiddleware(normalizedPath, controller.handler);

      return _router.mount(normalizedPath, middleware(newHandler));
    } else {
      return _router.mount(normalizedPath, controller.handler);
    }
  }

  @override
  void middleware(Middleware middleware) {
    return _middlewares.add(middleware);
  }

  @override
  Future<HttpServer> start({Object? address, int? port}) async {
    final pipeline = _middlewares.fold(Pipeline(), (p, m) => p.addMiddleware(m));

    final handler = pipeline.addHandler(_router.call);

    return await io.serve(handler.call, address ?? '0.0.0.0', port ?? 8080);
  }
}
