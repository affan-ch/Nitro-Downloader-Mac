
// Videos ViewModel.swift


import SwiftUI
import Foundation
import Combine

@MainActor
class VideosViewModel: ObservableObject {
    
    // MARK: - Core State
    @Published var downloadItems: [DownloadItem] = []
    @Published var selection: Set<DownloadItem.ID> = []
    
    // MARK: - Toolbar State
    @Published var searchText = ""
    @Published var statusFilter: DownloadStatus? = nil // nil means "All"
    @Published var sortOrder = [KeyPathComparator(\DownloadItem.fileName)]
    @Published var columnVisibility = ColumnVisibility()
    @Published var isShowingSettings = false
    @Published var isShowingAddSingleDownload = false
    // MARK: - Computed Properties for UI Logic
    
    // The single source of truth for what the table displays.
    // It automatically applies search, filtering, and sorting.
    var filteredAndSortedItems: [DownloadItem] {
        var items = downloadItems
        
        // 1. Apply Search Filter
        if !searchText.isEmpty {
            items = items.filter { $0.fileName.localizedCaseInsensitiveContains(searchText) || $0.description.localizedCaseInsensitiveContains(searchText) }
        }
        
        // 2. Apply Status Filter
        if let statusFilter = statusFilter {
            items = items.filter { $0.status == statusFilter }
        }
        
        // 3. Apply Sorting
        items.sort(using: sortOrder)
        
        return items
    }
    
    // MARK: - Computed Properties for Button States
    
    private var selectedItems: [DownloadItem] {
        downloadItems.filter { selection.contains($0.id) }
    }
    
    var canResume: Bool {
        guard selectedItems.count == 1, let item = selectedItems.first else { return false }
        return item.status == .paused
    }
    
    var canStop: Bool {
        guard selectedItems.count == 1, let item = selectedItems.first else { return false }
        return item.status == .downloading
    }
    
    var canStopAll: Bool {
        // Enabled if any of the selected items are currently downloading
        return !selectedItems.isEmpty && selectedItems.contains { $0.status == .downloading }
    }
    
    var canDelete: Bool {
        return !selection.isEmpty
    }
    
    // MARK: - Initializer with Dummy Data
    init() {
        self.downloadItems = Self.createDummyData()
    }
    
    // MARK: - Toolbar Actions
    
    func addSingleDownload() {
        print("ACTION: Add Single Download")
        isShowingAddSingleDownload = true
    }
    func addBulkDownload() { print("ACTION: Add Bulk from File") }
    
    func addDownload(command: [String], title: String, sourceURL: URL) {
        print("Received command to start download:")
        print("yt-dlp " + command.joined(separator: " "))
        
    }
    
    func resumeSelected() {
        guard let itemID = selection.first, let index = downloadItems.firstIndex(where: { $0.id == itemID }) else { return }
        downloadItems[index].status = .downloading
        print("ACTION: Resuming \(downloadItems[index].fileName)")
    }
    
    func stopSelected() {
        guard let itemID = selection.first, let index = downloadItems.firstIndex(where: { $0.id == itemID }) else { return }
        downloadItems[index].status = .paused
        print("ACTION: Stopping \(downloadItems[index].fileName)")
    }
    
    func stopAllSelected() {
        for id in selection {
            if let index = downloadItems.firstIndex(where: { $0.id == id }), downloadItems[index].status == .downloading {
                downloadItems[index].status = .paused
            }
        }
        print("ACTION: Stop All for selected items")
    }
    
    func deleteSelected() {
        downloadItems.removeAll { selection.contains($0.id) }
        selection.removeAll()
        print("ACTION: Deleting selected items")
    }
    
    func openSettings() {
        isShowingSettings = true
    }
    
}

// Helper struct for managing column visibility
struct ColumnVisibility {
    var size = true
    var status = true
    var timeLeft = true
    var downloadSpeed = true
    var downloadURL = false // Hidden by default
    var lastTryDate = true
    var description = false // Hidden by default
}

