//
//  SettingsView.swift
//  Transmission
//
//  Created by Raj Lulla on 1/16/24.
//

import SwiftUI
import KeychainSwift

struct SettingsView: View {
    let keychain = KeychainSwift()

    @State private var rpcURL: String = KeychainSwift().get("rpcURL") ?? ""
    @State private var username: String = KeychainSwift().get("username") ?? ""
    @State private var password: String = KeychainSwift().get("password") ?? ""
    
    @ObservedObject var viewModel: TorrentListViewModel
    @Binding var showingSettings: Bool

    var body: some View {
        Form {
            Section(header: Text("Transmission Settings")) {
                TextField("RPC URL - Must be HTTPS", text: $rpcURL)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                SecureField("Password", text: $password)
                Button("Save") {
                    saveSettings()
                }
            }
        }
        .navigationBarTitle("Settings")
    }

    private func saveSettings() {
        keychain.set(rpcURL, forKey: "rpcURL")
        keychain.set(username, forKey: "username")
        keychain.set(password, forKey: "password")
        showingSettings = false
        viewModel.refreshTorrents()
    }
}

#Preview {
    SettingsView(viewModel: TorrentListViewModel(), showingSettings: .constant(true))
}
