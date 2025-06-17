
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

    func addSingleDownload() { print("ACTION: Add Single Download") }
    func addBulkDownload() { print("ACTION: Add Bulk from File") }

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
