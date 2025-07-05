
// Dependency.swift


import Foundation

// Represents the installation status of a single tool.
enum DependencyStatus: Equatable {
    case unknown
    case checking
    case notInstalled
    case installing
    case installed
    case failed(String)
}

// A class to hold the state of a single dependency.
// Using a class (and ObservableObject) allows individual rows in a list to update.
@MainActor
class Dependency: ObservableObject, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let formulaName: String // The name used by Homebrew (e.g., "yt-dlp", "vlc")
    let isCask: Bool
    let commandName: String?
    let versionFlag: String
    
    /// A closure that takes the raw output from the version command and extracts the version string.
    let versionParser: (String) -> String?
    
    @Published var status: DependencyStatus = .unknown
    @Published var version: String? = nil
    @Published var installationLog: [String] = []

    init(name: String,
         description: String,
         formulaName: String,
         isCask: Bool = false,
         commandName: String? = nil,
         versionFlag: String = "--version",
         versionParser: @escaping (String) -> String?) {
        
        self.name = name
        self.description = description
        self.formulaName = formulaName
        self.isCask = isCask
        self.commandName = commandName
        self.versionFlag = versionFlag
        self.versionParser = versionParser
    }
    
    func appendLog(_ line: String) {
        installationLog.append(line)
    }
}
