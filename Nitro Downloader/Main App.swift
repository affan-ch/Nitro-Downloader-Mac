
// Main App.swift


import SwiftUI

@main
struct MainApp: App {
    @StateObject private var sidebarViewModel = SidebarViewModel()

    var body: some Scene {
        WindowGroup {
            SidebarView(viewModel: sidebarViewModel)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
