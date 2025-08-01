import 'dart:async';

import 'package:shelf_enhanced/shelf_enhanced.dart';

abstract class ExceptionHandler<T> {
  FutureOr<Response> handler(T exception);
  bool isException(Exception exception) => exception is T;
}
