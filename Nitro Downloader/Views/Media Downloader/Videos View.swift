
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