// Dummy Data Generator (place this inside the ViewModel or in its own file)
extension VideosViewModel {
    static func createDummyData() -> [DownloadItem] {
        return [
            DownloadItem(fileName: "Nature_Documentary_4K.mp4", size: 4200.5, status: .completed, timeLeft: "0s", downloadSpeed: "0 KB/s", downloadURL: URL(string: "http://example.com/nature.mp4")!, lastTryDate: Date().addingTimeInterval(-3600), description: "A beautiful documentary about nature."),
            DownloadItem(fileName: "My_Band_Live_Concert.mov", size: 1500.2, status: .downloading, timeLeft: "1m 32s", downloadSpeed: "25.5 MB/s", downloadURL: URL(string: "http://example.com/concert.mov")!, lastTryDate: Date(), description: "Live concert footage."),
            DownloadItem(fileName: "Cooking_Tutorial_HD.mp4", size: 850.0, status: .paused, timeLeft: "5m 10s", downloadSpeed: "0 KB/s", downloadURL: URL(string: "http://example.com/cooking.mp4")!, lastTryDate: Date().addingTimeInterval(-600), description: "How to make pasta."),
            DownloadItem(fileName: "Archived_Project_Files.zip", size: 250.7, status: .failed, timeLeft: "--", downloadSpeed: "0 KB/s", downloadURL: URL(string: "http://example.com/archive.zip")!, lastTryDate: Date().addingTimeInterval(-86400), description: "Network error occurred."),
            DownloadItem(fileName: "Software_Update_v2.dmg", size: 670.1, status: .queued, timeLeft: "--", downloadSpeed: "0 KB/s", downloadURL: URL(string: "http://example.com/update.dmg")!, lastTryDate: Date(), description: "Waiting for other downloads to finish."),
            DownloadItem(fileName: "University_Lecture_Series.mp4", size: 2200.0, status: .downloading, timeLeft: "3m 05s", downloadSpeed: "19.8 MB/s", downloadURL: URL(string: "http://example.com/lecture.mp4")!, lastTryDate: Date(), description: "Physics 101 lecture recording.")
        ]
    }
}


// DownloadItem.swift


// The status of a download, with associated colors and icons for the UI.
enum DownloadStatus: String, CaseIterable, Identifiable {
    case downloading = "Downloading"
    case paused = "Paused"
    case completed = "Completed"
    case failed = "Failed"
    case queued = "Queued"
    
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .downloading: "arrow.down.circle"
        case .paused: "pause.circle"
        case .completed: "checkmark.circle.fill"
        case .failed: "xmark.circle.fill"
        case .queued: "hourglass"
        }
    }
    
    var color: Color {
        switch self {
        case .downloading: .blue
        case .paused: .orange
        case .completed: .green
        case .failed: .red
        case .queued: .gray
        }
    }
}

// Represents a single download item in the table.
// Conforms to Identifiable and Hashable for table selection.
struct DownloadItem: Identifiable, Hashable {
    let id = UUID()
    var fileName: String
    var size: Double // In MB
    var status: DownloadStatus
    var timeLeft: String
    var downloadSpeed: String
    var downloadURL: URL
    var lastTryDate: Date
    var description: String
}



@MainActor
class AddSingleVideoDownloadViewModel: ObservableObject {
    // MARK: - Published Properties for UI
    @Published var urlString = ""
    @Published var videoTitle = ""
    @Published var uploaderName = ""
    @Published var viewCount: Int?
    @Published var likeCount: Int?
    @Published var uploadDate: Date?
    @Published var durationString = ""
    @Published var commentCount: Int?
    
    // Format Selection
    @Published var availableVideoFormats: [YtDlpFormat] = []
    @Published var availableAudioFormats: [YtDlpFormat] = []
    @Published var selectedVideoFormatId = "bestvideo"
    @Published var selectedAudioFormatId = "bestaudio"
    
    // Conversion Options
    @Published var convertVideoFormat: String? = "mp4" // Default to mp4
    
    // Extra Options
    @Published var embedSubtitles = true
    @Published var embedThumbnail = true
    @Published var embedMetadata = true
    @Published var embedChapters = true
    
    // View State
    @Published var isFetchingFormats = false
    @Published var canFetch = false
    @Published var errorMessage: String?
    
    let videoFormats = ["mp4", "mkv", "mov", "webm", "flv"]
    
    // Callback to the main view model
    var onStartDownload: ((_ command: [String], _ title: String, _ sourceURL: URL) -> Void)?
    
    
    // Formatter for large numbers (e.g., 1,234,567 -> 1.2M)
    private func formatNumber(_ number: Int) -> String {
        let num = Double(number)
        let thousand = num / 1000
        let million = num / 1000000
        
        if million >= 1.0 {
            return "\(round(million*10)/10)M"
        } else if thousand >= 1.0 {
            return "\(round(thousand*10)/10)K"
        } else {
            return "\(number)"
        }
    }
    
    // Formatter for dates (this one is correct and can stay)
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    // --- UPDATE the computed properties to use the new function ---
    var formattedViewCount: String {
        guard let count = viewCount else { return "N/A" }
        return formatNumber(count)
    }
    
    var formattedCommentCount: String {
        guard let count = commentCount else { return "N/A" }
        return formatNumber(count) // Uses the same helper function
    }
    
    var formattedLikeCount: String {
        guard let count = likeCount else { return "N/A" }
        return formatNumber(count)
    }
    
    var formattedUploadDate: String {
        guard let date = uploadDate else { return "N/A" }
        return Self.dateFormatter.string(from: date)
    }
    
