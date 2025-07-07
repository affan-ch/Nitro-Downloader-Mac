
// Videos View.swift


import SwiftUI

struct VideosView: View {
    @StateObject private var viewModel = VideosViewModel()
    private let toolbarButtonVerticalPadding: CGFloat = 6
    private let toolbarButtonHorizontalPadding: CGFloat = 8
    
    var body: some View {
        VStack(spacing: 0) {
            // The Table is the main content
            Table(viewModel.filteredAndSortedItems, selection: $viewModel.selection, sortOrder: $viewModel.sortOrder) {
                
                TableColumn("File Name", value: \.fileName) { item in
                    Text(item.fileName)
                        .lineLimit(1)
                        .help(item.fileName) // Show full name on hover
                }
                .width(min: 200)
                
                if viewModel.columnVisibility.size {
                    TableColumn("Size", value: \.size) { item in
                        Text(String(format: "%.1f MB", item.size))
                    }
                    .width(80)
                }
                
                if viewModel.columnVisibility.status {
                    TableColumn("Status", value: \.status.rawValue) { item in
                        Label(item.status.rawValue, systemImage: item.status.icon)
                            .foregroundStyle(item.status.color)
                    }
                    .width(120)
                }
                
                if viewModel.columnVisibility.timeLeft {
                    TableColumn("Time Left", value: \.timeLeft).width(80)
                }
                
                if viewModel.columnVisibility.downloadSpeed {
                    TableColumn("Speed", value: \.downloadSpeed).width(100)
                }
                
                if viewModel.columnVisibility.lastTryDate {
                    TableColumn("Last Try", value: \.lastTryDate.timeIntervalSince1970) { item in
                        Text(item.lastTryDate, style: .relative)
                    }
                    .width(100)
                }
                
                if viewModel.columnVisibility.description {
                    TableColumn("Description", value: \.description).width(min: 150)
                }
                
                if viewModel.columnVisibility.downloadURL {
                    TableColumn("URL", value: \.downloadURL.absoluteString) { item in
                        Text(item.downloadURL.absoluteString)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .help(item.downloadURL.absoluteString)
                    }
                    .width(min: 150)
                }
            }
            .tableStyle(.inset(alternatesRowBackgrounds: true))
        }
        
        .navigationTitle("Video Downloads")
        .searchable(text: $viewModel.searchText, prompt: "Search by Name or Description")
        .sheet(isPresented: $viewModel.isShowingSettings) {
            VideoSettingsView() // A placeholder for your settings modal
        }
        .sheet(isPresented: $viewModel.isShowingAddSingleDownload) {
            AddSingleVideoDownloadView(onStartDownload: viewModel.addDownload)
        }
        .toolbar {
            
            // MARK: Left Toolbar Group
            ToolbarItemGroup(placement: .navigation) {
                Menu {
                    Button("Add Single Download", action: viewModel.addSingleDownload)
                    Button("Add Bulk from File...", action: viewModel.addBulkDownload)
                } label: {
                    Label("Add Download", systemImage: "plus")
                        .padding(.vertical, toolbarButtonVerticalPadding)
                        .padding(.horizontal, toolbarButtonHorizontalPadding)
                }
                .help("Add new downloads")
            }
            
            
            // MARK: Right Toolbar Group
            ToolbarItemGroup(placement: .primaryAction) {
                
                // --- Action Buttons ---
                Button(action: viewModel.resumeSelected) {
                    Label("Resume", systemImage: "play.fill")
                        .padding(.vertical, toolbarButtonVerticalPadding)
                        .padding(.horizontal, toolbarButtonHorizontalPadding)
                }
                .help("Resume selected download")
                .disabled(!viewModel.canResume)
                
                Button(action: viewModel.stopSelected) {
                    Label("Stop", systemImage: "pause.fill")
                        .padding(.vertical, toolbarButtonVerticalPadding)
                        .padding(.horizontal, toolbarButtonHorizontalPadding)
                }
                .help("Pause selected download")
                .disabled(!viewModel.canStop)
                
                Button(action: viewModel.stopAllSelected) {
                    Label("Stop All", systemImage: "stop.fill")
                        .padding(.vertical, toolbarButtonVerticalPadding)
                        .padding(.horizontal, toolbarButtonHorizontalPadding)
                }
                .help("Pause all selected downloads")
                .disabled(!viewModel.canStopAll)
                
                Button(action: viewModel.deleteSelected) {
                    Label("Delete", systemImage: "trash")
                        .padding(.vertical, toolbarButtonVerticalPadding)
                        .padding(.horizontal, toolbarButtonHorizontalPadding)
                }
                .help("Delete selected downloads")
                .disabled(!viewModel.canDelete)
                
                Spacer()
                
                // --- View & Filter Menus ---
                
                Menu {
                    // Using a Picker for exclusive selection
                    Picker("Filter by Status", selection: $viewModel.statusFilter) {
                        Text("All Statuses").tag(nil as DownloadStatus?)
                        ForEach(DownloadStatus.allCases) { status in
                            Label(status.rawValue, systemImage: status.icon).tag(status as DownloadStatus?)
                        }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .padding(.vertical, toolbarButtonVerticalPadding)
                        .padding(.horizontal, toolbarButtonHorizontalPadding)
                }
                .help("Filter items by status")
                
                Menu {
                    Toggle("Size", isOn: $viewModel.columnVisibility.size)
                    Toggle("Status", isOn: $viewModel.columnVisibility.status)
                    Toggle("Time Left", isOn: $viewModel.columnVisibility.timeLeft)
                    Toggle("Speed", isOn: $viewModel.columnVisibility.downloadSpeed)
                    Toggle("Last Try Date", isOn: $viewModel.columnVisibility.lastTryDate)
                    Divider()
                    Toggle("Description", isOn: $viewModel.columnVisibility.description)
                    Toggle("Download URL", isOn: $viewModel.columnVisibility.downloadURL)
                } label: {
                    Label("Toggle Columns", systemImage: "tablecells")
                        .padding(.vertical, toolbarButtonVerticalPadding)
                        .padding(.horizontal, toolbarButtonHorizontalPadding)
                }
                .help("Show or hide table columns")
                
                Button(action: viewModel.openSettings) {
                    Label("Settings", systemImage: "gearshape")
                        .padding(.vertical, toolbarButtonVerticalPadding)
                        .padding(.horizontal, toolbarButtonHorizontalPadding)
                }
                .help("Open application settings")
            }
        }
    }
}

// A placeholder for your Settings modal
struct VideoSettingsView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text("Application Settings").font(.title)
            // Add your settings controls here
            Spacer()
            Button("Done") {
                dismiss()
            }
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}




