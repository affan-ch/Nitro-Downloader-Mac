
// Sidebar ViewModel.swift


import SwiftUI

class SidebarViewModel: ObservableObject {
    @Published var selectedItem: SidebarItem = .videos {
        didSet {
            onSelectionChange?(selectedItem)
        }
    }
    
    @Published var selectedMenuItem: String = "All Files" // Example state for sidebar
    @Published var searchText: String = "" // For the search bar in the toolbar
    
    var onSelectionChange: ((SidebarItem) -> Void)?
    
}

enum SidebarItem: String, CaseIterable, Hashable {
    case videos
    case playlists
    case musics
    case thumbnails
    case socialMedia
    case files
    case torrents
    case ftps
    case siteGrabber
    case formatConverter
    case trimAndClip
    case resizeAndCompress
}
