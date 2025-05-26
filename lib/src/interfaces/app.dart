import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_enhanced/src/common/method.dart';
import 'package:shelf_enhanced/src/interfaces/controller.dart';

abstract interface class App {
  void add(Method method, String path, Function handler);
  void get(String path, Function handler);
  void post(String path, Function handler);
  void put(String path, Function handler);
  void delete(String path, Function handler);
  void patch(String path, Function handler);
  void head(String path, Function handler);
  void options(String path, Function handler);
  void trace(String path, Function handler);
  void controller(Controller controller);
  void middleware(Middleware middleware);
  Future<HttpServer> start({Object? address, int? port});
}
