
import 'exception.dart';
import 'result.dart';

extension ObjectToBKTException on Object {
  BKTResult<T> toBKTResultFailure<T>() {
    if (this is BKTException) {
      return BKTResult<T>.failure(toString(), exception: this as BKTException);
    }
    final exception = BKTUnknownException(
        message: toString(),
        exception: this is Exception ? this as Exception : null);
    return BKTResult<T>.failure(exception.message, exception: exception);
  }
}

extension ParseBKTException on Map<String, dynamic> {
  BKTException parseBKTException() {
    final errorCode = this['errorCode'];
    final errorMessage = this['errorMessage'] ?? "unknown";
    final typedErrorMessage =
    errorMessage is String ? errorMessage : errorMessage.toString();
    if (errorCode is int) {
      return errorCode.toBKTException(typedErrorMessage);
    }
    return BKTUnknownException(message: typedErrorMessage);
  }
}

extension IntToBKTException on int {
  BKTException toBKTException(String errorMessage) {
    switch (this) {
      case 1:
        return RedirectRequestException(message: errorMessage);
      case 2:
        return BKTBadRequestException(message: errorMessage);
      case 3:
        return BKTUnauthorizedException(message: errorMessage);
      case 4:
        return BKTForbiddenException(message: errorMessage);
      case 5:
        return BKTFeatureNotFoundException(message: errorMessage);
      case 6:
        return BKTClientClosedRequestException(message: errorMessage);
      case 7:
        return BKTInvalidHttpMethodException(message: errorMessage);
      case 8:
        return PayloadTooLargeException(message: errorMessage);
      case 9:
        return BKTInternalServerErrorException(message: errorMessage);
      case 10:
        return BKTServiceUnavailableException(message: errorMessage);
      case 11:
        return BKTTimeoutException(message: errorMessage);
      case 12:
        return BKTNetworkException(message: errorMessage);
      case 13:
        return BKTIllegalArgumentException(message: errorMessage);
      case 14:
        return BKTIllegalStateException(message: errorMessage);
      case 15:
        return BKTUnknownException(message: errorMessage);
      default:
        return BKTUnknownException(message: errorMessage);
    }
  }
}
