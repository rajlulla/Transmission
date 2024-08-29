//
//  TorrentListViewModel.swift
//  Transmission
//
//  Created by Raj Lulla on 1/16/24.
//

import Foundation

@MainActor final class TorrentListViewModel: ObservableObject {
    
    @Published var torrents: [Torrent] = []
    @Published var selectedTorrent: Torrent? = nil
    @Published var showingSettings: Bool = false
    @Published var showTorrentActions: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertItem: AlertItem? = nil
    @Published var showDeleteConfirmation: Bool = false
    @Published var isLoading: Bool = true
    @Published var shouldAutoRefresh = true
    
    func getTorrents() {
        NetworkManager.shared.fetchTorrents { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                    case .success(let torrents):
                    let sortedTorrents = torrents.sorted { first, second in
                        if first.percentDone < 1 && second.percentDone < 1 {
                            return first.percentDone < second.percentDone
                        } else if first.percentDone >= 1 && second.percentDone >= 1 {
                            if first.status == 0 && second.status != 0 {
                                return false
                            } else if second.status == 0 && first.status != 0 {
                                return true
                            } else if first.isFinished && !second.isFinished {
                                return false
                            } else if second.isFinished && !first.isFinished {
                                return true
                            } else {
                                return first.uploadRatio < second.uploadRatio
                            }
                        } else {
                            return first.percentDone < second.percentDone
                        }
                    }
                    self?.torrents = sortedTorrents

                    case .failure(let error):
                        self?.handleError(error)
                }
            }
        }
    }
    
    // Resume Torrent
    func resumeTorrent(torrentId: Int) {
        NetworkManager.shared.resumeTorrent(torrentId: torrentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        self?.refreshTorrents()
                    case .failure(let error):
                        self?.handleError(error)
                }
            }
        }
    }

    // Resume Torrent Now
    func resumeTorrentNow(torrentId: Int) {
        NetworkManager.shared.resumeTorrentNow(torrentId: torrentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        self?.refreshTorrents()
                    case .failure(let error):
                        self?.handleError(error)
                }
            }
        }
    }

    // Stop Torrent
    func stopTorrent(torrentId: Int) {
        NetworkManager.shared.stopTorrent(torrentId: torrentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        self?.refreshTorrents()
                    case .failure(let error):
                        self?.handleError(error)
                }
            }
        }
    }

    // Verify Torrent
    func verifyTorrent(torrentId: Int) {
        NetworkManager.shared.verifyTorrent(torrentId: torrentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        self?.refreshTorrents()
                    case .failure(let error):
                        self?.handleError(error)
                }
            }
        }
    }

    // Reannounce Torrent
    func reannounceTorrent(torrentId: Int) {
        NetworkManager.shared.reannounceTorrent(torrentId: torrentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        self?.refreshTorrents()
                    case .failure(let error):
                        self?.handleError(error)
                }
            }
        }
    }
    
    // Reannounce Torrent
    func deleteTorrent(torrentId: Int) {
        NetworkManager.shared.deleteTorrent(torrentId: torrentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        self?.refreshTorrents()
                    case .failure(let error):
                        self?.handleError(error)
                }
            }
        }
    }
    
    // Reannounce Torrent
    func deleteTorrentData(torrentId: Int) {
        NetworkManager.shared.deleteTorrentData(torrentId: torrentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success:
                        self?.refreshTorrents()
                    case .failure(let error):
                        self?.handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: TransmissionError) {
        self.showAlert = true
        self.shouldAutoRefresh = false
        
        switch error {
            case .invalidResponse:
                alertItem = AlertContext.invalidResponse

            case .invalidURL:
                alertItem = AlertContext.invalidURL

            case .invalidData:
                alertItem = AlertContext.invalidData

            case .unableToComplete:
                alertItem = AlertContext.unableToComplete
                
            case .tooManyRetries:
                alertItem = AlertContext.tooManyRetries
                
            case .missingSessionId:
                alertItem = AlertContext.missingSessionId
                
            case .authenticationError:
                alertItem = AlertContext.authenticationError
                
            case .rpcURLNotSet:
                alertItem = AlertContext.rpcURLNotSet
        }
    }
    
    func refreshTorrents() {
        shouldAutoRefresh = true
        getTorrents()
    }
}
