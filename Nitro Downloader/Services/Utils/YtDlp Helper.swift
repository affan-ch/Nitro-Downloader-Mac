
// YtDlp Helper.swift


import Foundation


class YtDlpHelper {
    
    // IMPORTANT: In a real app, find this path dynamically or let the user set it.
    static let ytDlpPath = "/usr/local/bin/yt-dlp"

    static func fetchVideoInfo(url: String) async throws -> YtDlpInfo {
        let arguments = [
            "--dump-json",
            url
        ]
        
        let jsonData = try runYtDlpProcess(arguments: arguments)
        
        do {
            let decoder = JSONDecoder()
            let info = try decoder.decode(YtDlpInfo.self, from: jsonData)
            return info
        } catch {
            throw YtDlpError.jsonParsingFailed(error)
        }
    }

    // --- REVISED AND CORRECTED FUNCTION ---
    private static func runYtDlpProcess(arguments: [String]) throws -> Data {
        guard FileManager.default.fileExists(atPath: ytDlpPath) else {
            throw YtDlpError.executableNotFound
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: ytDlpPath)
        process.arguments = arguments

        // Create pipes for standard output and standard error
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Start the process
        try process.run()
        
        // Asynchronously read the data from the pipes.
        // This is the key change: we read the data while the process is running.
        let outputData = try outputPipe.fileHandleForReading.readToEnd() ?? Data()
        let errorData = try errorPipe.fileHandleForReading.readToEnd() ?? Data()
        
        // Wait for the process to terminate
        process.waitUntilExit()

        // Check the result
        if process.terminationStatus == 0 {
            // Success
            return outputData
        } else {
            // Failure
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw YtDlpError.processFailed(
                terminationStatus: process.terminationStatus,
                errorOutput: errorString.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
    }
}

enum YtDlpError: Error, LocalizedError {
    case processFailed(terminationStatus: Int32, errorOutput: String)
    case executableNotFound
    case jsonParsingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .processFailed(_, let errorOutput):
            // Only show the error output if it's not empty, otherwise it's confusing.
            let message = errorOutput.isEmpty ? "The process terminated with a non-zero exit code." : errorOutput
            return "yt-dlp process failed. \(message)"
        case .executableNotFound:
            return "yt-dlp executable not found at /usr/local/bin/yt-dlp. Please ensure it's installed and in your PATH, or configure the path in the app's settings."
        case .jsonParsingFailed(let error):
            return "Failed to parse video information. Error: \(error.localizedDescription)"
        }
    }
}

// YtDlp Models

struct YtDlpInfo: Codable {
    // Core Info
    let id: String
    let title: String
    let fulltitle: String?
    let description: String?
    let thumbnail: String? // URL for the best thumbnail
    let formats: [YtDlpFormat]
    
    // Duration
    let duration: Double? // Duration in seconds
    let duration_string: String? // Pre-formatted duration string
    
    // Channel / Uploader Info
    let channel: String?
    let channel_url: String?
    let channel_follower_count: Int?
    let uploader: String?
    let uploader_id: String?
    let uploader_url: String?
    
    // Engagement & Stats
    let view_count: Int?
    let like_count: Int?
    let comment_count: Int?
    let upload_date: String? // "YYYYMMDD" format
    
    // Status
    let is_live: Bool?
    let was_live: Bool?
    let availability: String?
}

// Represents a single available format (video, audio, or combined)
struct YtDlpFormat: Codable, Identifiable, Hashable {
    let format_id: String
    let format_note: String?
    let ext: String
    let resolution: String? // "1920x1080"
    let vcodec: String? // e.g., "avc1.640028", "vp09.00.40.08", "av01.0.08M.08"
    let acodec: String? // "mp4a.40.2"
    let filesize: Int?
    let tbr: Double? // Total Bitrate in Kbit/s
    let language: String?

    // Make it identifiable for SwiftUI lists
    var id: String { format_id }

