import 'package:shelf/shelf.dart';
import 'package:shelf_enhanced/src/common/json.dart';

Handler notFoundHandler() {
  return (request) => Json.notFound(
        body: {'error': 'Route not found!'},
      );
}
