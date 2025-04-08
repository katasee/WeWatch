//
//  CustomErrorMessage.swift
//  WeWatch
//
//  Created by Anton on 08/04/2025.
//

import SwiftUI

extension AuthenticationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Something went wrong while communicating with the server. Please try again later."
        case .decodingError:
            return "Something went wrong while processing the data from the server."
        case .custom(let errorMessage):
            return errorMessage
        case .invalidURL:
            return "Invalid URL. Please try again"
        case .invalidStatusCode:
            return "The server responded with an error. Please try again later."
        }
    }
}
