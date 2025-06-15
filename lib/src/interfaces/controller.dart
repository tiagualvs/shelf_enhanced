import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../common/handler_when_has_middleware.dart';
import '../common/method.dart';
import '../common/not_found_handler.dart';

abstract class Controller {
  final String prefix;
  final Router _router;

  Controller(this.prefix) : _router = Router(notFoundHandler: notFoundHandler()) {
    setup(Register(_router));
  }

  void setup(Register register);

  Handler get handler {
    return _router.call;
  }
}

class Register {
  final Router router;

  const Register(this.router);

  void add(Method method, String route, Function handler, {Middleware? middleware}) async {
    if (middleware != null) {
      final newHandler = await handlerWhenHasMiddleware(route, handler);

      return router.add(method.verb, route, middleware(newHandler));
    } else {
      return router.add(method.verb, route, handler);
    }
  }

  void get(String route, Function handler, {Middleware? middleware}) =>
      add(Get(), route, handler, middleware: middleware);

  void post(String route, Function handler, {Middleware? middleware}) =>
      add(Post(), route, handler, middleware: middleware);

  void put(String route, Function handler, {Middleware? middleware}) =>
      add(Put(), route, handler, middleware: middleware);

  void delete(String route, Function handler, {Middleware? middleware}) =>
      add(Delete(), route, handler, middleware: middleware);

  void patch(String route, Function handler, {Middleware? middleware}) =>
      add(Patch(), route, handler, middleware: middleware);

  void head(String route, Function handler, {Middleware? middleware}) =>
      add(Head(), route, handler, middleware: middleware);

  void options(String route, Function handler, {Middleware? middleware}) =>
      add(Options(), route, handler, middleware: middleware);

  void trace(String route, Function handler, {Middleware? middleware}) =>
      add(Trace(), route, handler, middleware: middleware);
}
