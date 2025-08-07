import 'field.dart';

class FormData {
  final int contentLength;
  final List<Field> fields;

  const FormData(this.contentLength, this.fields);

  const FormData.empty() : this(0, const []);

  bool isEmpty() => contentLength == 0;

  bool isNotEmpty() => contentLength > 0;

  bool contains<T extends Field>(String name) {
    return fields.whereType<T>().any((f) => f.name == name);
  }

  T? get<T extends Field>(String name) {
    if (!contains<T>(name)) return null;
    return fields.whereType<T>().firstWhere((f) => f.name == name);
  }

  Map<String, dynamic> toJson() {
    return {
      'contentLength': contentLength,
      'fields': fields.map((f) => f.toJson()).toList(),
    };
  }
}