struct AddSingleVideoDownloadView: View {
    @StateObject private var viewModel = AddSingleVideoDownloadViewModel()
    @Environment(\.dismiss) var dismiss
    
    let onStartDownload: ((_ command: [String], _ title: String, _ sourceURL: URL) -> Void)
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                // --- Section 1: URL Input & Video Title ---
                Section {
                    // This HStack is now stable and won't misalign
                    HStack {
                        TextField("Video URL", text: $viewModel.urlString, prompt: Text("https://..."))
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: viewModel.fetchFormats) {
                            Label("Fetch", systemImage: "arrow.down.circle")
                        }
                        .disabled(!viewModel.canFetch || viewModel.isFetchingFormats)
                        .overlay { // Use overlay to prevent layout shift
                            if viewModel.isFetchingFormats {
                                ProgressView().scaleEffect(0.7)
                            }
                        }
                    }
                    
                    if !viewModel.videoTitle.isEmpty {
                        Text(viewModel.videoTitle)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                
                // --- Section 2: Video Info (NEW) ---
                if !viewModel.uploaderName.isEmpty {
                    Section("Video Information") {
                        LabeledContent("Uploader", value: viewModel.uploaderName)
                        
                        // For a more compact layout that fits more info:
                        HStack(spacing: 12) { // Use less spacing
                            InfoItem(icon: "eye", value: viewModel.formattedViewCount, label: "Views")
                            Divider()
                            InfoItem(icon: "hand.thumbsup", value: viewModel.formattedLikeCount, label: "Likes")
                            Divider()
                            InfoItem(icon: "text.bubble", value: viewModel.formattedCommentCount, label: "Comments")
                            Divider()
                            InfoItem(icon: "clock", value: viewModel.durationString, label: "Duration")
                            Divider()
                            InfoItem(icon: "calendar", value: viewModel.formattedUploadDate, label: "Uploaded")

                        }
                        .frame(height: 40) // Give the HStack a fixed height for stability
                        .foregroundStyle(.secondary)
                    }
                }
                
                // --- Section 3: Quality & Format ---
                Section("Quality & Format") {
                    Picker("Video Quality", selection: $viewModel.selectedVideoFormatId) {
                        Text("Best Available").tag("bestvideo")
                        ForEach(viewModel.sortedVideoFormats) { Text($0.detailedDisplayName).tag($0.id) }
                    }
                    
                    Picker("Audio Quality", selection: $viewModel.selectedAudioFormatId) {
                        Text("Best Available").tag("bestaudio")
                        ForEach(viewModel.uniqueAndSortedAudioFormats) { Text($0.audioDisplayName).tag($0.id) }
                    }
                    
                    Picker("Convert To", selection: $viewModel.convertVideoFormat) {
                        Text("None").tag(nil as String?)
                        ForEach(viewModel.videoFormats, id: \.self) { Text($0.uppercased()).tag($0 as String?) }
                    }
                }
                
                // --- Section 4: Extras (Updated) ---
                Section("Extras") {
                    Toggle("Embed Subtitles", isOn: $viewModel.embedSubtitles)
                    Toggle("Embed Thumbnail", isOn: $viewModel.embedThumbnail)
                    Toggle("Embed Metadata", isOn: $viewModel.embedMetadata)
                    Toggle("Embed Chapters", isOn: $viewModel.embedChapters) // New
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section { Text(errorMessage).foregroundColor(.red) }
                }
            }
            .formStyle(.grouped)
            
            // --- Bottom Action Buttons ---
            HStack {
                Spacer()
                Button("Cancel", role: .cancel, action: { dismiss() }).keyboardShortcut(.cancelAction)
                Button("Start Download") {
                    viewModel.startDownload()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.urlString.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            .background(.bar)
        }
        .frame(minWidth: 650, idealWidth: 700, minHeight: 500, idealHeight: 580)
        .onAppear {
            viewModel.onStartDownload = self.onStartDownload
        }
    }
}

// Helper view for the info items
struct InfoItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(value, systemImage: icon)
                .font(.subheadline.weight(.semibold))
            Text(label)
                .font(.caption2)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}
