import 'package:flutter/foundation.dart';

@immutable
class Evaluation {
  const Evaluation({
    required this.id,
    required this.featureId,
    required this.featureVersion,
    required this.userId,
    required this.variationId,
    required this.variationValue,
    required this.reason,
  });

  final String id;
  final String featureId;
  final int featureVersion;
  final String userId;
  final String variationId;
  final String variationValue;
  final int reason;

  @override
  bool operator ==(Object other) =>
      other is Evaluation &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      featureId == other.featureId &&
      featureVersion == other.featureVersion &&
      userId == other.userId &&
      variationId == other.variationId &&
      variationValue == other.variationValue &&
      reason == other.reason;

  @override
  int get hashCode =>
      id.hashCode ^
      featureId.hashCode ^
      featureVersion.hashCode ^
      userId.hashCode ^
      variationId.hashCode ^
      variationValue.hashCode ^
      reason.hashCode;

  @override
  String toString() {
    return 'Evaluation{id: $id, featureId: $featureId, '
        'featureVersion: $featureVersion, userId: $userId, '
        'variationId: $variationId, variationValue: $variationValue, '
        'reason: $reason}';
  }
}
