
// Database Manager.swift


import Foundation
import GRDB

class DatabaseManager {
    // A shared singleton instance
    static let shared = DatabaseManager()
    
    // The database connection pool
    let dbQueue: DatabaseQueue
    
    
    // A custom error enum for clear failure reasons
    enum DatabaseError: Error, LocalizedError {
        case databasePathInvalid
        
        var errorDescription: String? {
            switch self {
            case .databasePathInvalid:
                return "Could not determine a valid path for the database."
            }
        }
    }
    
    private init() {
        do {
            // 1. IMPORTANT: Ensure the "Nitro Downloader" folder exists before proceeding.
            try AppPaths.ensureDirectoryExists()
            
            // 2. Get the constant URL for your database.
            guard let dbURL = AppPaths.databaseURL else {
                // Instead of returning, throw an error to be caught below
                throw DatabaseError.databasePathInvalid
            }
            
            // 2. Open the database connection
            dbQueue = try DatabaseQueue(path: dbURL.path)
            
            // 3. Run the migrations
            try self.runMigrations()
            
            print("Database setup complete at: \(dbURL.path)")
            
        } catch {
            // This is a critical failure. In a real app, you might want to
            // display an alert to the user or gracefully disable features.
            fatalError("Failed to initialize database: \(error)")
        }
    }
    
    private func runMigrations() throws {
        // Create an AppMigrator instance and run the migrations
        let migrator = AppMigrator.migrator
        try migrator.migrate(dbQueue)
    }
}

// Ensure the database is set up when the app starts
func setupDatabase() {
    _ = DatabaseManager.shared
}
