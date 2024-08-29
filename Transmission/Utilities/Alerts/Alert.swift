//
//  Alert.swift
//  Transmission
//
//  Created by Raj Lulla on 1/16/24.
//

import Foundation

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}


struct AlertContext {
    static let invalidData          = AlertItem(title: "Server Error",
                                                message: "Invalid data.")
    
    static let invalidResponse      = AlertItem(title: "Server Error",
                                                message: "Invalid response.")
    
    static let rpcURLNotSet         = AlertItem(title: "Error",
                                                message: "Transmission URL not set. Please set the URL in settings.")
    
    static let invalidURL           = AlertItem(title: "Sever Error",
                                                message: "Invalid URL.")
    
    static let unableToComplete     = AlertItem(title: "Server Error",
                                                message: "Unable to complete.")
    
    static let tooManyRetries       = AlertItem(title: "Server Error",
                                                message: "Too many retries.")
    
    static let missingSessionId     = AlertItem(title: "Server Error",
                                                message: "Could not get session ID.")
    
    static let authenticationError  = AlertItem(title: "Server Error",
                                                message: "Authentication failed.")
}
