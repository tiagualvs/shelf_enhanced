library shelf_enhanced;

import 'src/app.dart';
import 'src/interfaces/app.dart';

export 'package:shelf/shelf.dart';
export 'package:shelf_cors_headers/shelf_cors_headers.dart';
export 'package:shelf_proxy/shelf_proxy.dart';
export 'package:shelf_static/shelf_static.dart';

export 'src/app.dart';
export 'src/common/field.dart';
export 'src/common/json.dart';
export 'src/common/method.dart';
export 'src/common/regexes.dart';
export 'src/common/request_extension.dart';
export 'src/interfaces/controller.dart';

App createApp({String? prefix}) => AppImp(prefix: prefix);
