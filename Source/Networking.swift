//
//  Networking.swift
//  IAdvizeConversationSDK
//
//  Created by Alexandre Karst on 14/11/2018.
//  Copyright © 2018 iAdvize. All rights reserved.
//

import Foundation

/// List of acceptable "mime type".
private let acceptableMimeTypes = ["application/json"]

/// List of acceptable "status code".
private let acceptableStatusCodes = Array(200..<300)

struct Networking {
    /// Validate the result of an API request checking if there was an error
    /// returned by the server and if the data and the status code are valid.
    ///
    /// - Parameters:
    ///   - data: Data returned by the server.
    ///   - response: Response from the API request.
    ///   - error: Error returned from the server.
    /// - Throws: `APIError.validationFailed`.
    static func validate(_ data: Data?, _ response: URLResponse?, _ error: Error?) throws {
        // Check if we have a proper response.
        guard let response = response as? HTTPURLResponse else {
            throw APIError.validationFailed(reason: .invalidResponse)
        }

        // Check if the status code returned from the server is valid.
        guard acceptableStatusCodes.contains(response.statusCode) else {
            throw APIError.validationFailed(reason: .invalidStatusCode(code: response.statusCode))
        }

        // If we expect some content, we have to validate that it is from
        // an acceptable content type.
        if response.expectedContentLength > 0 {
            guard let mimeType = response.mimeType, acceptableMimeTypes.contains(mimeType) else {
                throw APIError.validationFailed(reason: .invalidContentType(contentType: response.mimeType ?? "No mime type was found."))
            }

            // If we expect some data (expectedContentLength > 0) we check if
            // we have some.
            guard let data = data,
                data.count > 0 else {
                    throw APIError.validationFailed(reason: .emptyResponse)
            }
        }

        // If an error occured, throw it directly.
        if let error = error {
            throw error
        }
    }
}
