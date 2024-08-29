//
//  Int+Ext.swift
//  Transmission
//
//  Created by Raj Lulla on 1/12/24.
//

import Foundation

extension Int {
    func toDataSizeString() -> String {
        let bytes = Double(self)
        let kilobytes = bytes / 1000
        let megabytes = kilobytes / 1000
        let gigabytes = megabytes / 1000

        if gigabytes >= 1 {
            return String(format: "%.2f GB", gigabytes)
        } else if megabytes >= 1 {
            return String(format: "%.2f MB", megabytes)
        } else if kilobytes >= 1 {
            return String(format: "%.2f kB", kilobytes)
        } else {
            return "\(self) B"
        }
    }
    
    func toReadableTime() -> String {
        if self == -1 {
            return "∞"
        } else if self >= 86400 { // More than or equal to 24 hours
            let days = self / 86400
            let hours = (self % 86400) / 3600
            return "\(days)d \(hours)h"
        } else if self >= 3600 { // Less than 24 hours but more than or equal to 1 hour
            let hours = self / 3600
            let minutes = (self % 3600) / 60
            return "\(hours)h \(minutes)m"
        } else if self >= 60 { // Less than 1 hour but more than or equal to 1 minute
            let minutes = self / 60
            return "\(minutes)m"
        } else { // Less than 1 minute
            return "\(self)s"
        }
    }
}