    // --- ADD THIS: Computed property for sorted video formats ---
    var sortedVideoFormats: [YtDlpFormat] {
        availableVideoFormats.sorted { lhs, rhs in
            // 1. Primary Sort: Resolution height, descending (e.g., 1080 > 720)
            let lhsHeight = lhs.dimensions.height
            let rhsHeight = rhs.dimensions.height
            if lhsHeight != rhsHeight {
                return lhsHeight > rhsHeight
            }
            
            // 2. Secondary Sort (if resolutions are equal): Bitrate, descending (higher is better)
            let lhsBitrate = lhs.tbr ?? 0
            let rhsBitrate = rhs.tbr ?? 0
            if lhsBitrate != rhsBitrate {
                return lhsBitrate > rhsBitrate
            }
            
            // 3. Tertiary Sort (if bitrates are also equal): Filesize, descending
            let lhsSize = lhs.filesize ?? 0
            let rhsSize = rhs.filesize ?? 0
            return lhsSize > rhsSize
        }
    }
    
    // Helper struct to define what makes an audio format "unique" to a user.
    // We use rounded bitrate to group similar qualities (e.g., 129kbps and 130kbps).
    private struct AudioFormatKey: Hashable {
        let language: String
        let codec: String
        let bitrate: Int // Rounded bitrate
    }
    
    
    var uniqueAndSortedAudioFormats: [YtDlpFormat] {
        // 1. Filter out useless formats (like the "MP4" ones with no bitrate)
        let validFormats = availableAudioFormats.filter { ($0.tbr ?? 0) > 0 }
        
        // 2. Sort all valid formats by quality (highest bitrate first).
        // This is crucial because we want to keep the BEST version of any duplicates.
        let sortedFormats = validFormats.sorted { $0.tbr ?? 0 > $1.tbr ?? 0 }
        
        var uniqueKeys = Set<AudioFormatKey>()
        var uniqueFormats: [YtDlpFormat] = []
        
        // 3. Iterate through the sorted list and pick only the first of each unique type.
        for format in sortedFormats {
            let key = AudioFormatKey(
                language: format.language ?? "unknown",
                codec: format.prettyAudioCodec,
                bitrate: Int(round(format.tbr ?? 0)) // Round bitrate to group similar qualities
            )
            
            // If we haven't seen this combination of lang/codec/bitrate before, add it.
            if !uniqueKeys.contains(key) {
                uniqueFormats.append(format)
                uniqueKeys.insert(key)
            }
        }
        
        return uniqueFormats
    }
    
    init() {
        // Debounce URL typing to enable the "Fetch" button
        $urlString
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .map { URL(string: $0) != nil }
            .assign(to: &$canFetch)
    }
    
    private func resetInfo() {
        videoTitle = ""
        uploaderName = ""
        viewCount = nil
        likeCount = nil
        uploadDate = nil
        durationString = ""
        availableVideoFormats = []
        availableAudioFormats = []
        errorMessage = nil
    }
    
    func fetchFormats() {
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            return
        }
        
        isFetchingFormats = true
        resetInfo()
        
        Task {
            do {
                let info = try await YtDlpHelper.fetchVideoInfo(url: url.absoluteString)
                
                // Populate all the new state properties
                self.videoTitle = info.fulltitle ?? info.title
                self.uploaderName = info.uploader ?? info.channel ?? "Unknown Uploader"
                self.viewCount = info.view_count
                self.likeCount = info.like_count
                self.durationString = info.duration_string ?? ""
                self.commentCount = info.comment_count
                
                if let dateStr = info.upload_date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyyMMdd"
                    self.uploadDate = formatter.date(from: dateStr)
                }
                
                // Filter and sort formats (same logic as before)
                self.availableVideoFormats = info.formats.filter { $0.vcodec != "none" && $0.acodec == "none" }
                self.availableAudioFormats = info.formats.filter { $0.acodec != "none" && $0.vcodec == "none" }
                
            } catch {
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
            isFetchingFormats = false
        }
    }
    
    func startDownload() {
        // 1. Build the command array
        var command: [String] = []
        
        // Check if the user wants the default "Best Available" for both.
        if selectedVideoFormatId == "bestvideo" && selectedAudioFormatId == "bestaudio" {
            // Use the more robust format string with a fallback.
            command.append("-f")
            command.append("bestvideo+bestaudio/best")
        } else {
            // Otherwise, use the specific formats the user selected from the list.
            command.append("-f")
            command.append("\(selectedVideoFormatId)+\(selectedAudioFormatId)")
        }
        
        // Video Conversion (Remuxing)
        if let videoFormat = convertVideoFormat {
            command.append("--remux-video")
            command.append(videoFormat)
        }
        
        // --- Embeddings ---
        if embedSubtitles {
            command.append("--embed-subs")
        }
        if embedThumbnail {
            command.append("--embed-thumbnail")
        }
        if embedMetadata {
            command.append("--embed-metadata")
        }
        if embedChapters { // Add chapter flag
            command.append("--embed-chapters")
        }
        
        // --- Filename & Final URL ---
        command.append("--restrict-filenames") // Add filename restriction
        command.append("-o")
        command.append("%(title)s [%(id)s].%(ext)s") // A safer filename template
        command.append(urlString)
        
        guard let url = URL(string: urlString), let onStart = onStartDownload else {
            errorMessage = "Internal error: Could not start download."
            return
        }
        
        onStart(command, videoTitle.isEmpty ? "New Download" : videoTitle, url)
    }
}
