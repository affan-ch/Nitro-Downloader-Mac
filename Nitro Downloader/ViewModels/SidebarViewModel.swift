
// SidebarViewModel.swift ✅


import SwiftUI

class SidebarViewModel: ObservableObject {
    @Published var selectedItem: SidebarItem = .videos {
        didSet {
            onSelectionChange?(selectedItem)
        }
    }

    var onSelectionChange: ((SidebarItem) -> Void)?
}

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
