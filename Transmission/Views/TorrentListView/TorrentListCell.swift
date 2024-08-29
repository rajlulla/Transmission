//
//  TorrentListCell.swift
//  Transmission
//
//  Created by Raj Lulla on 1/12/24.
//

import SwiftUI

struct TorrentListCell: View {
    
    let torrent: Torrent
    
    private func statusProperties() -> (rateLine: String, sizeLine: String, progressColor: Color, backgroundColor: Color, progressValue: Double) {

        var rateLine: String
        var sizeLine: String
        var progressColor: Color
        var backgroundColor: Color = .clear // Default to clear background
        var progressValue: Double = torrent.percentDone

        switch torrent.status {
        case 0:
            if torrent.isFinished {
                rateLine = "Finished"
                sizeLine = "\(torrent.haveValid.toDataSizeString()), uploaded \(torrent.uploadedEver.toDataSizeString()) (Ratio \(String(format: "%.2f", torrent.uploadRatio)))"
                progressColor = .green
            } else {
                rateLine = "Stopped"
                sizeLine = "\(torrent.haveValid.toDataSizeString()) of \(torrent.sizeWhenDone.toDataSizeString()) (\(String(format: "%.1f%%", torrent.percentDone * 100)))"
                progressColor = .red
            }
        case 1:
            rateLine = "Queued to verify local data"
            sizeLine = "\(torrent.haveValid.toDataSizeString()) of \(torrent.sizeWhenDone.toDataSizeString()) (\(String(format: "%.1f%%", torrent.percentDone * 100)))"
            progressColor = .yellow
        case 2:
            rateLine = "Verifying local data"
            sizeLine = "\(torrent.haveValid.toDataSizeString()) of \(torrent.sizeWhenDone.toDataSizeString()) (\(String(format: "%.1f%%", torrent.percentDone * 100)))"
            progressColor = .yellow
        case 3:
            rateLine = "Queued to download"
            sizeLine = "\(torrent.haveValid.toDataSizeString()) of \(torrent.sizeWhenDone.toDataSizeString()) (\(String(format: "%.1f%%", torrent.percentDone * 100)))"
            progressColor = .blue
        case 4:
            rateLine = "Downloading from \(torrent.peersSendingToUs) of \(torrent.peersConnected) peers - ▼ \(torrent.rateDownload.toDataSizeString()) ▲ \(torrent.rateUpload.toDataSizeString())"
            sizeLine = "\(torrent.haveValid.toDataSizeString()) of \(torrent.sizeWhenDone.toDataSizeString()) (\(String(format: "%.1f%%", torrent.percentDone * 100))) - \(torrent.eta.toReadableTime()) remaining"
            progressColor = .blue
        case 5:
            rateLine = "Queued to seed"
            sizeLine = "\(torrent.haveValid.toDataSizeString())"
            progressColor = .green
            progressValue = torrent.uploadRatio
            backgroundColor = .green.opacity(0.6)
        case 6:
            rateLine = "Seeding to \(torrent.peersGettingFromUs) of \(torrent.peersConnected) peers - ▲ \(torrent.rateUpload.toDataSizeString())"
            sizeLine = "\(torrent.haveValid.toDataSizeString()), uploaded \(torrent.uploadedEver.toDataSizeString()) \(String(format: "(%.2f)", torrent.uploadRatio))"
            progressColor = .green
            progressValue = torrent.uploadRatio
            backgroundColor = .green.opacity(0.6)
        default:
            rateLine = "Unknown"
            sizeLine = "Unknown"
            progressColor = .red
        }
        
        return (rateLine, sizeLine, progressColor, backgroundColor, progressValue)
    }
    
    var body: some View {
        let (rateLine, sizeLine, progressColor, backgroundColor, progressValue) = statusProperties()

        VStack(alignment: .leading) {
            Text(torrent.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(rateLine)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            ProgressView(value: progressValue)
                .tint(progressColor)
                .background(backgroundColor)
            
            Text(sizeLine)
                .font(.callout)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

#Preview {
    TorrentListCell(torrent: MockData.sampleCompletedTorrent)
}
