import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../common/method.dart';
import '../common/not_found_handler.dart';

abstract class Controller {
  final String prefix;
  final Router _router;
  final List<Middleware> _middlewares;

  Controller(this.prefix)
      : _router = Router(notFoundHandler: notFoundHandler()),
        _middlewares = [] {
    setup(Register(_router, _middlewares));
  }

  void setup(Register register);

  Handler get handler {
    return _middlewares.fold(Pipeline(), (p, m) => p.addMiddleware(m)).addHandler(_router.call);
  }
}

class Register {
  final Router router;
  final List<Middleware> middlewares;

  const Register(this.router, this.middlewares);

  void middleware(Middleware middleware) {
    return middlewares.add(middleware);
  }

  void add(Method method, String route, Function handler) {
    return router.add(method.verb, route, handler);
  }

  void get(String route, Function handler) => add(Get(), route, handler);

  void post(String route, Function handler) => add(Post(), route, handler);

  void put(String route, Function handler) => add(Put(), route, handler);

  void delete(String route, Function handler) => add(Delete(), route, handler);

  void patch(String route, Function handler) => add(Patch(), route, handler);

  void head(String route, Function handler) => add(Head(), route, handler);

  void options(String route, Function handler) => add(Options(), route, handler);

  void trace(String route, Function handler) => add(Trace(), route, handler);

  void mount(String route, Handler handler) => router.mount(route, handler);
}
