import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_enhanced/src/common/method.dart';
import 'package:shelf_enhanced/src/interfaces/controller.dart';

abstract interface class App {
  void add(Method method, String path, Function handler, {Middleware? middleware});
  void get(String path, Function handler, {Middleware? middleware});
  void post(String path, Function handler, {Middleware? middleware});
  void put(String path, Function handler, {Middleware? middleware});
  void delete(String path, Function handler, {Middleware? middleware});
  void patch(String path, Function handler, {Middleware? middleware});
  void head(String path, Function handler, {Middleware? middleware});
  void options(String path, Function handler, {Middleware? middleware});
  void trace(String path, Function handler, {Middleware? middleware});
  void controller(Controller controller, {Middleware? middleware});
  void middleware(Middleware middleware);
  Future<HttpServer> start({Object? address, int? port});
}
