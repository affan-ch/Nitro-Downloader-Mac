
// Dependency Setup View.swift


import SwiftUI

struct DependencySetupView: View {
    @StateObject private var manager = DependencyManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Tool Setup")
                .font(.largeTitle.bold())
                .padding(.bottom)
            
            // Homebrew Status Section
            GroupBox("Homebrew Status") {
                HStack {
                    Image(systemName: manager.isHomebrewInstalled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(manager.isHomebrewInstalled ? .green : .red)
                    
                    VStack(alignment: .leading) {
                        Text(manager.isHomebrewInstalled ? "Homebrew Installed" : "Homebrew Not Found")
                            .font(.headline)
                        Text(manager.homebrewStatusMessage)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    Spacer()
                    if manager.isInstallingHomebrew {
                        ProgressView().padding(.horizontal)
                    }
                }
            }
            
            // Dependencies List Section
            Text("Required Tools").font(.title2.bold())
            
            List(manager.dependencies) { dependency in
                DependencyRowView(dependency: dependency)
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))
            
        }
        .padding()
        .frame(minWidth: 600, minHeight: 450)
        .task {
            // This automatically starts the check when the view appears.
            manager.beginDependencyCheck()
        }
    }
}

struct DependencyRowView: View {
    @ObservedObject var dependency: Dependency
    @State private var showingLog = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dependency.name).font(.headline)
                Text(dependency.description).font(.subheadline).foregroundColor(.secondary)
            }
            
            Spacer()
            
            statusView
                .frame(width: 150, alignment: .trailing)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingLog) {
            InstallationLogView(log: dependency.installationLog, toolName: dependency.name)
        }
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch dependency.status {
        case .unknown:
            Text("Queued...").foregroundColor(.gray)
        case .checking:
            ProgressView().scaleEffect(0.7)
        case .notInstalled:
            Label("Not Installed", systemImage: "xmark.circle.fill").foregroundColor(.red)
        case .installing:
            VStack {
                ProgressView()
                Text("Installing...").font(.caption)
                if !dependency.installationLog.isEmpty {
                    Button("Show Log") { showingLog = true }
                        .font(.caption)
                }
            }
        case .installed:
            VStack(alignment: .trailing) {
                Label("Installed", systemImage: "checkmark.circle.fill").foregroundColor(.green)
                if let version = dependency.version {
                    Text(version).font(.caption).foregroundColor(.secondary)
                }
            }
        case .failed(let error):
            VStack(alignment: .trailing) {
                Label("Failed", systemImage: "exclamationmark.triangle.fill").foregroundColor(.orange)
                Text(error)
                    .font(.caption)
                    .lineLimit(1)
                Button("Show Log") { showingLog = true }
                    .font(.caption)
            }
        }
    }
}

struct InstallationLogView: View {
    let log: [String]
    let toolName: String
    
    var body: some View {
        VStack {
            Text("Installation Log: \(toolName)")
                .font(.headline)
                .padding()
            
            ScrollView {
                Text(log.joined(separator: "\n"))
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

