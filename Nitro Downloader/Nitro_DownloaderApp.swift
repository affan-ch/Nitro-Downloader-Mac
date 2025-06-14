
//  Nitro_DownloaderApp.swift


import SwiftUI

@main
struct Nitro_DownloaderApp: App {
    @StateObject private var sidebarViewModel = SidebarViewModel()


    var body: some Scene {
        WindowGroup {
            SidebarView(viewModel: sidebarViewModel)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
