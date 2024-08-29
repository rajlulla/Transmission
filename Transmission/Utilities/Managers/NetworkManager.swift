//
//  NetworkManager.swift
//  Transmission
//
//  Created by Raj Lulla on 1/16/24.
//

import Foundation
import KeychainSwift

final class NetworkManager {
    static let shared = NetworkManager()
    private let keychain = KeychainSwift()
    
    private var sessionId: String?
    private let maxRetries = 2  // Maximum number of retries for a 409 response
    
    func fetchTorrents(completion: @escaping (Result<[Torrent], TransmissionError>) -> Void) {
        // JSON for POST request
        let postData = """
        {
            "arguments": {
                "fields": [
                    "eta",
                    "id",
                    "isFinished",
                    "isStalled",
                    "haveValid",
                    "name",
                    "peersConnected",
                    "peersGettingFromUs",
                    "peersSendingToUs",
                    "percentDone",
                    "rateDownload",
                    "rateUpload",
                    "sizeWhenDone",
                    "status",
                    "uploadedEver",
                    "uploadRatio"
                ]
            },
            "method": "torrent-get"
        }
        """.data(using: .utf8)
        
        // Perform network request
        performNetworkRequest(httpMethod: "POST", bodyData: postData) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(TransmissionResponse.self, from: data)
                    completion(.success(decodedResponse.arguments.torrents))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func resumeTorrent(torrentId: Int, completion: @escaping (Result<Void, TransmissionError>) -> Void) {
        performTorrentAction(torrentId: torrentId, action: "torrent-start", completion: completion)
    }

    func resumeTorrentNow(torrentId: Int, completion: @escaping (Result<Void, TransmissionError>) -> Void) {
        performTorrentAction(torrentId: torrentId, action: "torrent-start-now", completion: completion)
    }

    func stopTorrent(torrentId: Int, completion: @escaping (Result<Void, TransmissionError>) -> Void) {
        performTorrentAction(torrentId: torrentId, action: "torrent-stop", completion: completion)
    }
    
    func verifyTorrent(torrentId: Int, completion: @escaping (Result<Void, TransmissionError>) -> Void) {
        performTorrentAction(torrentId: torrentId, action: "torrent-verify", completion: completion)
    }
    
    func reannounceTorrent(torrentId: Int, completion: @escaping (Result<Void, TransmissionError>) -> Void) {
        performTorrentAction(torrentId: torrentId, action: "torrent-reannounce", completion: completion)
    }
    
    private func performTorrentAction(torrentId: Int, action: String, completion: @escaping (Result<Void, TransmissionError>) -> Void) {
        let postData = """
        {
            "arguments": {
                "ids": [\(torrentId)]
            },
            "method": "\(action)"
        }
        """.data(using: .utf8)

        performNetworkRequest(httpMethod: "POST", bodyData: postData) { result in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteTorrent(torrentId: Int, completion: @escaping (Result<Void, TransmissionError>) -> Void) {
        performDeleteTorrent(torrentId: torrentId, deleteLocalData: false, completion: completion)
    }
    
    func deleteTorrentData(torrentId: Int, completion: @escaping (Result<Void, TransmissionError>) -> Void) {
        performDeleteTorrent(torrentId: torrentId, deleteLocalData: true, completion: completion)
    }
    
    private func performDeleteTorrent(torrentId: Int, deleteLocalData: Bool, completion: @escaping (Result<Void, TransmissionError>) -> Void) {
        let postData = """
        {
            "arguments": {
                "ids": [\(torrentId)],
                "delete-local-data": \(deleteLocalData)
            },
            "method": "torrent-remove"
        }
        """.data(using: .utf8)

        performNetworkRequest(httpMethod: "POST", bodyData: postData) { result in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func performNetworkRequest(httpMethod: String, bodyData: Data?, retryCount: Int = 0, completion: @escaping (Result<Data, TransmissionError>) -> Void) {
        // Check if the RPC URL is set in the Keychain
        guard let urlString = keychain.get("rpcURL") else {
            completion(.failure(.rpcURLNotSet)) // Custom error when RPC URL is not set
            return
        }
        
        // Check if the RPC URL is a valid URL
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        // Create Netowrk Request
        var request = URLRequest(url: url)
        request.addValue(sessionId ?? "", forHTTPHeaderField: "X-Transmission-Session-Id")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        request.httpBody = bodyData

        // Set Authorization header if authentication is needed
        if keychain.getBool("useAuth") == true,
           let username = keychain.get("username"),
           let password = keychain.get("password") {
            let credentials = "\(username):\(password)"
            if let credentialsData = credentials.data(using: .utf8) {
                let base64Credentials = credentialsData.base64EncodedString(options: [])
                request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            }
        }

        // Create request task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check http response
            if let response = response as? HTTPURLResponse {
                // If response is a 409, update the session ID
                if response.statusCode == 409 {
                    guard retryCount < self.maxRetries else {
                        completion(.failure(.tooManyRetries))
                        return
                    }
                    
                    if self.handleSessionIdUpdate(from: response) {
                        self.performNetworkRequest(httpMethod: httpMethod, bodyData: bodyData, retryCount: retryCount + 1, completion: completion) // Retry with new session ID
                    } else {
                        completion(.failure(.missingSessionId))
                    }
                    return
                // If the response is a 401, auth failed
                } else if response.statusCode == 401 {
                    completion(.failure(.authenticationError))
                    return
                }
            }
            
            // Handle any error
            if let _ = error {
                completion(.failure(.unableToComplete))
            }
            
            // If response is not 200, show an error
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // If data doesn't exist, show an error
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            // Return data
            completion(.success(data))
        }
        
        task.resume()
    }

    
    private func handleSessionIdUpdate(from response: HTTPURLResponse) -> Bool {
        if let newSessionId = response.allHeaderFields["x-transmission-session-id"] as? String {
            self.sessionId = newSessionId
            return true
        }
        return false
    }
}
