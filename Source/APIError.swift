//
//  APIError.swift
//  SwiftGraylog
//
//  Created by Alexandre Karst on 14/11/2018.
//  Copyright © 2018 iAdvize. All rights reserved.
//

import Foundation

/// Enum describing all errors that could occured during the API requesting process.
///
/// - validationFailed: Once we receive the response from the server, we validate it
/// checking if they were an error thrown by the server, the status
/// code and the consistency of the returned data.
enum APIError: Error {
    case validationFailed(reason: ValidationFailureReason)

    /// Enum precising why the server response validation failed.
    ///
    /// - invalidResponse: The response data wasn't in right format (JSON).
    /// - emptyResponse: No response data was empty while expecting some data.
    /// - invalidStatusCode: The server returns an invalid status code.
    /// An error occurs on the server side.
    /// - invalidContentType: The content type (mime type) returned by the server
    /// is invalid.
    /// - invalidURL: The URL provided is invalid.
    /// - serverError:      The server returns an error (e.g. failure status code).
    /// - requestFailed:    The server returns some errors regarding the query.
    enum ValidationFailureReason {
        case invalidResponse
        case emptyResponse
        case invalidStatusCode(code: Int)
        case invalidContentType(contentType: String)
        case invalidURL(url: String)
        case serverError(error: Error)
    }
}

/// Extension which exposes a localized description for each validation failures.
extension APIError.ValidationFailureReason {
    /// Combined with `localizedDescription()` it gives a global context of the error.
    ///
    /// - Parameter reason: Specific error message explaining why this error was triggered.
    /// - Returns: A detailed description of the error.
    func description(with reason: String) -> String {
        return "Response validation failed. \(reason)"
    }

    /// Error messages explaining each failure reasons.
    var localizedDescription: String {
        switch self {
        case .invalidStatusCode(let code):
            return description(with: "Invalid status code: \(code).")
        case .invalidContentType(let contentType):
            return description(with: "Invalid content type: \(contentType).")
        case .invalidResponse:
            return description(with: "Invalid response.")
        case .emptyResponse:
            return description(with: "Expected some data but the server response was empty.")
        case .invalidURL(let url):
            return description(with: "Invalid URL: \(url).")
        case .serverError(let error):
            return description(with: error.localizedDescription)
        }
    }
}

/// Extension which exposes an error description for any kind of APIError.
extension APIError: LocalizedError {
    /// Full description of the APIError that can be logged.
    var errorDescription: String? {
        switch self {
        case .validationFailed(let reason):
            return reason.localizedDescription
        }
    }
}
