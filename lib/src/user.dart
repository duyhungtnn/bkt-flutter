import 'package:flutter/foundation.dart';

@immutable
class BKTUser {
  const BKTUser._({
    required this.id,
    required this.data,
  });

  final String id;
  final Map<String, String> data;

  @override
  bool operator ==(Object other) =>
      other is BKTUser &&
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

class BKTUserBuilder {
  String _id = "";
  Map<String, String> _data = {};

  BKTUserBuilder id(String id) {
    _id = id;
    return this;
  }

  BKTUserBuilder data(Map<String, String> data) {
    _data = data;
    return this;
  }

  /// Create an [BKTUser] from the current configuration of the builder.
  /// Make sure you set `_id`
  /// Throws a [ArgumentError] if `id` empty.
  BKTUser build() {
    if (_id.isEmpty) {
      throw ArgumentError("id is required");
    }
    return BKTUser._(id: _id, data: _data);
  }
}