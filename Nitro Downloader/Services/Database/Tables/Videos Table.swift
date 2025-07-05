
// Videos Table.swift


import Foundation
import GRDB

struct VideoItemRecord: Codable, FetchableRecord, MutablePersistableRecord {
    var id: UUID
    var fileName: String
    var size: Double
    var status: String // Store the enum's rawValue
    var timeLeft: String
    var downloadSpeed: String
    var downloadURL: String
    var lastTryDate: Date
    var description: String
    var priority: Int // We'll add this in a v2 migration

    // Define the database table name
    static let databaseTableName = "videos"
    
    // Helper to get the DownloadStatus enum
    var downloadStatus: DownloadStatus {
        get { DownloadStatus(rawValue: status) ?? .failed }
        set { status = newValue.rawValue }
    }
}
