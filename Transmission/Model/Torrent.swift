//
//  Torrent.swift
//  Transmission
//
//  Created by Raj Lulla on 1/12/24.
//

import Foundation

struct TransmissionResponse: Decodable {
    let arguments: Arguments
    let result: String

    struct Arguments: Decodable {
        let torrents: [Torrent]
    }
}

struct Torrent: Decodable, Identifiable {
    let id: Int
    let name: String
    let status: Int
    let percentDone: Double
    let haveValid: Int
    let sizeWhenDone: Int
    let uploadedEver: Int
    let uploadRatio: Double
    let rateDownload: Int
    let rateUpload: Int
    let peersGettingFromUs: Int
    let peersSendingToUs: Int
    let peersConnected: Int
    let isFinished: Bool
    let isStalled: Bool
    let eta: Int
}

struct MockData {
    static let sampleTorrent            = Torrent(id: 16,
                                                  name: "War for the Planet of the Apes 2017 (1080p Bluray x265 HEVC 10bit AAC 7.1 Tigole)",
                                                  status: 4,
                                                  percentDone: 0.9693,
                                                  haveValid: 5818317457,
                                                  sizeWhenDone: 6002866833,
                                                  uploadedEver: 0,
                                                  uploadRatio: 0.0,
                                                  rateDownload: 0,
                                                  rateUpload: 0,
                                                  peersGettingFromUs: 0,
                                                  peersSendingToUs: 0,
                                                  peersConnected: 0,
                                                  isFinished: false,
                                                  isStalled: true,
                                                  eta: -1)
    
    static let sampleCompletedTorrent   = Torrent(id: 1, 
                                                  name: "Completed Torrent",
                                                  status: 6,
                                                  percentDone: 1.0,
                                                  haveValid: 10000000,
                                                  sizeWhenDone: 10000000,
                                                  uploadedEver: 1000000,
                                                  uploadRatio: 0.1,
                                                  rateDownload: 0,
                                                  rateUpload: 0, 
                                                  peersGettingFromUs: 0,
                                                  peersSendingToUs: 0,
                                                  peersConnected: 0,
                                                  isFinished: false,
                                                  isStalled: false,
                                                  eta: -1)
    
    static let torrents                 = [sampleTorrent, sampleCompletedTorrent, sampleTorrent]
}
