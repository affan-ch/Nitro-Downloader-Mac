
//  AppViewModel.swift


import SwiftUI

enum SidebarItem: String, CaseIterable, Hashable {
    case videos
    case playlists
    case musics
    case thumbnails
    case files
    case torrents
    case ftps
    case instagram
    case facebook
    case tiktok
}

class AppViewModel: ObservableObject {
    @Published var selectedItem: SidebarItem = .videos
    @Published var isSidebarVisible: Bool = true
}
