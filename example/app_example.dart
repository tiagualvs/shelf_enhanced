import 'package:shelf_enhanced/shelf_enhanced.dart';

void main() async {
  final app = createApp(prefix: '/api/v1');

  app.get('/', (_) => Response(200, body: 'Hello, World!'));

  app.controller(UsersController());

  app.middleware(logRequests());

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
    final body = await request.readFormData();

    if (body.isEmpty) {
      return Json.badRequest(
        body: {
          'error': 'File is required',
        },
      );
    }

    return Json.ok(
      body: {
        'file': {
          'filename': (body['file'] as FileField).filename,
          'mime_type': (body['file'] as FileField).mimeType,
          'size': '${((body['file'] as FileField).value.lengthInBytes / 1024 / 1024).toStringAsFixed(2)} MB',
        },
      },
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
