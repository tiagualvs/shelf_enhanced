library shelf_enhanced;

import 'src/app.dart';
import 'src/interfaces/app.dart';

export 'package:shelf/shelf.dart';
export 'package:shelf_proxy/shelf_proxy.dart';

export 'src/app.dart';
export 'src/common/field.dart';
export 'src/common/json.dart';
export 'src/common/method.dart';
export 'src/common/regexes.dart';
export 'src/common/request_extension.dart';
export 'src/interfaces/controller.dart';
export 'src/interfaces/exception_handler.dart';

App createApp({String? prefix}) => AppImp(prefix: prefix);
