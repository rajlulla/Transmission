//
//  TorrentListView.swift
//  Transmission
//
//  Created by Raj Lulla on 1/12/24.
//

import SwiftUI

struct TorrentListView: View {
    
    @StateObject var viewModel = TorrentListViewModel()
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            NavigationStack {
                List(viewModel.torrents) { torrent in
                    torrentCellView(for: torrent)
                }
                .navigationTitle("🧲 Downloads")
                .listStyle(.plain)
                .refreshable {
                    viewModel.refreshTorrents()
                }
                .onReceive(timer) { _ in
                    autoRefreshTorrents()
                }
                .toolbar {
                    Button("Settings") {
                        viewModel.showingSettings = true
                    }
                }
                .sheet(isPresented: $viewModel.showingSettings) {
                    SettingsView(viewModel: viewModel, showingSettings: $viewModel.showingSettings)
                }
                .alert("Select Action", isPresented: $viewModel.showTorrentActions) {
                    if viewModel.selectedTorrent?.status == 0{
                        Button("Resume", action: {
                            resumeTorrentAction()
                        })
                        Button("Resume Now", action: {
                            resumeTorrentNowAction()
                        })
                    } else {
                        Button("Pause", action: {
                            stopTorrentAction()
                        })
                    }
                    if viewModel.selectedTorrent?.status != 2 && viewModel.selectedTorrent?.status != 3 {
                        Button("Verify Data", action: {
                            verifyTorrentAction()
                        })
                    }
                    Button("Reannounce", action: {
                        reannounceTorrentAction()
                    })
                    Button("Delete", role: .destructive, action: {
                        viewModel.showDeleteConfirmation = true
                    })
                    Button("Cancel", role: .cancel, action: {})
                } message: {
                    Text(viewModel.selectedTorrent?.name ?? "")
                }
                .alert("Delete Torrent", isPresented: $viewModel.showDeleteConfirmation) {
                    Button("Delete with Data", role: .destructive) {
                        deleteTorrentDataAction()
                    }
                    Button("Delete without Data") {
                        deleteTorrentAction()
                    }
                    Button("Cancel", role: .cancel, action: {})
                } message: {
                    Text("Do you want to delete the local data as well?")
                }
                .alert(viewModel.alertItem?.title ?? "", isPresented: $viewModel.showAlert) {
                    Button("Cancel", role: .cancel, action: {})
                } message: {
                    Text(viewModel.alertItem?.message ?? "")
                }
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
    
    private func torrentCellView(for torrent: Torrent) -> some View {
        TorrentListCell(torrent: torrent)
            .onTapGesture {
                viewModel.selectedTorrent = torrent
                viewModel.showTorrentActions = true
            }
    }
    
    private func autoRefreshTorrents() {
        if viewModel.shouldAutoRefresh {
            viewModel.getTorrents()
        }
    }
    
    private func resumeTorrentAction() {
        if let torrentId = viewModel.selectedTorrent?.id {
            viewModel.resumeTorrent(torrentId: torrentId)
        }
    }

    private func resumeTorrentNowAction() {
        if let torrentId = viewModel.selectedTorrent?.id {
            viewModel.resumeTorrentNow(torrentId: torrentId)
        }
    }

    private func stopTorrentAction() {
        if let torrentId = viewModel.selectedTorrent?.id {
            viewModel.stopTorrent(torrentId: torrentId)
        }
    }

    private func verifyTorrentAction() {
        if let torrentId = viewModel.selectedTorrent?.id {
            viewModel.verifyTorrent(torrentId: torrentId)
        }
    }

    private func reannounceTorrentAction() {
        if let torrentId = viewModel.selectedTorrent?.id {
            viewModel.reannounceTorrent(torrentId: torrentId)
        }
    }

    private func deleteTorrentAction() {
        if let torrentId = viewModel.selectedTorrent?.id {
            viewModel.deleteTorrent(torrentId: torrentId)
        }
    }

    private func deleteTorrentDataAction() {
        if let torrentId = viewModel.selectedTorrent?.id {
            viewModel.deleteTorrentData(torrentId: torrentId)
        }
    }
}

#Preview {
    TorrentListView()
}
