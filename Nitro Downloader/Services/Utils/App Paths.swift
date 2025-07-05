
// App Paths.swift


import Foundation

struct AppPaths {

    // --- Directory Name ---
    // A private constant for the main folder name for easy modification.
    private static let appDirectoryName = "Nitro Downloader"

    
    // --- File Names ---
    // Using constants for filenames prevents typos and makes changes easy.
    static let databaseFileName = "nitro.db" // Added constant for your DB file

    
    // --- Main Directory URL ---
    /// The dedicated directory for your app's support files.
    /// Example: ~/Library/Application Support/Nitro Downloader/
    static let toolDirectory: URL? = {
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return appSupportURL.appendingPathComponent(appDirectoryName)
    }()

    
    /// The full URL to the SQLite database.
    /// Example: .../Nitro Downloader/nitro.db
    static var databaseURL: URL? {
        // We reuse `toolDirectory` to ensure the DB is in the correct folder.
        return toolDirectory?.appendingPathComponent(databaseFileName)
    }

    
    // --- Helper Function ---
    /// Checks if the tool directory exists and creates it if it doesn't.
    /// You must call this before trying to write files to the directory.
    static func ensureDirectoryExists() throws {
        guard let url = toolDirectory else {
            throw NSError(domain: "AppPathsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find Application Support directory."])
        }

        // Creates the "Nitro Downloader" directory if it doesn't already exist.
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
}
