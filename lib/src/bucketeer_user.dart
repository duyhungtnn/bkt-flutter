import 'package:flutter/foundation.dart';

@immutable
class BucketeerUser {
  const BucketeerUser({
    required this.id,
    required this.data,
  });

  final String id;
  final Map<String, String> data;

  @override
  bool operator ==(Object other) =>
      other is BucketeerUser &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      mapEquals(data, other.data);

  @override
  int get hashCode => id.hashCode ^ data.hashCode;

  @override
  String toString() {
    return 'BucketeerUser{id: $id, data: $data}';
  }
}