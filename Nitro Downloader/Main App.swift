
// Main App.swift


import SwiftUI

@main
struct MainApp: App {
    @StateObject private var sidebarViewModel = SidebarViewModel()
    
    init(){
        setupDatabase()
    }
    var body: some Scene {
        WindowGroup {
            SidebarView(viewModel: sidebarViewModel)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
