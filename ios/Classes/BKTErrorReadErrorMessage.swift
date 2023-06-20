import Foundation
import Bucketeer

extension BKTError {
    func message() -> String {
        let errorMessage : String
        switch self {
        case .badRequest(message: let message):
            errorMessage = message
        case .unauthorized(message: let message):
            errorMessage = message
        case .forbidden(message: let message):
            errorMessage = message
        case .notFound(message: let message):
            errorMessage = message
        case .clientClosed(message: let message):
            errorMessage = message
        case .unavailable(message: let message):
            errorMessage = message
        case .apiServer(message: let message):
            errorMessage = message
        case .timeout(message: let message, _):
            errorMessage = message
        case .network(message: let message, _):
            errorMessage = message
        case .illegalArgument(message: let message):
            errorMessage = message
        case .illegalState(message: let message):
            errorMessage = message
        case .unknownServer(message: let message, _):
            errorMessage = message
        case .unknown(message: let message, _):
            errorMessage = message
        }
        return errorMessage
    }
}
