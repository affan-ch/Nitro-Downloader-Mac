
// Dependency Manager.swift


import Foundation
import SwiftUI

@MainActor
class DependencyManager: ObservableObject {
    
    @Published var dependencies: [Dependency] = [
        Dependency(
            name: "YT-DLP",
            description: "The core engine powering all media retrieval. It's used to download single videos, entire playlists, audio-only musics, and video thumbnails from hundreds of supported websites.",
            formulaName: "yt-dlp",
            versionParser: { output in
                // Input: "2025.06.30"
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        ),
        Dependency(
            name: "Aria2c",
            description: "A Universal Download Engine enabling high-speed, resumable downloads. It downloads everything from torrents to files captured from your browser, using parallel connections for superior speed and control.",
            formulaName: "aria2",
            commandName: "aria2c",
            versionParser: { output in
                // Split the entire output into individual lines
                let lines = output.split(separator: "\n")
                
                // Find the first line that starts with "aria2 version"
                if let versionLine = lines.first(where: { $0.starts(with: "aria2 version") }) {
                    // The line looks like: "aria2 version 1.37.0"
                    // Split that line by spaces and take the last component
                    return versionLine.split(separator: " ").last.map(String.init)
                }
                
                // If we can't find that line, return nil
                return nil
            }
        ),
        Dependency(
            name: "FFmpeg",
            description: "Required for merging video/audio and format conversions. Includes `ffprobe` to analyze file metadata and `ffplay` for simple, direct media playback.",
            formulaName: "ffmpeg",
            versionFlag: "-version", // FFmpeg uses -version
            versionParser: { output in
                // Input: "ffmpeg version 7.1.1 Copyright..."
                let components = output.split(separator: " ")
                if let versionIndex = components.firstIndex(of: "version") {
                    return String(components[versionIndex + 1])
                }
                return nil
            }
        ),
        Dependency(
            name: "VLC",
            description: "A Powerful Media Player that plays nearly any video file and can stream directly from torrents or web sources without needing to download first.",
            formulaName: "vlc",
            isCask: true,
            versionParser: { output in
                // Input: "VLC media player 3.0.21 Vetinari..."
                let components = output.split(separator: " ")
                // Find the first component that looks like a version number (contains dots)
                return components.first(where: { $0.range(of: #"\d+\.\d+\.\d+"#, options: .regularExpression) != nil })
                               .map(String.init)
            }
        ),
        Dependency(
            name: "HTTrack",
            description: "A Website Copier, allowing you to download a site for offline browsing. Best suited for static HTML-based websites, as it may not capture content rendered by JavaScript.",
            formulaName: "httrack",
            versionParser: { output in
                // Expected input: "HTTrack version 3.49-2"
                // or similar output.
                let components = output.split(separator: " ")
                if let versionIndex = components.firstIndex(of: "version"), versionIndex + 1 < components.count {
                    return String(components[versionIndex + 1])
                }
                return nil
            }
        ),
        Dependency(
            name: "Lftp",
            description: "The engine for all FTP and SFTP operations, built for both speed and power. It handles transfers of single files, entire folders, and supports advanced directory mirroring.",
            formulaName: "lftp",
            versionFlag: "--version", // Lftp uses --version
            versionParser: { output in
                // Get the first line of the output, e.g., "LFTP | Version 4.9.3 | Copyright..."
                guard let firstLine = output.split(separator: "\n").first else { return nil }
                
                // Split that first line into components
                let components = firstLine.split(separator: " ")
                
                // Find the index of "Version" (capitalized) and return the next component
                if let versionIndex = components.firstIndex(of: "Version"), versionIndex + 1 < components.count {
                    return String(components[versionIndex + 1])
                }
                
                return nil
            }
        )
        
    ]

    @Published var isHomebrewInstalled: Bool = false
    @Published var homebrewStatusMessage: String = "Checking for Homebrew..."
    @Published var isInstallingHomebrew = false

    private let shell = Shell()
    
    
    /// Determines the full path to the Homebrew executable.
    private var brewExecutablePath: String? {
        // Check Apple Silicon path first
        let appleSiliconPath = "/opt/homebrew/bin/brew"
        // Then check Intel path
        let intelPath = "/usr/local/bin/brew"
        
        if FileManager.default.fileExists(atPath: appleSiliconPath) {
            return appleSiliconPath
        } else if FileManager.default.fileExists(atPath: intelPath) {
            return intelPath
        } else {
            return nil // Homebrew is not in a standard location
        }
    }

    func beginDependencyCheck() {
        Task {
            await checkAndInstallAll()
        }
    }

    private func checkAndInstallAll() async {
        await checkHomebrewStatus()
        
        if !isHomebrewInstalled {
            await installHomebrew()
            // After attempting install, re-check status
            await checkHomebrewStatus()
        }
        
        // If Homebrew is now present, proceed with other dependencies
        if isHomebrewInstalled {
            for dependency in dependencies {
                await checkDependencyStatus(dependency)
                if dependency.status == .notInstalled {
                    await installDependency(dependency)
                }
            }
        }
    }
    
    // MARK: - Homebrew Management
    
    private func checkHomebrewStatus() async {
        homebrewStatusMessage = "Checking for Homebrew..."
        
        if let path = brewExecutablePath {
            isHomebrewInstalled = true
            homebrewStatusMessage = "Homebrew is installed at: \(path)"
        } else {
            isHomebrewInstalled = false
            homebrewStatusMessage = "Homebrew not found in standard locations."
        }
    }
    
    private func installHomebrew() async {
        isInstallingHomebrew = true
        homebrewStatusMessage = "Installing Homebrew. This may take several minutes and might ask for your password..."
        
        let installCommand = "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        
        do {
            try await shell.runWithStreamingOutput(installCommand) { outputLine in
                self.homebrewStatusMessage = "Homebrew install: \(outputLine)"
            } onError: { errorLine in
                 self.homebrewStatusMessage = "Homebrew install (error): \(errorLine)"
            }
            homebrewStatusMessage = "Homebrew installation completed successfully!"
        } catch {
            homebrewStatusMessage = "Homebrew installation failed: \(error.localizedDescription)"
        }
        
        isInstallingHomebrew = false
    }
    
    // MARK: - Dependency Management

    private func checkDependencyStatus(_ dependency: Dependency) async {
        guard let brewPath = brewExecutablePath else {
            dependency.status = .failed("Homebrew not found.")
            return
        }
        
        dependency.status = .checking
        
        let commandToRun = dependency.commandName ?? dependency.formulaName
        
        // Construct the full path to the executable in the Homebrew bin directory
        let brewPrefix = brewPath.replacingOccurrences(of: "/bin/brew", with: "")
        let fullCommandPath = "\(brewPrefix)/bin/\(commandToRun)"
        
        do {
            let command = "\(fullCommandPath) \(dependency.versionFlag)"
            let output = try await shell.run(command)
            
            // Use the custom parser for this dependency
            if let parsedVersion = dependency.versionParser(output) {
                dependency.version = parsedVersion
                dependency.status = .installed
            } else {
                // Parser failed, we can't determine the version
                dependency.version = "Unknown"
                dependency.status = .installed // It's installed, but version is unclear
            }
            
        } catch {
            // If running the command fails, the tool is not installed or not working.
            dependency.status = .notInstalled
            dependency.version = nil
        }
    }
    
    // In DependencyManager.swift

    private func installDependency(_ dependency: Dependency) async {
        guard isHomebrewInstalled, let brewPath = brewExecutablePath else {
            dependency.status = .failed("Homebrew is not installed.")
            return
        }

        dependency.status = .installing
        dependency.installationLog = ["Starting installation..."]
        
        let caskOption = dependency.isCask ? "--cask " : ""
        let command = "\(brewPath) install \(caskOption)\(dependency.formulaName)"
        
        do {
            // Run the installation
            try await shell.runWithStreamingOutput(command) { outputLine in
                dependency.appendLog(outputLine)
            } onError: { errorLine in
                dependency.appendLog("ERROR: \(errorLine)")
            }
            
            // --- SIMPLIFIED VERIFICATION ---
            // After a successful install command, simply re-check the status.
            // The result of this check will be the final state.
            await checkDependencyStatus(dependency)
            
            // If, after all that, it's still not considered installed, then it's a true failure.
            if dependency.status != .installed {
                dependency.status = .failed("Installation command ran, but tool is still not found.")
            }
            
        } catch {
            // ... (Keep your excellent, detailed error handling logic here for the known failure cases) ...
            let finalErrorMessage = "Installation failed. Check log for details."
            let fullLog = dependency.installationLog.joined(separator: "\n").lowercased()

            if fullLog.contains("already a binary at") {
                // ... logic for binary conflict
            } else if fullLog.contains("cannot override non-directory") {
                // ... logic for corruption
            }
            
            dependency.status = .failed(finalErrorMessage)
        }
    }

}
