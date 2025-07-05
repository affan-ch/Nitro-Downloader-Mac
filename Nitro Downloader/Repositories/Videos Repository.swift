
// Videos Repository.swift

import SwiftUI


extension DatabaseManager {
    
    // MARK: - Create
    
    func createVideoRecord(_ download: VideoItemRecord) throws {
        try dbQueue.write { db in
            // 1. Create a mutable copy of the 'let' constant parameter.
            var mutableDownload = download
            
            // 2. Call the mutating 'insert' method on the mutable copy.
            try mutableDownload.insert(db)
        }
    }
    
    // MARK: - Read
    
    func fetchAllVideoRecords() throws -> [VideoItemRecord] {
        try dbQueue.read { db in
            try VideoItemRecord.fetchAll(db)
        }
    }
    
    func fetchVideoRecord(id: UUID) throws -> VideoItemRecord? {
        try dbQueue.read { db in
            try VideoItemRecord.fetchOne(db, key: id)
        }
    }
    
    // MARK: - Update
    
    func updateVideoRecord(_ download: VideoItemRecord) throws {
        try dbQueue.write { db in
            try download.update(db)
        }
    }
    
    // A more specific update example
    func updateVideoRecordStatus(for id: UUID, to newStatus: DownloadStatus) throws {
        try dbQueue.write { db in
            if var download = try VideoItemRecord.fetchOne(db, key: id) {
                download.status = newStatus.rawValue
                try download.update(db)
            }
        }
    }
    
    // MARK: - Delete
    
    func deleteVideoRecord(id: UUID) throws -> Bool {
        try dbQueue.write { db in
            try VideoItemRecord.deleteOne(db, key: id)
        }
    }
    
    func deleteVideoRecords(ids: [UUID]) throws {
        try dbQueue.write { db in
            _ = try VideoItemRecord.deleteAll(db, keys: ids)
        }
    }
    
    func deleteAllVideoRecords() throws {
        try dbQueue.write { db in
            _ = try VideoItemRecord.deleteAll(db)
        }
    }
}