    // --- NEW: Computed property to get numerical dimensions for sorting ---
    var dimensions: (width: Int, height: Int) {
        guard let res = resolution, res.contains("x") else { return (0, 0) }
        let parts = res.split(separator: "x")
        guard parts.count == 2, let width = Int(parts[0]), let height = Int(parts[1]) else { return (0, 0) }
        return (width, height)
    }

    // --- NEW: Computed property for a user-friendly codec name ---
    var prettyCodec: String {
        guard let codec = vcodec, codec != "none" else { return "N/A" }
        if codec.starts(with: "avc1") { return "H.264" }
        if codec.starts(with: "vp09") || codec.starts(with: "vp9") { return "VP9" }
        if codec.starts(with: "av01") { return "AV1" }
        if codec.starts(with: "hev1") || codec.starts(with: "hvc1") { return "H.265 (HEVC)" }
        return codec.uppercased() // Fallback
    }
    
    // --- REVISED: A much better display name for the sorted list ---
    var detailedDisplayName: String {
        var parts: [String] = []
        
        // Part 1: Resolution (or format note if resolution is missing)
        if let res = resolution, res != "audio only" {
            parts.append(res)
        } else if let note = format_note {
            parts.append(note)
        }
        
        // Part 2: Codec
        parts.append(prettyCodec)
        
        // Part 3: Quality Metric (Prefer bitrate, fallback to filesize)
        if let bitrate = tbr, bitrate > 0 {
            parts.append(String(format: "%.0f kbps", bitrate))
        } else if let size = filesize {
            parts.append(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))
        } else {
            // This handles the "256x144 - mp4" case from your image
            parts.append(ext.uppercased())
        }
        
        return parts.joined(separator: " - ")
    }
    
    // Original displayName for audio formats (simpler)
    var audioDisplayName: String {
        var parts: [String] = []

        // --- Part 1: Language (Primary Information) ---
        // Use the 'language' field first. If it's nil, try to parse from the note.
        if let langCode = language, let langName = Locale.current.localizedString(forIdentifier: langCode) {
            parts.append(langName)
        } else if let note = format_note, note.contains("dubbed-auto") || note.contains("original") {
            // Fallback for parsing language from the format_note
            let components = note.split(separator: " - ").map { String($0) }
            if !components.isEmpty {
                parts.append(components[0]) // e.g., "Deutsch (Deutschland)"
            }
        }

        // --- Part 2: Quality (Bitrate or Note) ---
        if let bitrate = tbr, bitrate > 0 {
            parts.append(String(format: "%.0f kbps", bitrate))
        } else if let note = format_note, !parts.contains(note) {
            // Add quality notes like 'low' or 'high' if available and not already part of the language
            let qualityNote = note.replacingOccurrences(of: "American English - ", with: "")
                                  .replacingOccurrences(of: "original, ", with: "")
                                  .replacingOccurrences(of: "(default)", with: "")
                                  .trimmingCharacters(in: .whitespaces)
            if !qualityNote.isEmpty && qualityNote != note {
                parts.append(qualityNote.capitalized) // e.g., "Low", "High"
            }
        }
        
        // --- Part 3: Codec ---
        if let codec = acodec, codec != "none" {
            let prettyAudioCodec = codec.starts(with: "mp4a") ? "AAC" : "Opus"
            parts.append(prettyAudioCodec)
        } else {
            parts.append(ext.uppercased())
        }

        // --- Part 4: File Size (as a final piece of info if available) ---
        if let size = filesize {
            parts.append(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file))
        }
        
        // If the list is just the codec and extension, it's a generic track. Show simple version.
        if parts.count <= 2 && (parts.contains("AAC") || parts.contains("Opus")) {
             if let bitrate = tbr, bitrate > 0 {
                 return "\(String(format: "%.0f kbps", bitrate)) - \(parts.last ?? ext.uppercased())"
             }
        }

        return parts.joined(separator: " - ")
    }
    
    var prettyAudioCodec: String {
        guard let codec = acodec, codec != "none" else {
            // Fallback for formats without a codec but with an extension
            return ext.uppercased()
        }
        if codec.starts(with: "mp4a") { return "AAC" }
        if codec.starts(with: "opus") { return "Opus" }
        return codec.uppercased()
    }
}
