//
//  TransmissionError.swift
//  Transmission
//
//  Created by Raj Lulla on 1/16/24.
//

import Foundation

enum TransmissionError: Error {
    case rpcURLNotSet
    case invalidURL
    case insecureURL
    case invalidResponse
    case invalidData
    case unableToComplete
    case tooManyRetries
    case missingSessionId
    case authenticationError
}
