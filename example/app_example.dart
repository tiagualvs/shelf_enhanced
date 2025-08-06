import 'dart:async';

import 'package:shelf_enhanced/shelf_enhanced.dart';

void main() async {
  final app = createApp(prefix: '/api/v1');

  app.add(
    Get(),
    '/message/<message>',
    (Request req, String message) {
      if (message == 'ABACATE') throw BadRequestException('ABACATE NAO PODE');
      if (message == 'TREM') throw NotFoundException('TREM NAO PODE');
      if (message == 'CURUPIRA') throw Exception('CURUPIRA NAO PODE');
      return Json(200, body: {'Hello': message});
    },
  );

  app.controller(UsersController());

  app.middleware(logRequests());

  app.exceptionHandler<MyException>(MyExceptionHandler());

  app.exceptionHandler<Exception>(DefaultExceptionHandler());

  final server = await app.start();

  print('Listening on http://${server.address.host}:${server.port}');
}

class UsersController extends Controller {
  final List<User> _users = [];

  UsersController() : super('/users');

  @override
  void setup(Register register) {
    register.post('/', createOne);
    register.get('/', findMany);
    register.get(r'/<userId|[\d]+>', findOne);
    register.post('/upload', upload);
  }

  Future<Response> upload(Request request) async {
    final form = await request.readFormData();

    if (form.isEmpty()) {
      return Json.badRequest(
        body: {
          'error': 'File is required',
        },
      );
    }

    return Json.ok(
      body: form.fields.map((f) {
        return switch (f) {
          TextField f => f.toString(),
          FileField f => f.toString(),
          ListField l => l.toString(),
        };
      }).toList(),
    );
  }

  Future<Json> createOne(Request request) async {
    final body = await request.readJson();

    if (!body.containsKey('name')) {
      return Json.badRequest(
        body: {
          'error': 'Name is required',
        },
      );
    }

    if (!body.containsKey('age')) {
      return Json.badRequest(
        body: {
          'error': 'Age is required',
        },
      );
    }

    final user = User(
      id: _users.length + 1,
      name: body['name'] as String,
      age: body['age'] as int,
    );

    _users.add(user);

    return Json.ok(
      body: {
        'user': {
          'name': user.name,
          'age': user.age,
        }
      },
    );
  }

  Future<Json> findMany(Request request) async {
    return Json.ok(
      body: {
        'users': List.from(
          _users.map(
            (user) {
              return {
                'name': user.name,
                'age': user.age,
              };
            },
          ),
        ),
      },
    );
  }

  Future<Response> findOne(Request request, String userId) async {
    final index = _users.indexWhere((user) => user.id == int.parse(userId));

    if (index == -1) {
      return Json.notFound(
        body: {
          'error': 'User not found',
        },
      );
    }

    return Json.ok(
      body: {
        'user': {
          'name': _users[index].name,
          'age': _users[index].age,
        }
      },
    );
  }
}

class User {
  final int id;
  final String name;
  final int age;

  const User({required this.id, required this.name, required this.age});
}

abstract class MyException implements Exception {
  final int statusCode;
  final String error;

  const MyException(this.statusCode, this.error);

  Response toResponse() => Json(statusCode, body: {'error': error});
}

class BadRequestException extends MyException {
  const BadRequestException(String error) : super(400, error);
}

class NotFoundException extends MyException {
  const NotFoundException(String error) : super(404, error);
}

class MyExceptionHandler extends ExceptionHandler<MyException> {
  @override
  FutureOr<Response> handler(MyException exception) {
    return exception.toResponse();
  }
}

class DefaultExceptionHandler extends ExceptionHandler<Exception> {
  @override
  FutureOr<Response> handler(Exception exception) {
    return Json.internalServerError(body: {'error': exception.toString()});
  }
}
