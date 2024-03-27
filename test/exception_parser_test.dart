// Write test cases
import 'package:bucketeer_flutter_client_sdk/src/exception.dart';
import 'package:bucketeer_flutter_client_sdk/src/exception_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testCases =  [
    {'input': 1, 'exceptionType': RedirectRequestException},
    {'input': 2, 'exceptionType': BKTBadRequestException},
    {'input': 3, 'exceptionType': BKTUnauthorizedException},
    {'input': 4, 'exceptionType': BKTForbiddenException},
    {'input': 5, 'exceptionType': BKTFeatureNotFoundException},
    {'input': 6, 'exceptionType': BKTClientClosedRequestException},
    {'input': 7, 'exceptionType': BKTInvalidHttpMethodException},
    {'input': 8, 'exceptionType': PayloadTooLargeException},
    {'input': 9, 'exceptionType': BKTInternalServerErrorException},
    {'input': 10, 'exceptionType': BKTServiceUnavailableException},
    {'input': 11, 'exceptionType': BKTTimeoutException},
    {'input': 12, 'exceptionType': BKTNetworkException},
    {'input': 13, 'exceptionType': BKTIllegalArgumentException},
    {'input': 14, 'exceptionType': BKTIllegalStateException},
    {'input': 15, 'exceptionType': BKTUnknownException},
    {'input': 0, 'exceptionType': BKTUnknownException},
  ];

  group('IntToBKTException tests', () {
    for (var testCase in testCases) {
      test('Converts ${testCase['input']} to ${testCase['exceptionType']}', () {
        final exception = (testCase['input'] as int).toBKTException('Test message');
        expect(exception.runtimeType, testCase['exceptionType']);
        expect(exception.message, 'Test message');
      });
    }
  });
}